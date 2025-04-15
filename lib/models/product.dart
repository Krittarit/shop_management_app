// lib/models/product.dart
// โมเดลข้อมูลสินค้า
class Product {
  // รหัสสินค้า (ได้จาก Firestore)
  String? id;
  // ชื่อสินค้า (บังคับ)
  String name;
  // ราคาสินค้า (บังคับ)
  double price;
  // จำนวนสินค้าในคลัง (บังคับ)
  int stock;
  // URL รูปภาพสินค้า (ไม่บังคับ)
  String? imageUrl;
  // รายละเอียดสินค้า (ไม่บังคับ)
  String? description;
  // หมวดหมู่สินค้า (บังคับ)
  String category;

  // Constructor
  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    required this.category,
  });

  // แปลงข้อมูลจาก Firestore มาเป็น Object
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId, // กำหนดรหัสจาก Firestore
      name: map['name'] ?? '', // ค่าเริ่มต้นถ้าไม่มีชื่อ
      price: (map['price'] ?? 0).toDouble(), // แปลงเป็น double
      stock: map['stock'] ?? 0, // ค่าเริ่มต้นถ้าไม่มีสต็อก
      imageUrl: map['imageUrl'], // อาจเป็น null
      description: map['description'], // อาจเป็น null
      category:
          map['category'] ?? 'ไม่มีหมวดหมู่', // ค่าเริ่มต้นถ้าไม่มีหมวดหมู่
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl, // จะเป็น null ถ้าไม่มี
      'description': description, // จะเป็น null ถ้าไม่มี
      'category': category,
    };
  }

  // สร้าง Product ใหม่โดยเพิ่มข้อมูลบางส่วน
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? description,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}
