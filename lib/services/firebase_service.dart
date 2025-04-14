import 'package:cloud_firestore/cloud_firestore.dart';

// คลาสสำหรับจัดการการเชื่อมต่อกับ Firebase
class FirebaseService {
  // ตัวแปรสำหรับเชื่อมต่อกับ Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ดึงข้อมูล Collection ทั้งหมด
  Stream<QuerySnapshot> getCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // ดึงข้อมูล Document เฉพาะ
  Future<DocumentSnapshot> getDocument(
      String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).get();
  }

  // สร้าง Document ใหม่
  Future<DocumentReference> addDocument(
      String collectionPath, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).add(data);
  }

  // อัปเดต Document ที่มีอยู่
  Future<void> updateDocument(
      String collectionPath, String documentId, Map<String, dynamic> data) {
    return _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  // ลบ Document
  Future<void> deleteDocument(String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).delete();
  }
}
