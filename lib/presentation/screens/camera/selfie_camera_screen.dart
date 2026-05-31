import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../core/services/face_detection_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../providers/attendance_providers.dart';
import '../../router/app_routes.dart';
import '../../widgets/primary_button.dart';

/// Selfie capture screen with real-time ML Kit face detection.
///
/// Validates: exactly 1 face detected · face fits the oval guide ·
/// lighting is sufficient · image is not blurry (landmark count proxy).
/// The capture button is enabled only when all checks pass.
class SelfieCameraScreen extends ConsumerStatefulWidget {
  const SelfieCameraScreen({
    super.key,
    required this.attendanceType,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.isInArea,
  });

  final AttendanceType attendanceType;
  // GPS context captured on the previous screen and passed forward, so the
  // selfie screen doesn't depend on the (auto-disposing) location streams.
  final String userId;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool isInArea;

  @override
  ConsumerState<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends ConsumerState<SelfieCameraScreen> {
  CameraController? _controller;
  FaceDetectionService? _faceService;

  // Validation state (updated from the image stream).
  bool _faceDetected = false;
  bool _faceInFrame = false;
  bool _lightingOk = false;
  bool _notBlurry = false; // proxied by landmark count

  bool _isCapturing = false;
  bool _isProcessingFrame = false;

  // Throttle: only process every Nth frame to avoid overwhelming the main
  // isolate with ML Kit calls.
  int _frameCounter = 0;
  static const _processEveryNthFrame = 8;

  bool get _allChecksPass =>
      _faceDetected && _faceInFrame && _lightingOk && _notBlurry;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    // Prefer the front camera for selfies.
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _faceService = FaceDetectionService();
    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    if (!mounted) return;

    _controller!.startImageStream(_onFrame);
    setState(() {});
  }

  void _onFrame(CameraImage image) {
    if (_isProcessingFrame || _isCapturing || !mounted) return;
    final controller = _controller;
    final service = _faceService;
    if (controller == null || service == null) return;
    _frameCounter++;
    if (_frameCounter % _processEveryNthFrame != 0) return;

    _isProcessingFrame = true;
    service
        .analyse(image, controller.description)
        .then(_updateValidation)
        .catchError((_) {}) // ignore transient frame-conversion errors
        .whenComplete(() => _isProcessingFrame = false);
  }

  void _updateValidation(FaceAnalysis? analysis) {
    if (!mounted || analysis == null) return;

    final face = analysis.faces.length == 1 ? analysis.faces.first : null;
    final inFrame = face != null && _isFaceInOval(face, analysis.imageSize);
    // "Not blurry" proxy: require at least 5 contour points detected.
    final notBlurry = face != null &&
        (face.contours[FaceContourType.face]?.points.length ?? 0) > 5;

    setState(() {
      _faceDetected = analysis.hasExactlyOneFace;
      _faceInFrame = inFrame;
      _lightingOk = analysis.brightnessOk;
      _notBlurry = notBlurry;
    });
  }

  /// Returns true if the face bounding box centre is inside a central oval
  /// region (roughly the alignment guide drawn on screen).
  bool _isFaceInOval(Face face, Size imageSize) {
    final bb = face.boundingBox;
    final faceCentreX = (bb.left + bb.right) / 2;
    final faceCentreY = (bb.top + bb.bottom) / 2;

    // Oval defined as the middle 60% horizontally, middle 70% vertically.
    final xMin = imageSize.width * 0.2;
    final xMax = imageSize.width * 0.8;
    final yMin = imageSize.height * 0.15;
    final yMax = imageSize.height * 0.85;

    return faceCentreX >= xMin &&
        faceCentreX <= xMax &&
        faceCentreY >= yMin &&
        faceCentreY <= yMax;
  }

