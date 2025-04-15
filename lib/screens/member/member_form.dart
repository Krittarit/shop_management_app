// lib/screens/member/member_form.dart
import 'package:flutter/material.dart';
import 'package:shop_management_app/models/member.dart';

// หน้าจอฟอร์มเพิ่ม/แก้ไขข้อมูลสมาชิก
class MemberFormScreen extends StatefulWidget {
  final Member? member; // สมาชิกที่ต้องการแก้ไข (null = เพิ่มใหม่)
  final Function(Member) onSave; // Callback เมื่อบันทึกข้อมูล

  const MemberFormScreen({
    super.key,
    this.member,
    required this.onSave,
  });

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  // ตัวแปรสำหรับจัดการฟอร์ม
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  int _point = 0; // คะแนนสะสม (ใช้เมื่อแก้ไข)

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการแก้ไข นำข้อมูลเดิมมาแสดง
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _phoneController.text = widget.member!.phone;
      _emailController.text = widget.member!.email ?? '';
      _addressController.text = widget.member!.address ?? '';
      _point = widget.member!.point;
    }
  }

  // ล้างทรัพยากร
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // หัวข้อฟอร์ม
              Text(
                widget.member == null ? 'เพิ่มสมาชิกใหม่' : 'แก้ไขข้อมูลสมาชิก',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ช่องกรอกชื่อ-นามสกุล (บังคับ)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ-นามสกุล *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อ-นามสกุล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ช่องกรอกเบอร์โทรศัพท์ (บังคับ)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์ *',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกเบอร์โทรศัพท์';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ช่องกรอกอีเมล (ไม่บังคับ)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'อีเมล (ไม่บังคับ)',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // ช่องกรอกที่อยู่ (ไม่บังคับ)
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'ที่อยู่ (ไม่บังคับ)',
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // แสดงและจัดการคะแนนสะสม (เฉพาะการแก้ไข)
              if (widget.member != null) ...[
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text('คะแนนสะสม:'),
                    const SizedBox(width: 8),
                    Text(
                      '$_point คะแนน',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // ปุ่มลดคะแนน
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        setState(() {
                          if (_point > 0) _point--;
                        });
                      },
                    ),
                    // ปุ่มเพิ่มคะแนน
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        setState(() {
                          _point++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ปุ่มดำเนินการ
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ปุ่มยกเลิก
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  // ปุ่มบันทึก
                  ElevatedButton(
                    onPressed: _saveMember,
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันบันทึกข้อมูลสมาชิก
  void _saveMember() {
    // ตรวจสอบความถูกต้องของฟอร์ม
    if (_formKey.currentState!.validate()) {
      final Member member;

      // กรณีแก้ไข
      if (widget.member != null) {
        member = widget.member!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          point: _point,
        );
      }
      // กรณีเพิ่มใหม่
      else {
        member = Member(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          joinDate: DateTime.now(),
          point: 0,
        );
      }

      // ส่งข้อมูลไปบันทึก
      widget.onSave(member);
    }
  }
}
