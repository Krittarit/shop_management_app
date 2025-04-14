import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_management_app/models/member.dart';
import 'package:shop_management_app/services/firebase_service.dart';

// คลาสสำหรับจัดการข้อมูลสมาชิก
class MemberService extends ChangeNotifier {
  // ตัวแปรสำหรับเชื่อมต่อกับ Firebase
  final FirebaseService _firebaseService = FirebaseService();

  // คอลเลกชันใน Firestore
  final String _collection = 'members';

  // รายการสมาชิกทั้งหมด
  List<Member> _members = [];

  // getter สำหรับดึงรายการสมาชิก
  List<Member> get members => _members;

  // constructor
  MemberService() {
    // ดึงข้อมูลสมาชิกทั้งหมดเมื่อเริ่มต้น service
    _fetchMembers();
  }

  // ดึงข้อมูลสมาชิกทั้งหมด
  void _fetchMembers() {
    _firebaseService.getCollection(_collection).listen((snapshot) {
      _members = snapshot.docs.map((doc) {
        return Member.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // เรียงตามชื่อ
      _members.sort((a, b) => a.name.compareTo(b.name));

      // แจ้งเตือนว่าข้อมูลมีการเปลี่ยนแปลง
      notifyListeners();
    });
  }

  // ดึงข้อมูลสมาชิกตาม ID
  Future<Member?> getMember(String id) async {
    final doc = await _firebaseService.getDocument(_collection, id);
    if (doc.exists) {
      return Member.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // เพิ่มสมาชิกใหม่
  Future<void> addMember(Member member) async {
    await _firebaseService.addDocument(_collection, member.toMap());
  }

  // อัปเดตข้อมูลสมาชิก
  Future<void> updateMember(Member member) async {
    if (member.id != null) {
      await _firebaseService.updateDocument(
          _collection, member.id!, member.toMap());
    }
  }

  // ลบสมาชิก
  Future<void> deleteMember(String id) async {
    await _firebaseService.deleteDocument(_collection, id);
  }

  // อัปเดตคะแนนสะสม
  Future<void> updatePoints(String memberId, int points) async {
    final member = await getMember(memberId);
    if (member != null) {
      member.point += points;
      await updateMember(member);
    }
  }

  // ค้นหาสมาชิกจากเบอร์โทรศัพท์
  Member? findMemberByPhone(String phone) {
    try {
      return _members.firstWhere((member) => member.phone == phone);
    } catch (e) {
      return null;
    }
  }
}