  Future<void> _capture() async {
    if (!_allChecksPass || _isCapturing) return;
    // Setting this first makes _onFrame early-return immediately so no new
    // ML Kit analysis starts while we tear down the stream.
    setState(() => _isCapturing = true);

    try {
      // Stop feeding camera frames before taking a still photo. Streaming and
      // takePicture cannot run concurrently — doing so frees a native buffer
      // that an in-flight ML Kit analysis is still reading → native crash.
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      // Wait for any in-flight frame analysis to finish (it holds a reference
      // to the now-stopped stream's buffer). Bounded so we never hang.
      var guard = 0;
      while (_isProcessingFrame && guard < 60) {
        await Future.delayed(const Duration(milliseconds: 20));
        guard++;
      }
      // Small settle so the AVCaptureSession switches from streaming to photo.
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      final xFile = await _controller!.takePicture();
      final file = File(xFile.path);

      // Live-stream validation already confirmed exactly 1 face before capture
      // was enabled (_allChecksPass gate). Re-running analyseFile on the JPEG
      // fails on iOS because takePicture saves with EXIF orientation that
      // InputImage.fromFile ignores → ML Kit sees a rotated image → 0 faces.

      // Save attendance record using the GPS context passed from the previous
      // screen (the location streams have been disposed by now).
      final notifier = ref.read(attendanceControllerProvider.notifier);
      final args = (
        userId: widget.userId,
        latitude: widget.latitude,
        longitude: widget.longitude,
        distanceMeters: widget.distanceMeters,
        isInArea: widget.isInArea,
        selfieFile: file,
      );

      final saved = widget.attendanceType == AttendanceType.clockIn
          ? await notifier.clockIn(
              userId: args.userId,
              latitude: args.latitude,
              longitude: args.longitude,
              distanceMeters: args.distanceMeters,
              isInArea: args.isInArea,
              selfieFile: args.selfieFile,
            )
          : await notifier.clockOut(
              userId: args.userId,
              latitude: args.latitude,
              longitude: args.longitude,
              distanceMeters: args.distanceMeters,
              isInArea: args.isInArea,
              selfieFile: args.selfieFile,
            );

      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.faceSuccess,
        extra: {
          'attendanceType': widget.attendanceType,
          'selfieFile': file,
          'record': saved,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
      // Restart the preview stream so the user can retry (guarded — the
      // controller may be mid-teardown).
      try {
        if (_controller != null &&
            _controller!.value.isInitialized &&
            !_controller!.value.isStreamingImages) {
          await _controller!.startImageStream(_onFrame);
        }
      } catch (_) {/* ignore */}
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      if (controller.value.isStreamingImages) {
        controller.stopImageStream().catchError((_) {});
      }
      controller.dispose();
    }
    _faceService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !(_controller?.value.isInitialized ?? false)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.attendanceType == AttendanceType.clockIn
              ? 'Selfie — Clock In'
              : 'Selfie — Clock Out',
        ),
      ),
      body: Stack(
        children: [
          // Camera preview fills the screen.
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          // Oval alignment guide overlay.
          Positioned.fill(
            child: CustomPaint(
              painter: _OvalOverlayPainter(allValid: _allChecksPass),
            ),
          ),
          // Validation checklist at the top.
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _ValidationChecklist(
              faceDetected: _faceDetected,
              faceInFrame: _faceInFrame,
              lightingOk: _lightingOk,
              notBlurry: _notBlurry,
            ),
          ),
          // Capture button at the bottom.
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: _isCapturing
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.safetyOrange),
                    ),
                  )
                : PrimaryButton(
                    label: 'Ambil Foto',
                    icon: Icons.camera_alt_rounded,
                    onPressed: _allChecksPass ? _capture : null,
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Oval overlay painter
// ---------------------------------------------------------------------------

class _OvalOverlayPainter extends CustomPainter {
  const _OvalOverlayPainter({required this.allValid});
  final bool allValid;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayColor = Colors.black.withValues(alpha: 0.55);
    final borderColor =
        allValid ? AppColors.success : AppColors.safetyOrange;

    // Oval dimensions: centred, 70% of width, 65% of height.
    final ovalW = size.width * 0.70;
    final ovalH = size.height * 0.62;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: ovalW,
      height: ovalH,
    );

    // Draw the dark overlay everywhere except inside the oval.
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = overlayColor);

    // Draw the oval border.
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Guide text below the oval.
    final tp = TextPainter(
      text: TextSpan(
        text: allValid ? 'Posisi sempurna — siap difoto' : 'Posisikan wajah di dalam frame',
        style: TextStyle(
          color: allValid ? AppColors.success : Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 32);

    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        ovalRect.bottom + 12,
      ),
    );
  }

  @override
  bool shouldRepaint(_OvalOverlayPainter old) => old.allValid != allValid;
}

// ---------------------------------------------------------------------------
// Validation checklist widget
// ---------------------------------------------------------------------------

class _ValidationChecklist extends StatelessWidget {
  const _ValidationChecklist({
    required this.faceDetected,
    required this.faceInFrame,
    required this.lightingOk,
    required this.notBlurry,
  });

  final bool faceDetected;
  final bool faceInFrame;
  final bool lightingOk;
  final bool notBlurry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _CheckRow(ok: faceDetected, label: 'Wajah terdeteksi (1 wajah)'),
          _CheckRow(ok: faceInFrame, label: 'Wajah dalam frame oval'),
          _CheckRow(ok: lightingOk, label: 'Pencahayaan cukup'),
          _CheckRow(ok: notBlurry, label: 'Gambar tidak blur'),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.ok, required this.label});
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: ok ? AppColors.success : Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: ok ? Colors.white : Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
