// lib/screens/sale/sale_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/models/member.dart';
import 'package:shop_management_app/models/product.dart';
import 'package:shop_management_app/models/sale.dart';
import 'package:shop_management_app/services/member_service.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:shop_management_app/services/sale_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

// หน้าจอบันทึกการขาย
class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  // สมาชิกที่เลือก (ถ้ามี)
  Member? _selectedMember;

  // วิธีชำระเงิน (ค่าเริ่มต้น: เงินสด)
  String _paymentMethod = 'เงินสด';

  // ตัวเลือกวิธีชำระเงิน
  final List<String> _paymentMethods = ['เงินสด', 'โอนเงิน', 'บัตรเครดิต'];

  // ตัวควบคุมช่องค้นหาสมาชิก
  final TextEditingController _memberSearchController = TextEditingController();

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ดึง Services
    final saleService = Provider.of<SaleService>(context);
    final productService = Provider.of<ProductService>(context);
    final memberService = Provider.of<MemberService>(context);

    // ดึงรายการสินค้าในตะกร้า
    final currentSaleItems = saleService.currentSaleItems;

    // คำนวณยอดรวม
    final totalAmount = saleService.calculateTotal();

    // ตั้งค่ารูปแบบเงิน
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    return Scaffold(
      // แถบด้านบน
      appBar: AppBar(
        title: const Text('บันทึกการขาย'),
        actions: [
          // ปุ่มล้างตะกร้า
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: currentSaleItems.isEmpty
                ? null
                : () => _showClearCartDialog(context, saleService),
          ),
        ],
      ),
      // เนื้อหาหลัก
      body: Column(
        children: [
          // ส่วนเลือกสมาชิก
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ข้อมูลลูกค้า',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ถ้ามีสมาชิกเลือกแล้ว
                  if (_selectedMember != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            _selectedMember!.name.isNotEmpty
                                ? _selectedMember!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedMember!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(_selectedMember!.phone),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${_selectedMember!.point} คะแนน",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ปุ่มยกเลิกการเลือก
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedMember = null;
                              _memberSearchController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ]
                  // ถ้ายังไม่ได้เลือก
                  else ...[
                    Row(
                      children: [
                        // ช่องค้นหา
                        Expanded(
                          child: TextField(
                            controller: _memberSearchController,
                            decoration: const InputDecoration(
                              labelText: 'ค้นหาสมาชิกด้วยเบอร์โทรศัพท์',
                              hintText: 'เบอร์โทรศัพท์',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ปุ่มค้นหา
                        ElevatedButton(
                          onPressed: () {
                            final phone = _memberSearchController.text.trim();
                            if (phone.isNotEmpty) {
                              final member =
                                  memberService.findMemberByPhone(phone);
                              if (member != null) {
                                setState(() {
                                  _selectedMember = member;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'ไม่พบสมาชิกที่มีเบอร์โทรศัพท์นี้'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('ค้นหา'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedMember = null;
                            _memberSearchController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'บันทึกการขายให้ลูกค้าทั่วไป (ไม่ใช่สมาชิก)'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        child: const Text('ลูกค้าทั่วไป (ไม่ใช่สมาชิก)'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ส่วนเลือกสินค้า
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'รายการสินค้า',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // ปุ่มเพิ่มสินค้า
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('เพิ่มสินค้า'),
                  onPressed: () => _showAddProductDialog(context),
                ),
              ],
            ),
          ),

          // รายการสินค้าในตะกร้า
          Expanded(
            child: currentSaleItems.isEmpty
                ? const Center(
                    child: Text('ยังไม่มีรายการสินค้า'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentSaleItems.length,
                    itemBuilder: (context, index) {
                      final item = currentSaleItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.productName),
                          subtitle: Text(currencyFormat.format(item.price)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ปุ่มลดจำนวน
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: item.quantity > 1
                                    ? () {
                                        saleService.updateItemQuantity(
                                            index, item.quantity - 1);
                                      }
                                    : null,
                              ),
                              // จำนวน
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              // ปุ่มเพิ่มจำนวน
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  if (productService.hasEnoughStock(
                                      item.productId, item.quantity + 1)) {
                                    saleService.updateItemQuantity(
                                        index, item.quantity + 1);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('สินค้าในคลังไม่เพียงพอ'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                              // ปุ่มลบ
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  saleService.removeItemFromCurrentSale(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ส่วนสรุปการขาย
          if (currentSaleItems.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ยอดรวม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ยอดรวม',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormat.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // เลือกวิธีชำระเงิน
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'วิธีการชำระเงิน',
                        border: OutlineInputBorder(),
                      ),
                      value: _paymentMethod,
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _paymentMethod = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ปุ่มบันทึก
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _saveSale(context),
                        child: const Text(
                          'บันทึกการขาย',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // แสดง Dialog เลือกสินค้า
  void _showAddProductDialog(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    final saleService = Provider.of<SaleService>(context, listen: false);
    final products = productService.products.where((p) => p.stock > 0).toList();

    // ตั้งค่ารูปแบบเงิน
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    // ถ้าไม่มีสินค้า
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่มีสินค้าในคลัง'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เลือกสินค้า'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.image),
                              ),
                            )
                          : const Icon(Icons.inventory),
                ),
                title: Text(product.name),
                subtitle: Row(
                  children: [
                    Text(currencyFormat.format(product.price)),
                    const SizedBox(width: 8),
                    Text(
                      'คงเหลือ: ${product.stock}',
                      style: TextStyle(
                        color: product.stock < 5 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showQuantityDialog(context, product),
              );
            },
          ),
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

  // แสดง Dialog ระบุจำนวนสินค้า
  void _showQuantityDialog(BuildContext context, Product product) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ระบุจำนวน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(product.name),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'จำนวน',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;

              // ตรวจสอบจำนวน
              if (quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('จำนวนต้องมากกว่า 0'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // ตรวจสอบสต็อก
              final productService =
                  Provider.of<ProductService>(context, listen: false);
              if (!productService.hasEnoughStock(product.id!, quantity)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('สินค้าในคลังไม่เพียงพอ'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // เพิ่มสินค้าลงตะกร้า
              final saleService =
                  Provider.of<SaleService>(context, listen: false);
              saleService.addItemToCurrentSale(
                SaleItem(
                  productId: product.id!,
                  productName: product.name,
                  price: product.price,
                  quantity: quantity,
                ),
              );

              // ปิด Dialog
              Navigator.pop(context);
              Navigator.pop(context);

              // แสดงข้อความสำเร็จ
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('เพิ่ม ${product.name} จำนวน $quantity ชิ้น'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  // แสดง Dialog ล้างตะกร้า
  void _showClearCartDialog(BuildContext context, SaleService saleService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างรายการ'),
        content: const Text('คุณต้องการล้างรายการสินค้าทั้งหมดหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              saleService.clearCurrentSale();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ล้างรายการเรียบร้อยแล้ว'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child:
                const Text('ล้างรายการ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // บันทึกการขาย
  void _saveSale(BuildContext context) {
    final saleService = Provider.of<SaleService>(context, listen: false);
    final productService = Provider.of<ProductService>(context, listen: false);
    final memberService = Provider.of<MemberService>(context, listen: false);

    // ตรวจสอบว่ามีสินค้า
    if (saleService.currentSaleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่มีรายการสินค้า'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ตรวจสอบสต็อก
    for (var item in saleService.currentSaleItems) {
      if (!productService.hasEnoughStock(item.productId, item.quantity)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สินค้า ${item.productName} ในคลังไม่เพียงพอ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // สร้างข้อมูลการขาย
    final sale = Sale(
      saleDate: DateTime.now(),
      memberId: _selectedMember?.id,
      memberName: _selectedMember?.name,
      items: List.from(saleService.currentSaleItems),
      totalAmount: saleService.calculateTotal(),
      paymentMethod: _paymentMethod,
    );

    // แสดง Dialog ยืนยัน
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการบันทึกการขาย'),
        content: const Text('คุณต้องการบันทึกการขายนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // แสดง Dialog กำลังบันทึก
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('กำลังบันทึกการขาย...'),
                    ],
                  ),
                ),
              );

              // บันทึกการขาย
              try {
                await saleService.saveSale(sale, productService, memberService);

                if (context.mounted) {
                  Navigator.pop(context);

                  // แสดง Dialog สำเร็จ
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('บันทึกการขายสำเร็จ'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text('บันทึกการขายเรียบร้อยแล้ว'),
                          const SizedBox(height: 8),
                          Text(
                            'ยอดรวม: ${NumberFormat.currency(locale: 'th_TH', symbol: '฿').format(sale.totalAmount)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // ล้างข้อมูล
                            setState(() {
                              _selectedMember = null;
                              _memberSearchController.clear();
                              _paymentMethod = 'เงินสด';
                            });
                          },
                          child: const Text('ปิด'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาด: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('บันทึก', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
