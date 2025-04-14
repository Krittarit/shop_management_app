import 'package:flutter/material.dart';
import 'package:shop_management_app/screens/report/sales_report_screen.dart';
import 'package:shop_management_app/services/theme_provider.dart';

class CustomDrawer extends StatelessWidget {
  final Function(ThemeType) onThemeChanged;
  final ThemeType currentTheme;

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
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('จัดการสมาชิก'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/members');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('จัดการสินค้า'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/products');
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('จัดการการขาย'),
            children: [
              ListTile(
                leading: const Icon(Icons.add_shopping_cart, size: 20),
                title: const Text('บันทึกการขายใหม่'),
                contentPadding: const EdgeInsets.only(left: 32),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/sales/new');
                },
              ),
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
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('รายงานการขาย'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SalesReportScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('นำเข้า/ส่งออกข้อมูล'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                  context, '/data/import_export'); // เปลี่ยนเป้าหมาย
            },
          ),
          const Divider(),
          ExpansionTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('ตั้งค่าธีม'),
            children: [
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
