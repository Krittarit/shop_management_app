import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_management_app/models/product.dart';
import 'package:shop_management_app/services/firebase_service.dart';

// คลาสสำหรับจัดการข้อมูลสินค้า
class ProductService extends ChangeNotifier {
  // ตัวแปรสำหรับเชื่อมต่อกับ Firebase
  final FirebaseService _firebaseService = FirebaseService();

  // คอลเลกชันใน Firestore
  final String _collection = 'products';

  // รายการสินค้าทั้งหมด
  List<Product> _products = [];

  // getter สำหรับดึงรายการสินค้า
  List<Product> get products => _products;

  // constructor
  ProductService() {
    // ดึงข้อมูลสินค้าทั้งหมดเมื่อเริ่มต้น service
    _fetchProducts();
  }

  // ดึงข้อมูลสินค้าทั้งหมด
  void _fetchProducts() {
    _firebaseService.getCollection(_collection).listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // เรียงตามชื่อ
      _products.sort((a, b) => a.name.compareTo(b.name));

      // แจ้งเตือนว่าข้อมูลมีการเปลี่ยนแปลง
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

  // เพิ่มสินค้าใหม่ - รับ URL รูปภาพแทนไฟล์
  Future<void> addProduct(Product product, {String? imageUrl}) async {
    // หากมีการระบุ URL รูปภาพ ให้ใช้ URL นั้น
    if (imageUrl != null && imageUrl.isNotEmpty) {
      product = product.copyWith(imageUrl: imageUrl);
    }

    await _firebaseService.addDocument(_collection, product.toMap());
  }

  // อัปเดตข้อมูลสินค้า - รับ URL รูปภาพใหม่แทนไฟล์
  Future<void> updateProduct(Product product, {String? imageUrl}) async {
    if (product.id != null) {
      // หากมีการระบุ URL รูปภาพใหม่ ให้อัปเดต
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

  // อัปเดตจำนวนสินค้าในคลัง
  Future<void> updateStock(String productId, int amount) async {
    final product = await getProduct(productId);
    if (product != null) {
      product.stock += amount;
      if (product.stock < 0) product.stock = 0;
      await updateProduct(product);
    }
  }

  // ดึงรายการสินค้าตามหมวดหมู่
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

  // ตรวจสอบว่ามีสินค้าเพียงพอหรือไม่
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
