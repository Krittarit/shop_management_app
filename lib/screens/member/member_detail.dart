// lib/screens/member/member_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/models/member.dart';
import 'package:shop_management_app/models/sale.dart';
import 'package:shop_management_app/screens/member/member_form.dart';
import 'package:shop_management_app/services/member_service.dart';
import 'package:shop_management_app/services/sale_service.dart';

// หน้าจอแสดงรายละเอียดสมาชิก
class MemberDetailScreen extends StatelessWidget {
  final Member member; // ข้อมูลสมาชิกที่ต้องการแสดง

  const MemberDetailScreen({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    // ดึง SaleService เพื่อเข้าถึงข้อมูลการซื้อ
    final saleService = Provider.of<SaleService>(context);

    // ดึงรายการซื้อของสมาชิกนี้
    final memberSales = saleService.getSalesByMemberId(member.id ?? '');

    // ตั้งค่ารูปแบบวันที่และเงิน
    final dateFormat = DateFormat('d MMMM yyyy', 'th');
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    return Scaffold(
      // แถบด้านบน
      appBar: AppBar(
        title: const Text('รายละเอียดสมาชิก'),
        actions: [
          // ปุ่มแก้ไขข้อมูลสมาชิก
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditMemberDialog(context),
          ),
        ],
      ),
      // เนื้อหาหลัก
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // การ์ดข้อมูลสมาชิก
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ส่วนหัว: ชื่อและคะแนน
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${member.point} คะแนน',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // ข้อมูลการติดต่อ
                    const Text(
                      'ข้อมูลการติดต่อ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // เบอร์โทร
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'เบอร์โทรศัพท์',
                      value: member.phone,
                    ),

                    // อีเมล (ถ้ามี)
                    if (member.email != null && member.email!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.email,
                        label: 'อีเมล',
                        value: member.email!,
                      ),

                    // ที่อยู่ (ถ้ามี)
                    if (member.address != null && member.address!.isNotEmpty)
                      _buildInfoRow(
                        icon: Icons.home,
                        label: 'ที่อยู่',
                        value: member.address!,
                      ),

                    const Divider(height: 32),

                    // ข้อมูลสมาชิก
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'วันที่สมัคร',
                      value: dateFormat.format(member.joinDate),
                    ),
                    _buildInfoRow(
                      icon: Icons.shopping_cart,
                      label: 'จำนวนการซื้อ',
                      value: '${memberSales.length} ครั้ง',
                    ),
                    _buildInfoRow(
                      icon: Icons.payments,
                      label: 'ยอดซื้อรวม',
                      value: currencyFormat.format(
                        saleService.calculateTotalSales(memberSales),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ส่วนประวัติการซื้อ
            const Text(
              'ประวัติการซื้อ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // แสดงรายการซื้อหรือข้อความถ้าไม่มี
            memberSales.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('ไม่มีประวัติการซื้อ'),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: memberSales.length,
                    itemBuilder: (context, index) {
                      final sale = memberSales[index];
                      return _buildSaleItem(context, sale);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // สร้างแถวข้อมูล เช่น เบอร์โทร, อีเมล
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // สร้างการ์ดแสดงรายการซื้อ
  Widget _buildSaleItem(BuildContext context, Sale sale) {
    // ตั้งค่ารูปแบบวันที่และเงิน
    final dateFormat = DateFormat('d MMM yyyy HH:mm', 'th');
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัว: วันที่และยอดรวม
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(sale.saleDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(sale.totalAmount),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // รายการสินค้า
            const SizedBox(height: 8),
            ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Text('${item.quantity} x '),
                      Expanded(child: Text(item.productName)),
                      Text(currencyFormat.format(item.total)),
                    ],
                  ),
                )),

            // วิธีชำระเงิน
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getPaymentIcon(sale.paymentMethod),
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  sale.paymentMethod,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // เลือกไอคอนตามวิธีชำระเงิน
  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'เงินสด':
        return Icons.money;
      case 'โอนเงิน':
        return Icons.account_balance;
      case 'บัตรเครดิต':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  // แสดง Dialog สำหรับแก้ไขข้อมูลสมาชิก
  void _showEditMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MemberFormScreen(
          member: member,
          onSave: (Member updatedMember) async {
            // อัปเดตข้อมูลสมาชิก
            final memberService =
                Provider.of<MemberService>(context, listen: false);
            await memberService.updateMember(updatedMember);
            if (context.mounted) {
              Navigator.pop(context);
              // แสดงข้อความสำเร็จ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('อัปเดตข้อมูลเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
