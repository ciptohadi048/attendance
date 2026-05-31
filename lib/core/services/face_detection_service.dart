import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Result of one face-detection + quality analysis pass on a camera frame.
class FaceAnalysis {
  const FaceAnalysis({
    required this.faces,
    required this.imageSize,
    required this.rotation,
    required this.brightnessOk,
  });

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool brightnessOk;

  bool get hasExactlyOneFace => faces.length == 1;
  bool get hasMultipleFaces => faces.length > 1;
  bool get noFace => faces.isEmpty;
}

/// Wraps ML Kit's [FaceDetector] with CameraImage → InputImage conversion.
///
/// Created once and kept alive for the duration of the camera session; call
/// [dispose] when the camera is closed.
class FaceDetectionService {
  FaceDetectionService()
      : _detector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.fast,
            enableContours: true,
            enableClassification: true,
            minFaceSize: 0.15,
          ),
        );

  final FaceDetector _detector;

  /// Analyse a single [CameraImage] frame.
  ///
  /// Returns `null` if the image cannot be converted (e.g. unsupported format
  /// on this platform version).
  Future<FaceAnalysis?> analyse(
    CameraImage image,
    CameraDescription cameraDescription,
  ) async {
    final inputImage = _toInputImage(image, cameraDescription);
    if (inputImage == null) return null;

    final faces = await _detector.processImage(inputImage);
    final brightnessOk = _checkBrightness(image);

    return FaceAnalysis(
      faces: faces,
      imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg,
      brightnessOk: brightnessOk,
    );
  }

  /// Analyse a captured [File] (JPEG) — used for the final validation before
  /// saving.
  Future<List<Face>> analyseFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    return _detector.processImage(inputImage);
  }

  Future<void> dispose() => _detector.close();

  // ---------------------------------------------------------------------------
  // CameraImage → InputImage conversion (handles iOS BGRA + Android YUV)
  // ---------------------------------------------------------------------------

  InputImage? _toInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final rotation = _rotationFromCamera(camera);
    final format = _formatFromImage(image);
    if (format == null) return null;

    // For multi-plane (Android YUV), concatenate all plane bytes.
    // For single-plane (iOS BGRA), use the one plane directly.
    final bytes = image.planes.length == 1
        ? image.planes.first.bytes
        : _concatenatePlanes(image.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotationFromCamera(CameraDescription camera) {
    // iOS BGRA frames are already consumer-orientation-corrected by AVFoundation.
    // Passing a non-zero rotation causes ML Kit to double-rotate and misplace
    // bounding boxes — always use rotation0deg on iOS.
    if (Platform.isIOS) return InputImageRotation.rotation0deg;

    // Android: map sensor orientation to the ML Kit rotation constant.
    final sensorOrientation = camera.sensorOrientation;
    return switch (sensorOrientation) {
      90 => InputImageRotation.rotation90deg,
      180 => InputImageRotation.rotation180deg,
      270 => InputImageRotation.rotation270deg,
      _ => InputImageRotation.rotation0deg,
    };
  }

  InputImageFormat? _formatFromImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.bgra8888) {
      return InputImageFormat.bgra8888;
    }
    if (image.format.group == ImageFormatGroup.yuv420) {
      return InputImageFormat.yuv_420_888;
    }
    if (image.format.group == ImageFormatGroup.nv21) {
      return InputImageFormat.nv21;
    }
    return null;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    return Uint8List.fromList(
      planes.expand((p) => p.bytes).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Lighting check: sample Y-plane (or green channel) mean brightness.
  // A mean luma < 40 (out of 255) is considered too dark.
  // ---------------------------------------------------------------------------

  bool _checkBrightness(CameraImage image) {
    final yPlane = image.planes.first.bytes;
    if (yPlane.isEmpty) return true;
    // Sample every 64th byte to avoid blocking the UI thread.
    int sum = 0;
    int count = 0;
    for (int i = 0; i < yPlane.length; i += 64) {
      sum += yPlane[i];
      count++;
    }
    final mean = sum / count;
    return mean > 40;
  }
}
