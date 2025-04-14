import 'package:flutter/material.dart';
import 'package:shop_management_app/screens/report/sales_report_screen.dart';
import 'package:shop_management_app/services/theme_provider.dart';

// Widget Drawer สำหรับเมนูหลักของแอปพลิเคชัน
class CustomDrawer extends StatelessWidget {
  final Function(ThemeType) onThemeChanged; // เพิ่ม callback
  final ThemeType currentTheme; // เพิ่ม currentTheme

  const CustomDrawer({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // หัว Drawer
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'KittaShop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
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

          // รายการเมนู

          // หน้าหลัก
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          // จัดการสมาชิก
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('จัดการสมาชิก'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/members');
            },
          ),

          // จัดการสินค้า
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('จัดการสินค้า'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/products');
            },
          ),

          // จัดการการขาย (Submenu)
          ExpansionTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('จัดการการขาย'),
            children: [
              // บันทึกการขายใหม่
              ListTile(
                leading: const Icon(Icons.add_shopping_cart, size: 20),
                title: const Text('บันทึกการขายใหม่'),
                contentPadding: const EdgeInsets.only(left: 32),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/sales/new');
                },
              ),

              // ประวัติการขาย
              ListTile(
                leading: const Icon(Icons.history, size: 20),
                title: const Text('ประวัติการขาย'),
                contentPadding: const EdgeInsets.only(left: 32),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/sales/history');
                },
              ),
            ],
          ),

          // รายงาน (ใหม่)
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('รายงานการขาย'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesReportScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // ตั้งค่าธีม - แก้ให้ใช้ callback แทน Provider
          ExpansionTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('ตั้งค่าธีม'),
            children: [
              // ธีม Light
              RadioListTile<ThemeType>(
                title: const Text('โหมดสว่าง'),
                value: ThemeType.light,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    onThemeChanged(value);
                    Navigator.pop(context);
                  }
                },
              ),

              // ธีม Dark
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

              // ธีม Custom (UIIAIuiIUA)
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

          // เกี่ยวกับแอป
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('เกี่ยวกับ'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // แสดงหน้าต่างข้อมูลเกี่ยวกับแอป
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
