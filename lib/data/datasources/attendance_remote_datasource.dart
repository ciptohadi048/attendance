import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.attendanceCollection);

  Future<AttendanceRecordModel> save(
    AttendanceRecord record, {
    File? selfieFile,
  }) async {
    String? selfieUrl;

    if (selfieFile != null) {
      try {
        final path = AppConstants.selfieStoragePath(record.userId, record.date);
        final ref = _storage.ref(path);
        await ref.putFile(selfieFile);
        selfieUrl = await ref.getDownloadURL();
      } catch (_) {
        // Storage upload failed (e.g. rules not deployed yet).
        // Continue saving the attendance record without the selfie URL.
      }
    }

    final id = _uuid.v4();
    final model = AttendanceRecordModel(
      id: id,
      userId: record.userId,
      date: record.date,
      type: record.type,
      timestamp: record.timestamp,
      latitude: record.latitude,
      longitude: record.longitude,
      distanceFromOffice: record.distanceFromOffice,
      isInArea: record.isInArea,
      selfieUrl: selfieUrl,
      status: record.status,
    );

    await _col.doc(id).set(model.toMap());
    return model;
  }

  Future<List<AttendanceRecordModel>> todayRecords(String userId) async {
    final today = AttendanceRecord.today();
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: today)
        .orderBy('timestamp', descending: false)
        .get();
    return snap.docs.map(AttendanceRecordModel.fromFirestore).toList();
  }

  Stream<List<AttendanceRecordModel>> historyStream({
    required String userId,
    int limit = 30,
  }) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AttendanceRecordModel.fromFirestore).toList());
  }
}
