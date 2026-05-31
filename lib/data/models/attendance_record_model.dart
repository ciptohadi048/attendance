import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.type,
    required super.timestamp,
    required super.latitude,
    required super.longitude,
    required super.distanceFromOffice,
    required super.isInArea,
    super.selfieUrl,
    super.status,
  });

  factory AttendanceRecordModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return AttendanceRecordModel(
      id: doc.id,
      userId: d['userId'] as String,
      date: d['date'] as String,
      type: AttendanceType.values.firstWhere(
        (e) => e.name == d['type'],
        orElse: () => AttendanceType.clockIn,
      ),
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      latitude: (d['latitude'] as num).toDouble(),
      longitude: (d['longitude'] as num).toDouble(),
      distanceFromOffice: (d['distanceFromOffice'] as num).toDouble(),
      isInArea: d['isInArea'] as bool? ?? false,
      selfieUrl: d['selfieUrl'] as String?,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => AttendanceStatus.hadir,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'date': date,
        'type': type.name,
        'timestamp': Timestamp.fromDate(timestamp),
        'latitude': latitude,
        'longitude': longitude,
        'distanceFromOffice': distanceFromOffice,
        'isInArea': isInArea,
        'selfieUrl': selfieUrl,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
