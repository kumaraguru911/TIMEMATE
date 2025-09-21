import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // For ClassItem model

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save timetable for user
  Future<void> saveTimetable(String userId, List<ClassItem> classes) async {
    final data = classes.map((e) => e.toJson()).toList();
    await _db.collection('users').doc(userId).set({'timetable': data});
  }

  // Load timetable for user
  Future<List<ClassItem>> loadTimetable(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists && doc.data()?['timetable'] != null) {
      final List<dynamic> data = doc.data()!['timetable'];
      return data.map((e) => ClassItem.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return [];
  }
}
