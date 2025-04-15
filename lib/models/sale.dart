// lib/models/sale.dart
// โมเดลข้อมูลรายการสินค้าในการขาย
class SaleItem {
  // รหัสสินค้า
  String productId;
  // ชื่อสินค้า
  String productName;
  // ราคาต่อชิ้น
  double price;
  // จำนวนที่ซื้อ
  int quantity;
  // ราคารวมของรายการนี้ (คำนวณจาก price * quantity)
  double get total => price * quantity;

  // Constructor
  SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  // แปลงข้อมูลจาก Firestore มาเป็น Object
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] ?? '', // ค่าเริ่มต้นถ้าไม่มี
      productName: map['productName'] ?? '', // ค่าเริ่มต้นถ้าไม่มี
      price: (map['price'] ?? 0).toDouble(), // แปลงเป็น double
      quantity: map['quantity'] ?? 0, // ค่าเริ่มต้นถ้าไม่มี
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total, // รวมราคารวมไว้ใน Map
    };
  }
}

// โมเดลข้อมูลการขาย
class Sale {
  // รหัสการขาย (ได้จาก Firestore)
  String? id;
  // วันที่ขาย
  DateTime saleDate;
  // รหัสสมาชิก (ถ้ามี)
  String? memberId;
  // ชื่อสมาชิก (ถ้ามี)
  String? memberName;
  // รายการสินค้าที่ขาย
  List<SaleItem> items;
  // ยอดรวมทั้งหมด
  double totalAmount;
  // วิธีการชำระเงิน (เงินสด, โอน, บัตรเครดิต)
  String paymentMethod;

  // Constructor
  Sale({
    this.id,
    required this.saleDate,
    this.memberId,
    this.memberName,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
  });

  // แปลงข้อมูลจาก Firestore มาเป็น Object
  factory Sale.fromMap(Map<String, dynamic> map, String documentId) {
    // สร้าง List ของ SaleItem จากข้อมูล items
    List<SaleItem> items = [];
    if (map['items'] != null) {
      for (var item in map['items']) {
        items.add(SaleItem.fromMap(item));
      }
    }

    return Sale(
      id: documentId, // กำหนดรหัสจาก Firestore
      saleDate: map['saleDate']?.toDate() ??
          DateTime.now(), // แปลง Timestamp หรือใช้เวลาปัจจุบัน
      memberId: map['memberId'], // อาจเป็น null
      memberName: map['memberName'], // อาจเป็น null
      items: items, // รายการสินค้า
      totalAmount: (map['totalAmount'] ?? 0).toDouble(), // แปลงเป็น double
      paymentMethod: map['paymentMethod'] ?? 'เงินสด', // ค่าเริ่มต้นถ้าไม่มี
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'saleDate': saleDate, // Firestore จะแปลงเป็น Timestamp
      'memberId': memberId, // อาจเป็น null
      'memberName': memberName, // อาจเป็น null
      'items': items
          .map((item) => item.toMap())
          .toList(), // แปลง SaleItem เป็น List<Map>
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }
}
