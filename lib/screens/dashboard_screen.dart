import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/services/member_service.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:shop_management_app/services/sale_service.dart';
import 'package:shop_management_app/services/theme_provider.dart';
import 'package:shop_management_app/widgets/custom_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // เรียกใช้ services ผ่าน Provider
    final memberService = Provider.of<MemberService>(context);
    final productService = Provider.of<ProductService>(context);
    final saleService = Provider.of<SaleService>(context);
    final themeProvider =
        Provider.of<ThemeProvider>(context); // ดึง ThemeProvider

    // รูปแบบการแสดงเงิน
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    // คำนวณยอดขายวันนี้
    final todaySales = saleService.getSalesByDateRange(
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now(),
    );

    final todayTotal = saleService.calculateTotalSales(todaySales);

    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
      ),
      drawer: CustomDrawer(
        currentTheme: themeProvider.currentTheme, // ส่ง theme ปัจจุบัน
        onThemeChanged: (theme) {
          // ส่ง callback สำหรับเปลี่ยน theme
          themeProvider.setTheme(theme);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวหน้าจอหลัก
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.store, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ยินดีต้อนรับ!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'วันที่ ${DateFormat('d MMMM yyyy', 'th').format(DateTime.now())}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'ภาพรวม',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // ข้อมูลสรุป (Dashboard)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                // จำนวนสมาชิก
                _buildDashboardCard(
                  context,
                  title: 'สมาชิกทั้งหมด',
                  value: '${memberService.members.length}',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/members'),
                ),

                // จำนวนสินค้า
                _buildDashboardCard(
                  context,
                  title: 'สินค้าทั้งหมด',
                  value: '${productService.products.length}',
                  icon: Icons.inventory,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/products'),
                ),

                // ยอดขายวันนี้
                _buildDashboardCard(
                  context,
                  title: 'ยอดขายวันนี้',
                  value: currencyFormat.format(todayTotal),
                  icon: Icons.payments,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/sales/history'),
                ),

                // จำนวนการขายวันนี้
                _buildDashboardCard(
                  context,
                  title: 'การขายวันนี้',
                  value: '${todaySales.length} รายการ',
                  icon: Icons.shopping_cart,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/sales/history'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ปุ่มด่วน (Quick Actions)
            const Text(
              'การดำเนินการด่วน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // ปุ่มเพิ่มการขายใหม่
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child:
                            Icon(Icons.add_shopping_cart, color: Colors.white),
                      ),
                      title: const Text('เพิ่มการขายใหม่'),
                      subtitle: const Text('บันทึกการขายสินค้า'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Navigator.pushNamed(context, '/sales/new'),
                    ),

                    const Divider(),

                    // ปุ่มเพิ่มสมาชิกใหม่
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person_add, color: Colors.white),
                      ),
                      title: const Text('เพิ่มสมาชิกใหม่'),
                      subtitle: const Text('ลงทะเบียนสมาชิกใหม่'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/members',
                        arguments: {'showAddDialog': true},
                      ),
                    ),

                    const Divider(),

                    // ปุ่มเพิ่มสินค้าใหม่
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.add_box, color: Colors.white),
                      ),
                      title: const Text('เพิ่มสินค้าใหม่'),
                      subtitle: const Text('เพิ่มสินค้าในคลัง'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/products',
                        arguments: {'showAddDialog': true},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้างการ์ดแสดงข้อมูลบน Dashboard
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
