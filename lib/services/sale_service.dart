// lib/services/sale_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_management_app/models/sale.dart';
import 'package:shop_management_app/services/firebase_service.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:shop_management_app/services/member_service.dart';

// คลาสสำหรับจัดการข้อมูลการขาย
class SaleService extends ChangeNotifier {
  // อินสแตนซ์ FirebaseService
  final FirebaseService _firebaseService = FirebaseService();

  // ชื่อ Collection ใน Firestore
  final String _collection = 'sales';

  // List สำหรับเก็บการขายทั้งหมด
  List<Sale> _sales = [];

  // List สำหรับเก็บตะกร้าสินค้าชั่วคราว
  List<SaleItem> _currentSaleItems = [];

  // Getter สำหรับการขาย
  List<Sale> get sales => _sales;

  // Getter สำหรับตะกร้า
  List<SaleItem> get currentSaleItems => _currentSaleItems;

  // Constructor
  SaleService() {
    // ดึงข้อมูลการขายเมื่อเริ่มต้น
    _fetchSales();
  }

  // ดึงข้อมูลการขายทั้งหมดแบบเรียลไทม์
  void _fetchSales() {
    try {
      _firebaseService.getCollection(_collection).listen((snapshot) {
        _sales = snapshot.docs.map((doc) {
          return Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        // เรียงจากใหม่ไปเก่า
        _sales.sort((a, b) => b.saleDate.compareTo(a.saleDate));
        // แจ้งการเปลี่ยนแปลง
        notifyListeners();
      }, onError: (e) {
        print('Error fetching sales: $e');
      });
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  // ดึงข้อมูลการขายตาม ID
  Future<Sale?> getSale(String id) async {
    final doc = await _firebaseService.getDocument(_collection, id);
    if (doc.exists) {
      return Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // เพิ่มสินค้าลงตะกร้า
  void addItemToCurrentSale(SaleItem item) {
    // ตรวจสอบว่ามีสินค้านี้ในตะกร้าแล้วหรือไม่
    int index =
        _currentSaleItems.indexWhere((i) => i.productId == item.productId);

    if (index != -1) {
      // ถ้ามี เพิ่มจำนวน
      _currentSaleItems[index] = SaleItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: _currentSaleItems[index].quantity + item.quantity,
      );
    } else {
      // ถ้าไม่มี เพิ่มใหม่
      _currentSaleItems.add(item);
    }

    // แจ้งการเปลี่ยนแปลง
    notifyListeners();
  }

  // ลบสินค้าจากตะกร้า
  void removeItemFromCurrentSale(int index) {
    if (index >= 0 && index < _currentSaleItems.length) {
      _currentSaleItems.removeAt(index);
      notifyListeners();
    }
  }

  // อัปเดตจำนวนสินค้าในตะกร้า
  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < _currentSaleItems.length && quantity > 0) {
      _currentSaleItems[index] = SaleItem(
        productId: _currentSaleItems[index].productId,
        productName: _currentSaleItems[index].productName,
        price: _currentSaleItems[index].price,
        quantity: quantity,
      );
      notifyListeners();
    }
  }

  // ล้างตะกร้า
  void clearCurrentSale() {
    _currentSaleItems.clear();
    notifyListeners();
  }

  // คำนวณยอดรวมตะกร้า
  double calculateTotal() {
    return _currentSaleItems.fold(0, (sum, item) => sum + item.total);
  }

  // บันทึกการขาย
  Future<void> saveSale(Sale sale, ProductService productService,
      MemberService memberService) async {
    // บันทึกการขาย
    final docRef =
        await _firebaseService.addDocument(_collection, sale.toMap());

    // อัปเดตสต็อก
    for (var item in sale.items) {
      await productService.updateStock(item.productId, -item.quantity);
    }

    // อัปเดตคะแนนสมาชิก (ถ้ามี)
    if (sale.memberId != null) {
      // 1 บาท = 1 คะแนน
      int points = sale.totalAmount.round();
      await memberService.updatePoints(sale.memberId!, points);
    }

    // ล้างตะกร้า
    clearCurrentSale();
  }

  // กรองการขายตามวันที่
  List<Sale> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) {
      return sale.saleDate.isAfter(startDate) &&
          sale.saleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // กรองการขายตามสมาชิก
  List<Sale> getSalesByMemberId(String memberId) {
    return _sales.where((sale) => sale.memberId == memberId).toList();
  }

  // คำนวณยอดรวมการขาย
  double calculateTotalSales([List<Sale>? salesList]) {
    final list = salesList ?? _sales;
    return list.fold(0, (sum, sale) => sum + sale.totalAmount);
  }
}
