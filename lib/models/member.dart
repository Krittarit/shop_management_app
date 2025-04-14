// โมเดลข้อมูลสมาชิก
class Member {
  String? id; // รหัสสมาชิก (ได้จาก Firestore)
  String name; // ชื่อสมาชิก
  String phone; // เบอร์โทรศัพท์
  String? email; // อีเมล (ไม่บังคับ)
  String? address; // ที่อยู่ (ไม่บังคับ)
  DateTime joinDate; // วันที่สมัครสมาชิก
  int point; // คะแนนสะสม

  // Constructor
  Member({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.joinDate,
    this.point = 0,
  });

  // แปลงข้อมูลจาก Firestore มาเป็น Object
  factory Member.fromMap(Map<String, dynamic> map, String documentId) {
    return Member(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
      joinDate: map['joinDate']?.toDate() ?? DateTime.now(),
      point: map['point'] ?? 0,
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'joinDate': joinDate,
      'point': point,
    };
  }

  // สร้าง Member ใหม่โดยเพิ่มข้อมูลบางส่วน
  Member copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    DateTime? joinDate,
    int? point,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      joinDate: joinDate ?? this.joinDate,
      point: point ?? this.point,
    );
  }
}
