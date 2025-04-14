import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_management_app/models/sale.dart';
import 'package:shop_management_app/services/firebase_service.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:shop_management_app/services/member_service.dart';

// คลาสสำหรับจัดการข้อมูลการขาย
class SaleService extends ChangeNotifier {
  // ตัวแปรสำหรับเชื่อมต่อกับ Firebase
  final FirebaseService _firebaseService = FirebaseService();

  // คอลเลกชันใน Firestore
  final String _collection = 'sales';

  // รายการการขายทั้งหมด
  List<Sale> _sales = [];

  // getter สำหรับดึงรายการการขาย
  List<Sale> get sales => _sales;

  // รายการสินค้าที่กำลังจะขาย (สำหรับหน้าบันทึกการขาย)
  List<SaleItem> _currentSaleItems = [];

  // getter สำหรับดึงรายการสินค้าที่กำลังจะขาย
  List<SaleItem> get currentSaleItems => _currentSaleItems;

  // constructor
  SaleService() {
    // ดึงข้อมูลการขายทั้งหมดเมื่อเริ่มต้น service
    _fetchSales();
  }

  // ดึงข้อมูลการขายทั้งหมด
  // ใน sale_service.dart
  void _fetchSales() {
    try {
      _firebaseService.getCollection(_collection).listen((snapshot) {
        _sales = snapshot.docs.map((doc) {
          return Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        _sales.sort((a, b) => b.saleDate.compareTo(a.saleDate));
        notifyListeners();
      }, onError: (e) {
        // แจ้ง error ผ่าน UI หรือ log
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

  // เพิ่มสินค้าในรายการที่กำลังจะขาย
  void addItemToCurrentSale(SaleItem item) {
    // ตรวจสอบว่ามีสินค้านี้ในรายการหรือไม่
    int index =
        _currentSaleItems.indexWhere((i) => i.productId == item.productId);

    if (index != -1) {
      // ถ้ามีแล้ว ให้เพิ่มจำนวน
      _currentSaleItems[index] = SaleItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: _currentSaleItems[index].quantity + item.quantity,
      );
    } else {
      // ถ้ายังไม่มี ให้เพิ่มในรายการ
      _currentSaleItems.add(item);
    }

    notifyListeners();
  }

  // ลบสินค้าออกจากรายการที่กำลังจะขาย
  void removeItemFromCurrentSale(int index) {
    if (index >= 0 && index < _currentSaleItems.length) {
      _currentSaleItems.removeAt(index);
      notifyListeners();
    }
  }

  // อัปเดตจำนวนสินค้าในรายการที่กำลังจะขาย
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

  // ล้างรายการสินค้าที่กำลังจะขาย
  void clearCurrentSale() {
    _currentSaleItems.clear();
    notifyListeners();
  }

  // คำนวณยอดรวมของรายการที่กำลังจะขาย
  double calculateTotal() {
    return _currentSaleItems.fold(0, (sum, item) => sum + item.total);
  }

  // บันทึกการขาย
  Future<void> saveSale(Sale sale, ProductService productService,
      MemberService memberService) async {
    // บันทึกการขาย
    final docRef =
        await _firebaseService.addDocument(_collection, sale.toMap());

    // อัปเดตสต็อกสินค้า
    for (var item in sale.items) {
      await productService.updateStock(item.productId, -item.quantity);
    }

    // อัปเดตคะแนนสะสมของสมาชิก (ถ้ามี)
    if (sale.memberId != null) {
      // สมมติให้ 1 บาท = 1 คะแนน
      int points = sale.totalAmount.round();
      await memberService.updatePoints(sale.memberId!, points);
    }

    // ล้างรายการสินค้าที่กำลังจะขาย
    clearCurrentSale();
  }

  // ดึงรายการขายตามช่วงวันที่
  List<Sale> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _sales.where((sale) {
      return sale.saleDate.isAfter(startDate) &&
          sale.saleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // ดึงรายการขายของสมาชิก
  List<Sale> getSalesByMemberId(String memberId) {
    return _sales.where((sale) => sale.memberId == memberId).toList();
  }

  // คำนวณยอดขายทั้งหมด
  double calculateTotalSales([List<Sale>? salesList]) {
    final list = salesList ?? _sales;
    return list.fold(0, (sum, sale) => sum + sale.totalAmount);
  }
}
