// โมเดลข้อมูลสินค้า
class Product {
  String? id; // รหัสสินค้า (ได้จาก Firestore)
  String name; // ชื่อสินค้า
  double price; // ราคาสินค้า
  int stock; // จำนวนสินค้าในคลัง
  String? imageUrl; // URL รูปภาพสินค้า (ไม่บังคับ)
  String? description; // รายละเอียดสินค้า (ไม่บังคับ)
  String category; // หมวดหมู่สินค้า

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
      id: documentId,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'],
      description: map['description'],
      category: map['category'] ?? 'ไม่มีหมวดหมู่',
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
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
