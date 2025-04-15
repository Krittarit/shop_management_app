// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// คลาสสำหรับจัดการการเชื่อมต่อกับ Firebase Firestore
class FirebaseService {
  // อินสแตนซ์สำหรับเชื่อมต่อ Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ดึงข้อมูล Collection ทั้งหมดแบบเรียลไทม์
  Stream<QuerySnapshot> getCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // ดึงข้อมูล Document เฉพาะ
  Future<DocumentSnapshot> getDocument(
      String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).get();
  }

  // เพิ่ม Document ใหม่
  Future<DocumentReference> addDocument(
      String collectionPath, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).add(data);
  }

  // อัปเดต Document
  Future<void> updateDocument(
      String collectionPath, String documentId, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  // ลบ Document
  Future<void> deleteDocument(String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).delete();
  }
}
