import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
  final result = <String, dynamic>{};
  data.forEach((key, value) {
    if (value is Timestamp) {
      result[key] = value.toDate().toIso8601String();
    } else if (value is Map<String, dynamic>) {
      result[key] = _convertTimestamps(value);
    } else if (value is List) {
      result[key] = value
          .map(
            (e) => e is Map<String, dynamic>
                ? _convertTimestamps(e)
                : (e is Timestamp ? e.toDate().toIso8601String() : e),
          )
          .toList();
    } else {
      result[key] = value;
    }
  });
  return result;
}

class FirestoreService {
  static final instance = FirestoreService._();
  FirestoreService._();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // ---------------------------------------------------
  // PROJECTS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> projectsStream({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _db.collection('publicProjects');
    if (publishedOnly) {
      query = query.where('publicationStatus', isEqualTo: 'published');
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getProjectsOnce({bool publishedOnly = false}) async {
    Query<Map<String, dynamic>> query = _db.collection('publicProjects');
    if (publishedOnly) {
      query = query.where('publicationStatus', isEqualTo: 'published');
    }
    final snap = await query.get();
    return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
  }

  Future<void> setProject(String id, Map<String, dynamic> data) async {
    await _db.collection('publicProjects').doc(id).set(data);
  }

  Future<void> deleteProject(String id) async {
    await _db.collection('publicProjects').doc(id).delete();
  }

  // ---------------------------------------------------
  // SCHEDULE ITEMS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> scheduleStream({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _db.collection('publicScheduleItems');
    if (publishedOnly) {
      query = query.where('publicationStatus', isEqualTo: 'published');
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<void> setScheduleItem(String id, Map<String, dynamic> data) async {
    await _db.collection('publicScheduleItems').doc(id).set(data);
  }

  Future<void> deleteScheduleItem(String id) async {
    await _db.collection('publicScheduleItems').doc(id).delete();
  }

  // ---------------------------------------------------
  // BOOTHS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> boothsStream({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _db.collection('booths');
    if (publishedOnly) {
      query = query.where('publicationStatus', isEqualTo: 'published');
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<void> setBooth(String id, Map<String, dynamic> data) async {
    await _db.collection('booths').doc(id).set(data);
  }

  Future<void> deleteBooth(String id) async {
    await _db.collection('booths').doc(id).delete();
  }

  // ---------------------------------------------------
  // ANNOUNCEMENTS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> announcementsStream({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _db.collection('publicAnnouncements');
    if (publishedOnly) {
      query = query.where('publicationStatus', isEqualTo: 'published');
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<void> setAnnouncement(String id, Map<String, dynamic> data) async {
    await _db.collection('publicAnnouncements').doc(id).set(data);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('publicAnnouncements').doc(id).delete();
  }

  // ---------------------------------------------------
  // AWARD WINNERS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> awardWinnersStream({bool publishedOnly = false}) {
    Query<Map<String, dynamic>> query = _db.collection('publishedAwardWinners');
    if (publishedOnly) {
      query = query.where('publicationStatus', isEqualTo: 'published');
    }
    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<void> setAwardWinner(String id, Map<String, dynamic> data) async {
    await _db.collection('publishedAwardWinners').doc(id).set(data);
  }

  Future<void> deleteAwardWinner(String id) async {
    await _db.collection('publishedAwardWinners').doc(id).delete();
  }

  // ---------------------------------------------------
  // EVENTS
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> getEvent(String eventId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    return _convertTimestamps(doc.data()!);
  }

  Future<void> setEvent(String id, Map<String, dynamic> data) async {
    await _db.collection('events').doc(id).set(data);
  }

  // ---------------------------------------------------
  // SETTINGS
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> getSetting(String settingId) async {
    final doc = await _db.collection('settings').doc(settingId).get();
    if (!doc.exists) return null;
    return _convertTimestamps(doc.data()!);
  }

  Future<void> setSetting(String id, Map<String, dynamic> data) async {
    await _db.collection('settings').doc(id).set(data);
  }

  // ---------------------------------------------------
  // IMPORTS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> importsStream() {
    return _db.collection('imports').snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<void> setImport(String id, Map<String, dynamic> data) async {
    await _db.collection('imports').doc(id).set(data);
  }

  // ---------------------------------------------------
  // IMPORT SUBCOLLECTIONS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> scheduleCandidatesStream(String importId) {
    return _db
        .collection('imports')
        .doc(importId)
        .collection('scheduleCandidates')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> awardCandidatesStream(String importId) {
    return _db
        .collection('imports')
        .doc(importId)
        .collection('awardCandidates')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> privacySkipsStream(String importId) {
    return _db
        .collection('imports')
        .doc(importId)
        .collection('privacySkips')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> validationIssuesStream(String importId) {
    return _db
        .collection('imports')
        .doc(importId)
        .collection('validationIssues')
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  // ---------------------------------------------------
  // LECTURERS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> lecturersStream() {
    return _db.collection('lecturers').snapshots().map((snap) {
      return snap.docs.map((doc) => _convertTimestamps(doc.data())).toList();
    });
  }

  Future<Map<String, dynamic>?> getLecturer(String uid) async {
    final doc = await _db.collection('lecturers').doc(uid).get();
    if (!doc.exists) return null;
    return _convertTimestamps(doc.data()!);
  }

  Future<void> setLecturer(String uid, Map<String, dynamic> data) async {
    await _db.collection('lecturers').doc(uid).set(data);
  }

  Future<void> deleteLecturer(String uid) async {
    await _db.collection('lecturers').doc(uid).delete();
  }

  // ---------------------------------------------------
  // PROJECT LECTURER ASSIGNMENTS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> assignmentsStream() {
    return _db
        .collection('projectLecturerAssignments')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  Future<Map<String, dynamic>?> getAssignment(String id) async {
    final doc = await _db
        .collection('projectLecturerAssignments')
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return _convertTimestamps(doc.data()!);
  }

  Future<void> setAssignment(String id, Map<String, dynamic> data) async {
    await _db.collection('projectLecturerAssignments').doc(id).set(data);
  }

  // ---------------------------------------------------
  // STUDENT PROJECT VISITS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> visitsStream() {
    return _db
        .collection('studentProjectVisits')
        .orderBy('createdAt', descending: true)
        .limit(500)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  Future<Map<String, dynamic>?> getVisit(String id) async {
    final doc = await _db.collection('studentProjectVisits').doc(id).get();
    if (!doc.exists) return null;
    return _convertTimestamps(doc.data()!);
  }

  Future<void> setVisit(String id, Map<String, dynamic> data) async {
    await _db.collection('studentProjectVisits').doc(id).set(data);
  }

  // ---------------------------------------------------
  // AUDIT LOGS
  // ---------------------------------------------------
  Stream<List<Map<String, dynamic>>> auditLogsStream() {
    return _db
        .collection('auditLogs')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => _convertTimestamps(doc.data()))
              .toList();
        });
  }

  Future<void> setAuditLog(String id, Map<String, dynamic> data) async {
    await _db.collection('auditLogs').doc(id).set(data);
  }

  // ---------------------------------------------------
  // FILE UPLOAD (web-compatible via putData)
  // ---------------------------------------------------
  Future<String?> uploadFile(
    String localPath,
    String destinationPath,
    Uint8List? bytes,
  ) async {
    final ref = _storage.ref(destinationPath);
    final fileBytes = bytes ?? (await _readFileAsBytes(localPath));
    await ref.putData(fileBytes);
    return destinationPath;
  }

  Future<Uint8List> _readFileAsBytes(String localPath) async {
    // Fallback for mobile/desktop platforms
    final file = File(localPath);
    return await file.readAsBytes();
  }

  static Future<PlatformFile?> pickExcelFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }
}
