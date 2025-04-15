// lib/widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:shop_management_app/screens/report/sales_report_screen.dart';
import 'package:shop_management_app/services/theme_provider.dart';

// Widget สำหรับสร้าง Drawer แบบกำหนดเอง
class CustomDrawer extends StatelessWidget {
  // Callback สำหรับเปลี่ยน Theme
  final Function(ThemeType) onThemeChanged;
  // Theme ปัจจุบันของแอป
  final ThemeType currentTheme;

  // Constructor
  const CustomDrawer({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    // สร้าง Drawer ด้วย ListView เพื่อแสดงเมนูนำทาง
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // ลบช่องว่างด้านบน
        children: [
          // ส่วนหัวของ Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary, // สีพื้นหลังจาก Theme
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // โลโก้แอป
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.store,
                    color: Colors.blue,
                    size: 35,
                  ),
                ),
                SizedBox(height: 10),
                // ชื่อแอป
                Text(
                  'KittaShop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                // คำบรรยาย
                Text(
                  'จัดการร้านค้าของคุณ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // เมนูหน้าหลัก
          ListTile(
            leading: const Icon(Icons.dashboard), // ไอคอน
            title: const Text('หน้าหลัก'),
            onTap: () {
              // นำทางไปหน้าหลัก แทนที่หน้าปัจจุบัน
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          // เมนูจัดการสมาชิก
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('จัดการสมาชิก'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              Navigator.pushNamed(context, '/members'); // นำทางไปหน้าสมาชิก
            },
          ),
          // เมนูจัดการสินค้า
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('จัดการสินค้า'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/products'); // นำทางไปหน้าสินค้า
            },
          ),
          // เมนูจัดการการขาย (เมนูย่อย)
          ExpansionTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('จัดการการขาย'),
            children: [
              // เมนูย่อย: บันทึกการขาย
              ListTile(
                leading: const Icon(Icons.add_shopping_cart, size: 20),
                title: const Text('บันทึกการขายใหม่'),
                contentPadding:
                    const EdgeInsets.only(left: 32), // เยื้องเมนูย่อย
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, '/sales/new'); // นำทางไปบันทึกการขาย
                },
              ),
              // เมนูย่อย: ประวัติการขาย
              ListTile(
                leading: const Icon(Icons.history, size: 20),
                title: const Text('ประวัติการขาย'),
                contentPadding: const EdgeInsets.only(left: 32),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                      context, '/sales/history'); // นำทางไปประวัติ
                },
              ),
            ],
          ),
          // เมนูรายงานการขาย
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('รายงานการขาย'),
            onTap: () {
              Navigator.pop(context);
              // นำทางไปหน้ารายงานการขายด้วย MaterialPageRoute
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SalesReportScreen()),
              );
            },
          ),
          // เมนูนำเข้า/ส่งออกข้อมูล
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('นำเข้า/ส่งออกข้อมูล'),
            onTap: () {
              Navigator.pop(context);
              // นำทางไปหน้านำเข้า/ส่งออก
              Navigator.pushNamed(
                  context, '/data/import_export'); // เปลี่ยนเป้าหมาย
            },
          ),
          // เส้นแบ่งเมนู
          const Divider(),
          // เมนูตั้งค่าธีม (เมนูย่อย)
          ExpansionTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('ตั้งค่าธีม'),
            children: [
              // ตัวเลือกโหมดสว่าง
              RadioListTile<ThemeType>(
                title: const Text('โหมดสว่าง'),
                value: ThemeType.light,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    onThemeChanged(value); // เปลี่ยน Theme
                    Navigator.pop(context); // ปิด Drawer
                  }
                },
              ),
              // ตัวเลือกโหมดมืด
              RadioListTile<ThemeType>(
                title: const Text('โหมดมืด'),
                value: ThemeType.dark,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    onThemeChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
              // ตัวเลือกธีม Custom
              RadioListTile<ThemeType>(
                title: const Text('ธีม UIIAIuiIUA'),
                value: ThemeType.custom,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    onThemeChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          // เมนูเกี่ยวกับ
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('เกี่ยวกับ'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context); // แสดง Dialog เกี่ยวกับ
            },
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดง Dialog ข้อมูลเกี่ยวกับแอป
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกี่ยวกับแอปพลิเคชัน'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('KittaShop - แอปจัดการร้านค้า'),
            SizedBox(height: 8),
            Text('เวอร์ชัน 1.0.0'),
            SizedBox(height: 16),
            Text('แอปพลิเคชันสำหรับจัดการร้านค้าขนาดเล็ก'),
            SizedBox(height: 8),
            Text('พัฒนาด้วย Flutter และ Firebase'),
          ],
        ),
        actions: [
          // ปุ่มปิด Dialog
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
