// lib/models/member.dart
// โมเดลข้อมูลสมาชิก
class Member {
  // รหัสสมาชิก (ได้จาก Firestore)
  String? id;
  // ชื่อสมาชิก (บังคับ)
  String name;
  // เบอร์โทรศัพท์ (บังคับ)
  String phone;
  // อีเมล (ไม่บังคับ)
  String? email;
  // ที่อยู่ (ไม่บังคับ)
  String? address;
  // วันที่สมัครสมาชิก (บังคับ)
  DateTime joinDate;
  // คะแนนสะสม (ค่าเริ่มต้น 0)
  int point;

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
      id: documentId, // กำหนดรหัสจาก Firestore
      name: map['name'] ?? '', // ค่าเริ่มต้นถ้าไม่มีชื่อ
      phone: map['phone'] ?? '', // ค่าเริ่มต้นถ้าไม่มีเบอร์โทร
      email: map['email'], // อาจเป็น null
      address: map['address'], // อาจเป็น null
      joinDate: map['joinDate']?.toDate() ??
          DateTime.now(), // แปลง Timestamp หรือใช้เวลาปัจจุบัน
      point: map['point'] ?? 0, // ค่าเริ่มต้นถ้าไม่มีคะแนน
    );
  }

  // แปลงข้อมูลจาก Object เป็นรูปแบบที่ Firestore ใช้ได้
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email, // จะเป็น null ถ้าไม่มี
      'address': address, // จะเป็น null ถ้าไม่มี
      'joinDate': joinDate, // Firestore จะแปลงเป็น Timestamp อัตโนมัติ
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
