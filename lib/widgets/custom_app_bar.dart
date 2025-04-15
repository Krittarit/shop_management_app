// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

// Widget สำหรับสร้าง AppBar แบบกำหนดเอง
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // หัวข้อของ AppBar
  final List<Widget>? actions; // ปุ่มหรือ Widget ด้านขวา (ถ้ามี)

  // Constructor
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions ?? [], // ใช้ List ว่างถ้า actions เป็น null
      elevation: 4, // เพิ่มเงาเล็กน้อย
      centerTitle: true, // จัดหัวข้อให้กึ่งกลาง
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
