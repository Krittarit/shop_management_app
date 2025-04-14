// โมเดลข้อมูลรายการสินค้าในการขาย
class SaleItem {
  String productId; // รหัสสินค้า
  String productName; // ชื่อสินค้า
  double price; // ราคาต่อชิ้น
  int quantity; // จำนวนที่ซื้อ
  double get total => price * quantity; // ราคารวมของรายการนี้

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
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}

// โมเดลข้อมูลการขาย
class Sale {
  String? id; // รหัสการขาย (ได้จาก Firestore)
  DateTime saleDate; // วันที่ขาย
  String? memberId; // รหัสสมาชิก (ถ้ามี)
  String? memberName; // ชื่อสมาชิก (ถ้ามี)
  List<SaleItem> items; // รายการสินค้าที่ขาย
  double totalAmount; // ยอดรวมทั้งหมด
  String paymentMethod; // วิธีการชำระเงิน (เงินสด, โอน, บัตรเครดิต)

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
    List<SaleItem> items = [];
    if (map['items'] != null) {
      for (var item in map['items']) {
        items.add(SaleItem.fromMap(item));
      }
    }

    return Sale(
      id: documentId,
      saleDate: map['saleDate']?.toDate() ?? DateTime.now(),
      memberId: map['memberId'],
      memberName: map['memberName'],
      items: items,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'เงินสด',
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'saleDate': saleDate,
      'memberId': memberId,
      'memberName': memberName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
    };
  }
}
