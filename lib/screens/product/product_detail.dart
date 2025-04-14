import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/models/product.dart';
import 'package:shop_management_app/screens/product/product_form.dart';
import 'package:shop_management_app/services/product_service.dart';

// หน้าจอแสดงรายละเอียดสินค้า
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // จัดรูปแบบเงิน
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสินค้า'),
        actions: [
          // ปุ่มแก้ไข
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProductDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพสินค้า
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ข้อมูลสินค้า
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อสินค้า
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ราคา
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          currencyFormat.format(product.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // สถานะสินค้า
                    const Text(
                      'สถานะสินค้า',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // จำนวนในคลัง
                    Row(
                      children: [
                        Icon(
                          product.stock > 0 ? Icons.check_circle : Icons.cancel,
                          color: product.stock > 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.stock > 0 ? 'มีสินค้า' : 'สินค้าหมด',
                          style: TextStyle(
                            color:
                                product.stock > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'คงเหลือ: ${product.stock} ชิ้น',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // หมวดหมู่
                    Row(
                      children: [
                        const Icon(Icons.category),
                        const SizedBox(width: 8),
                        const Text(
                          'หมวดหมู่:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(product.category),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ],
                    ),

                    // รายละเอียด (ถ้ามี)
                    if (product.description != null &&
                        product.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'รายละเอียด',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(product.description!),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ปุ่มจัดการสต็อก
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'จัดการสต็อก',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // ปุ่มเพิ่มสต็อก
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('เพิ่มสต็อก'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                _showAdjustStockDialog(context, true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ปุ่มลดสต็อก
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.remove),
                            label: const Text('ลดสต็อก'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                _showAdjustStockDialog(context, false),
                          ),
                        ),
                      ],
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

  // แสดงไดอะล็อกแก้ไขสินค้า
  void _showEditProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ProductFormScreen(
          product: product,
          onSave: (Product updatedProduct, String? imageUrl) async {
            final productService =
                Provider.of<ProductService>(context, listen: false);
            await productService.updateProduct(updatedProduct,
                imageUrl: imageUrl);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('อัปเดตสินค้าเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // แสดงไดอะล็อกปรับจำนวนสต็อก
  void _showAdjustStockDialog(BuildContext context, bool isAdd) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdd ? 'เพิ่มสต็อกสินค้า' : 'ลดสต็อกสินค้า'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${product.name} (คงเหลือ: ${product.stock} ชิ้น)'),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'จำนวน',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกจำนวน';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'กรุณากรอกจำนวนที่มากกว่า 0';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              if (amountController.text.isEmpty) {
                return;
              }

              final int amount = int.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                return;
              }

              // ถ้าเป็นการลดสต็อก
              if (!isAdd) {
                // ตรวจสอบว่าลดได้หรือไม่
                if (amount > product.stock) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('จำนวนสินค้าในคลังไม่เพียงพอ'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context);
                  }
                  return;
                }
              }

              // อัปเดตสต็อก
              final productService =
                  Provider.of<ProductService>(context, listen: false);
              await productService.updateStock(
                product.id!,
                isAdd ? amount : -amount,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAdd
                        ? 'เพิ่มสต็อกสินค้าจำนวน $amount ชิ้น'
                        : 'ลดสต็อกสินค้าจำนวน $amount ชิ้น'),
                    backgroundColor: isAdd ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            child: Text(
              isAdd ? 'เพิ่ม' : 'ลด',
              style: TextStyle(
                color: isAdd ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
