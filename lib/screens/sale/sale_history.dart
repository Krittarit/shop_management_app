import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/models/sale.dart';
import 'package:shop_management_app/services/sale_service.dart';

// หน้าจอแสดงประวัติการขาย
class SaleHistoryScreen extends StatefulWidget {
  const SaleHistoryScreen({super.key});

  @override
  State<SaleHistoryScreen> createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen> {
  // ตัวแปรสำหรับกรองข้อมูล
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final saleService = Provider.of<SaleService>(context);

    // กรองรายการขายตามช่วงวันที่
    final filteredSales = saleService.getSalesByDateRange(_startDate, _endDate);

    // คำนวณยอดขายรวม
    final totalSales = saleService.calculateTotalSales(filteredSales);

    // จัดรูปแบบวันที่
    final dateFormat = DateFormat('d MMM yyyy', 'th');

    // จัดรูปแบบเงิน
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการขาย'),
      ),
      body: Column(
        children: [
          // ส่วนกรองข้อมูล
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'กรองตามวันที่',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // ปุ่มเลือกวันที่เริ่มต้น
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'วันที่เริ่มต้น',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(dateFormat.format(_startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // ปุ่มเลือกวันที่สิ้นสุด
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'วันที่สิ้นสุด',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(dateFormat.format(_endDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ปุ่มตัวกรองด่วน
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'วันนี้',
                          onTap: () {
                            setState(() {
                              // แก้ไขจาก DateTime.now() เป็นเวลาเริ่มต้นและสิ้นสุดของวันนี้
                              final now = DateTime.now();
                              _startDate = DateTime(now.year, now.month,
                                  now.day, 0, 0, 0); // 00:00:00
                              _endDate = DateTime(now.year, now.month, now.day,
                                  23, 59, 59); // 23:59:59
                            });
                          },
                        ),
                        _buildFilterChip(
                          label: '7 วันล่าสุด',
                          onTap: () {
                            setState(() {
                              _startDate = DateTime.now()
                                  .subtract(const Duration(days: 7));
                              _endDate = DateTime.now();
                            });
                          },
                        ),
                        _buildFilterChip(
                          label: '30 วันล่าสุด',
                          onTap: () {
                            setState(() {
                              _startDate = DateTime.now()
                                  .subtract(const Duration(days: 30));
                              _endDate = DateTime.now();
                            });
                          },
                        ),
                        _buildFilterChip(
                          label: 'เดือนนี้',
                          onTap: () {
                            final now = DateTime.now();
                            setState(() {
                              _startDate = DateTime(now.year, now.month, 1);
                              _endDate = now;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ส่วนสรุปยอดขาย
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ยอดขายรวม',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalSales),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ส่วนรายการประวัติการขาย
          Expanded(
            child: filteredSales.isEmpty
                ? const Center(
                    child: Text('ไม่พบรายการขาย'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = filteredSales[index];
                      return _buildSaleItem(
                          context, sale, dateFormat, currencyFormat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // สร้าง Widget ตัวกรองแบบชิพ
  Widget _buildFilterChip(
      {required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }

  // แสดงไดอะล็อกเลือกวันที่
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // ถ้าวันที่เริ่มต้นมากกว่าวันที่สิ้นสุด ให้ปรับวันที่สิ้นสุดด้วย
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // ถ้าวันที่สิ้นสุดน้อยกว่าวันที่เริ่มต้น ให้ปรับวันที่เริ่มต้นด้วย
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  // สร้าง Widget แสดงรายการขาย
  Widget _buildSaleItem(BuildContext context, Sale sale, DateFormat dateFormat,
      NumberFormat currencyFormat) {
    // จัดรูปแบบวันที่และเวลา
    final dateTimeFormat = DateFormat('d MMM yyyy HH:mm', 'th');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          dateTimeFormat.format(sale.saleDate),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงชื่อลูกค้า (ถ้ามี)
            if (sale.memberName != null) Text('ลูกค้า: ${sale.memberName}'),
            // แสดงจำนวนรายการสินค้า
            Text('${sale.items.length} รายการ'),
          ],
        ),
        trailing: Text(
          currencyFormat.format(sale.totalAmount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
        // ส่วนแสดงรายละเอียดเมื่อกดขยาย
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงรายการสินค้า
                const Text(
                  'รายการสินค้า',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                const Divider(),
                // แสดงข้อมูลการชำระเงิน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'วิธีชำระเงิน: ${sale.paymentMethod}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'ยอดรวม: ${currencyFormat.format(sale.totalAmount)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                // แสดงข้อมูลสมาชิก (ถ้ามี)
                if (sale.memberName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'สมาชิก: ${sale.memberName}',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
