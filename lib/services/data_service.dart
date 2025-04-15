// lib/services/data_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DataService extends ChangeNotifier {
  // อินสแตนซ์สำหรับเชื่อมต่อ Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ส่งออกข้อมูลสมาชิกเป็น JSON
  Future<String> exportMembers() async {
    final snapshot = await _firestore.collection('members').get();
    final members = snapshot.docs.map((doc) {
      final data = doc.data();
      // แปลง Timestamp เป็น ISO string
      if (data['joinDate'] is Timestamp) {
        data['joinDate'] =
            (data['joinDate'] as Timestamp).toDate().toIso8601String();
      }
      data['id'] = doc.id;
      return data;
    }).toList();

    return jsonEncode(members);
  }

  // ส่งออกข้อมูลสินค้าเป็น JSON
  Future<String> exportProducts() async {
    final snapshot = await _firestore.collection('products').get();
    final products = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    return jsonEncode(products);
  }

  // ส่งออกข้อมูลการขายเป็น JSON
  Future<String> exportSales() async {
    final snapshot = await _firestore.collection('sales').get();
    final sales = snapshot.docs.map((doc) {
      final data = doc.data();
      // แปลง Timestamp เป็น ISO string
      if (data['saleDate'] is Timestamp) {
        data['saleDate'] =
            (data['saleDate'] as Timestamp).toDate().toIso8601String();
      }
      data['id'] = doc.id;
      return data;
    }).toList();

    return jsonEncode(sales);
  }

  // นำเข้า JSON ลง Collection
  Future<bool> importCollection(String collection, String jsonContent) async {
    try {
      // แปลง JSON เป็น List<Map>
      final List<dynamic> items = jsonDecode(jsonContent);
      final batch = _firestore.batch();

      // ลบข้อมูลเดิมทั้งหมด
      final existingDocs = await _firestore.collection(collection).get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // เพิ่มข้อมูลใหม่
      for (var item in items) {
        final docId = item['id'];
        if (docId == null) {
          throw Exception('Missing id in item: $item');
        }
        item.remove('id');

        // แปลงวันที่เป็น Timestamp
        if (collection == 'members' && item['joinDate'] is String) {
          item['joinDate'] =
              Timestamp.fromDate(DateTime.parse(item['joinDate']));
        }
        if (collection == 'sales' && item['saleDate'] is String) {
          item['saleDate'] =
              Timestamp.fromDate(DateTime.parse(item['saleDate']));
        }

        final docRef = _firestore.collection(collection).doc(docId);
        batch.set(docRef, item);
      }

      // ทำ Batch Operation
      await batch.commit();
      // แจ้งการเปลี่ยนแปลง
      notifyListeners();
      return true;
    } catch (e) {
      // พิมพ์ข้อผิดพลาด
      print('Error importing $collection: $e');
      return false;
    }
  }
}
