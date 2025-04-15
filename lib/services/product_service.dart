// lib/services/product_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_management_app/models/product.dart';
import 'package:shop_management_app/services/firebase_service.dart';

// คลาสสำหรับจัดการข้อมูลสินค้า
class ProductService extends ChangeNotifier {
  // อินสแตนซ์ FirebaseService
  final FirebaseService _firebaseService = FirebaseService();

  // ชื่อ Collection ใน Firestore
  final String _collection = 'products';

  // List สำหรับเก็บสินค้าทั้งหมด
  List<Product> _products = [];

  // Getter สำหรับดึงรายการสินค้า
  List<Product> get products => _products;

  // Constructor
  ProductService() {
    // ดึงข้อมูลสินค้าเมื่อเริ่มต้น
    _fetchProducts();
  }

  // ดึงข้อมูลสินค้าทั้งหมดแบบเรียลไทม์
  void _fetchProducts() {
    _firebaseService.getCollection(_collection).listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // เรียงตามชื่อ
      _products.sort((a, b) => a.name.compareTo(b.name));

      // แจ้งการเปลี่ยนแปลง
      notifyListeners();
    });
  }

  // ดึงข้อมูลสินค้าตาม ID
  Future<Product?> getProduct(String id) async {
    final doc = await _firebaseService.getDocument(_collection, id);
    if (doc.exists) {
      return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // เพิ่มสินค้าใหม่
  Future<void> addProduct(Product product, {String? imageUrl}) async {
    // รวม URL รูปภาพถ้ามี
    if (imageUrl != null && imageUrl.isNotEmpty) {
      product = product.copyWith(imageUrl: imageUrl);
    }

    await _firebaseService.addDocument(_collection, product.toMap());
  }

  // อัปเดตข้อมูลสินค้า
  Future<void> updateProduct(Product product, {String? imageUrl}) async {
    if (product.id != null) {
      // รวม URL รูปภาพถ้ามี
      if (imageUrl != null && imageUrl.isNotEmpty) {
        product = product.copyWith(imageUrl: imageUrl);
      }

      await _firebaseService.updateDocument(
          _collection, product.id!, product.toMap());
    }
  }

  // ลบสินค้า
  Future<void> deleteProduct(String id) async {
    await _firebaseService.deleteDocument(_collection, id);
  }

  // อัปเดตสต็อกสินค้า
  Future<void> updateStock(String productId, int amount) async {
    final product = await getProduct(productId);
    if (product != null) {
      product.stock += amount;
      if (product.stock < 0) product.stock = 0; // ป้องกันสต็อกติดลบ
      await updateProduct(product);
    }
  }

  // กรองสินค้าตามหมวดหมู่
  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // ดึงรายการหมวดหมู่ทั้งหมด
  List<String> getAllCategories() {
    final categories =
        _products.map((product) => product.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // ตรวจสอบสต็อกสินค้า
  bool hasEnoughStock(String productId, int quantity) {
    try {
      final product =
          _products.firstWhere((product) => product.id == productId);
      return product.stock >= quantity;
    } catch (e) {
      return false;
    }
  }
}
