import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/models/sale.dart';
import 'package:shop_management_app/services/sale_service.dart';
import 'package:fl_chart/fl_chart.dart';

// หน้าจอแสดงรายงานการขาย
class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen>
    with SingleTickerProviderStateMixin {
  // ตัวแปรสำหรับกรองข้อมูล
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // ตัวแปรสำหรับ TabController
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายงานการขาย'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'รายวัน'),
            Tab(text: 'รายเดือน'),
            Tab(text: 'สินค้าขายดี'),
          ],
        ),
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
                    'ช่วงเวลา',
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
                            child: Text(
                              DateFormat('d MMM yyyy', 'th').format(_startDate),
                            ),
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
                            child: Text(
                              DateFormat('d MMM yyyy', 'th').format(_endDate),
                            ),
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
                        _buildFilterChip(
                          label: 'เดือนที่แล้ว',
                          onTap: () {
                            final now = DateTime.now();
                            final lastMonth = now.month > 1
                                ? DateTime(now.year, now.month - 1, 1)
                                : DateTime(now.year - 1, 12, 1);

                            setState(() {
                              _startDate = lastMonth;
                              _endDate = DateTime(
                                lastMonth.year,
                                lastMonth.month + 1,
                                0,
                              );
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

          // ส่วนแสดงกราฟและรายงาน
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // แท็บที่ 1: รายงานรายวัน
                _buildDailyReportTab(),

                // แท็บที่ 2: รายงานรายเดือน
                _buildMonthlyReportTab(),

                // แท็บที่ 3: สินค้าขายดี
                _buildTopProductsTab(),
              ],
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

  // สร้างแท็บรายงานรายวัน
  Widget _buildDailyReportTab() {
    return Consumer<SaleService>(
      builder: (context, saleService, child) {
        // กรองข้อมูลตามช่วงวันที่
        final filteredSales =
            saleService.getSalesByDateRange(_startDate, _endDate);

        // รวมยอดขายตามวัน
        final dailySales = _groupSalesByDay(filteredSales);

        // สร้างข้อมูลสำหรับกราฟ
        final dailyData = dailySales.entries.map((entry) {
          return SalesData(entry.key, entry.value);
        }).toList();

        // เรียงข้อมูลตามวันที่
        dailyData.sort((a, b) => a.date.compareTo(b.date));

        // จัดรูปแบบเงิน
        final currencyFormat =
            NumberFormat.currency(locale: 'th_TH', symbol: '฿');

        // ถ้าไม่มีข้อมูล
        if (dailyData.isEmpty) {
          return const Center(
            child: Text('ไม่พบข้อมูลการขายในช่วงเวลาที่เลือก'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // การ์ดสรุปภาพรวม
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ยอดขายรวม',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(_calculateTotal(dailyData)),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'จำนวนวันที่มีการขาย',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dailyData.length} วัน',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // กราฟแสดงยอดขายรายวัน
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'กราฟยอดขายรายวัน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dailyData.asMap().entries.map((entry) {
                                    return FlSpot(
                                        entry.key.toDouble(),
                                        entry.value.amount /
                                            1000); // แปลงเป็น K
                                  }).toList(),
                                  isCurved: false,
                                  color: Colors.blue,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${(value * 1000).toInt()}',
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                  axisNameWidget: const Text(
                                    'ยอดขาย (บาท)',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  axisNameSize: 30,
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < dailyData.length) {
                                        return Text(
                                          DateFormat('d MMM', 'th')
                                              .format(dailyData[index].date),
                                          style: const TextStyle(fontSize: 12),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                  axisNameWidget: const Text(
                                    'วันที่',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  axisNameSize: 30,
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              minY: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // สร้างแท็บรายงานรายเดือน
  Widget _buildMonthlyReportTab() {
    return Consumer<SaleService>(
      builder: (context, saleService, child) {
        // กรองข้อมูลตามช่วงวันที่
        final filteredSales =
            saleService.getSalesByDateRange(_startDate, _endDate);

        // รวมยอดขายตามเดือน
        final monthlySales = _groupSalesByMonth(filteredSales);

        // สร้างข้อมูลสำหรับกราฟ
        final monthlyData = monthlySales.entries.map((entry) {
          return MonthlySalesData(entry.key, entry.value);
        }).toList();

        // เรียงข้อมูลตามเดือน
        monthlyData.sort((a, b) => a.yearMonth.compareTo(b.yearMonth));

        // จัดรูปแบบเงิน
        final currencyFormat =
            NumberFormat.currency(locale: 'th_TH', symbol: '฿');

        // ถ้าไม่มีข้อมูล
        if (monthlyData.isEmpty) {
          return const Center(
            child: Text('ไม่พบข้อมูลการขายในช่วงเวลาที่เลือก'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // การ์ดสรุปภาพรวม
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ยอดขายรวม',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat
                                .format(_calculateMonthlyTotal(monthlyData)),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'จำนวนเดือนที่มีการขาย',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${monthlyData.length} เดือน',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // กราฟแสดงยอดขายรายเดือน
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'กราฟยอดขายรายเดือน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups:
                                  monthlyData.asMap().entries.map((entry) {
                                return BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value.amount /
                                          1000, // แปลงเป็น K
                                      color: Colors.blue,
                                      width: 20,
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${(value * 1000).toInt()}',
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                  axisNameWidget: const Text(
                                    'ยอดขาย (บาท)',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  axisNameSize: 30,
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < monthlyData.length) {
                                        return Transform.rotate(
                                          angle: -45 * 3.14159 / 180,
                                          child: Text(
                                            DateFormat('MMM yyyy', 'th').format(
                                              DateTime(
                                                int.parse(monthlyData[index]
                                                    .yearMonth
                                                    .substring(0, 4)),
                                                int.parse(monthlyData[index]
                                                    .yearMonth
                                                    .substring(5)),
                                                1,
                                              ),
                                            ),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                  axisNameWidget: const Text(
                                    'เดือน',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  axisNameSize: 30,
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              minY: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // สร้างแท็บสินค้าขายดี
  Widget _buildTopProductsTab() {
    return Consumer<SaleService>(
      builder: (context, saleService, child) {
        // กรองข้อมูลตามช่วงวันที่
        final filteredSales =
            saleService.getSalesByDateRange(_startDate, _endDate);

        // หาสินค้าขายดี
        final topProducts = _getTopProducts(filteredSales);

        // จัดรูปแบบเงิน
        final currencyFormat =
            NumberFormat.currency(locale: 'th_TH', symbol: '฿');

        // ถ้าไม่มีข้อมูล
        if (topProducts.isEmpty) {
          return const Center(
            child: Text('ไม่พบข้อมูลการขายในช่วงเวลาที่เลือก'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'สินค้าขายดี 10 อันดับแรก',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // กราฟแท่งแสดงสินค้าขายดี
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: topProducts
                        .take(10)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.quantity.toDouble(),
                            color: Colors.blue,
                            width: 20,
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          },
                        ),
                        axisNameWidget: const Text(
                          'จำนวนที่ขายได้ (ชิ้น)',
                          style: TextStyle(fontSize: 14),
                        ),
                        axisNameSize: 30,
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < topProducts.length && index < 10) {
                              return Transform.rotate(
                                angle: -45 * 3.14159 / 180,
                                child: Text(
                                  topProducts[index].productName,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                        axisNameWidget: const Text(
                          'สินค้า',
                          style: TextStyle(fontSize: 14),
                        ),
                        axisNameSize: 30,
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    minY: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // รายการสินค้าขายดี
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: topProducts.length,
                    itemBuilder: (context, index) {
                      final product = topProducts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(product.productName),
                        subtitle: Text(
                            'ยอดขาย ${currencyFormat.format(product.amount)}'),
                        trailing: Text(
                          '${product.quantity} ชิ้น',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชันรวมยอดขายตามวัน
  Map<DateTime, double> _groupSalesByDay(List<Sale> sales) {
    final dailySales = <DateTime, double>{};

    for (final sale in sales) {
      // แปลงวันที่ให้เป็นวันที่อย่างเดียว (ไม่มีเวลา)
      final saleDate = DateTime(
        sale.saleDate.year,
        sale.saleDate.month,
        sale.saleDate.day,
      );

      if (dailySales.containsKey(saleDate)) {
        dailySales[saleDate] = dailySales[saleDate]! + sale.totalAmount;
      } else {
        dailySales[saleDate] = sale.totalAmount;
      }
    }

    return dailySales;
  }

  // ฟังก์ชันรวมยอดขายตามเดือน
  Map<String, double> _groupSalesByMonth(List<Sale> sales) {
    final monthlySales = <String, double>{};

    for (final sale in sales) {
      // สร้างคีย์ในรูปแบบ "YYYY-MM"
      final yearMonth =
          '${sale.saleDate.year}-${sale.saleDate.month.toString().padLeft(2, '0')}';

      if (monthlySales.containsKey(yearMonth)) {
        monthlySales[yearMonth] = monthlySales[yearMonth]! + sale.totalAmount;
      } else {
        monthlySales[yearMonth] = sale.totalAmount;
      }
    }

    return monthlySales;
  }

  // ฟังก์ชันหาสินค้าขายดี
  List<ProductSalesData> _getTopProducts(List<Sale> sales) {
    final productSales = <String, ProductSalesData>{};

    for (final sale in sales) {
      for (final item in sale.items) {
        if (productSales.containsKey(item.productId)) {
          productSales[item.productId]!.quantity += item.quantity;
          productSales[item.productId]!.amount += item.total;
        } else {
          productSales[item.productId] = ProductSalesData(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            amount: item.total,
          );
        }
      }
    }

    final result = productSales.values.toList();
    // เรียงลำดับตามจำนวนที่ขายได้ (มากไปน้อย)
    result.sort((a, b) => b.quantity.compareTo(a.quantity));

    return result;
  }

  // คำนวณยอดรวมของข้อมูลรายวัน
  double _calculateTotal(List<SalesData> data) {
    return data.fold(0, (sum, item) => sum + item.amount);
  }

  // คำนวณยอดรวมของข้อมูลรายเดือน
  double _calculateMonthlyTotal(List<MonthlySalesData> data) {
    return data.fold(0, (sum, item) => sum + item.amount);
  }
}

// คลาสเก็บข้อมูลยอดขายรายวัน
class SalesData {
  final DateTime date;
  final double amount;

  SalesData(this.date, this.amount);
}

// คลาสเก็บข้อมูลยอดขายรายเดือน
class MonthlySalesData {
  final String yearMonth;
  final double amount;

  MonthlySalesData(this.yearMonth, this.amount);
}

// คลาสเก็บข้อมูลยอดขายของสินค้า
class ProductSalesData {
  final String productId;
  final String productName;
  int quantity;
  double amount;

  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.amount,
  });
}
