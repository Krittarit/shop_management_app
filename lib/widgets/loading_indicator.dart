// lib/widgets/loading_indicator.dart
import 'package:flutter/material.dart';

// Widget สำหรับแสดงตัวบ่งชี้การโหลด
class LoadingIndicator extends StatelessWidget {
  // ข้อความที่แสดงด้านล่างตัวบ่งชี้
  final String message;
  // สีของตัวบ่งชี้ (ถ้าไม่ระบุ ใช้สีจาก Theme)
  final Color? color;

  // Constructor
  const LoadingIndicator({
    super.key,
    this.message = 'กำลังโหลด...', // ค่าเริ่มต้นข้อความ
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // จัดวางตัวบ่งชี้และข้อความให้อยู่กึ่งกลาง
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ตัวบ่งชี้การโหลด
          CircularProgressIndicator(
            color: color ??
                Theme.of(context)
                    .colorScheme
                    .primary, // ใช้สีที่กำหนดหรือจาก Theme
          ),
          // ช่องว่างระหว่างตัวบ่งชี้และข้อความ
          const SizedBox(height: 16),
          // ข้อความกำกับ
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  Theme.of(context).colorScheme.onSurface, // สีข้อความจาก Theme
            ),
          ),
        ],
      ),
    );
  }
}
