// lib/screens/product/product_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_management_app/models/product.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

// หน้าจอฟอร์มเพิ่ม/แก้ไขข้อมูลสินค้า
class ProductFormScreen extends StatefulWidget {
  final Product? product; // สินค้าที่ต้องการแก้ไข (null = เพิ่มใหม่)
  final Function(Product, String?) onSave; // Callback เมื่อบันทึกข้อมูล

  const ProductFormScreen({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // ตัวแปรสำหรับจัดการฟอร์ม
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _category = 'ทั่วไป'; // ค่าเริ่มต้นหมวดหมู่
  bool _isValidImageUrl = true; // สถานะความถูกต้องของ URL

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นการแก้ไข นำข้อมูลเดิมมาแสดง
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _descriptionController.text = widget.product!.description ?? '';
      _imageUrlController.text = widget.product!.imageUrl ?? '';
      _category = widget.product!.category;
    }
  }

  // ล้างทรัพยากร
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ตรวจสอบว่า URL รูปภาพถูกต้องหรือไม่
  void _validateImageUrl(String url) {
    if (url.isEmpty) {
      setState(() {
        _isValidImageUrl = true; // ถ้าไม่ระบุ URL ถือว่าผ่าน
      });
      return;
    }

    // ใช้ RegExp ตรวจสอบรูปแบบ URL รูปภาพ
    final pattern = RegExp(
      r'^(http|https):\/\/[^\s/$.?#].[^\s]*\.(jpg|jpeg|png|gif|bmp|webp)(\?.*)?$',
      caseSensitive: false,
    );

    setState(() {
      _isValidImageUrl = pattern.hasMatch(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึงรายการหมวดหมู่จาก ProductService
    final productService = Provider.of<ProductService>(context);
    final categories = productService.getAllCategories();

    // ถ้าไม่มีหมวดหมู่ ใช้ "ทั่วไป"
    if (categories.isEmpty) {
      categories.add('ทั่วไป');
    }

    // ถ้าหมวดหมู่ไม่อยู่ในรายการ เพิ่มเข้าไป
    if (!categories.contains(_category)) {
      categories.add(_category);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // หัวข้อฟอร์ม
              Text(
                widget.product == null
                    ? 'เพิ่มสินค้าใหม่'
                    : 'แก้ไขข้อมูลสินค้า',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ช่องกรอก URL รูปภาพและตัวอย่าง
              Column(
                children: [
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL รูปภาพ (ไม่บังคับ)',
                      prefixIcon: const Icon(Icons.image),
                      errorText:
                          !_isValidImageUrl ? 'URL รูปภาพไม่ถูกต้อง' : null,
                      hintText: 'https://example.com/image.jpg',
                      helperText:
                          'ระบุ URL ของรูปภาพที่ลงท้ายด้วย .jpg, .png, .gif เป็นต้น',
                    ),
                    onChanged: _validateImageUrl,
                  ),
                  const SizedBox(height: 8),
                  if (_imageUrlController.text.isNotEmpty && _isValidImageUrl)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: _imageUrlController.text,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ช่องกรอกชื่อสินค้า (บังคับ)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสินค้า *',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อสินค้า';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ช่องกรอกราคา (บังคับ)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'ราคา *',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกราคา';
                  }
                  if (double.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  }
                  if (double.parse(value) <= 0) {
                    return 'ราคาต้องมากกว่า 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ช่องกรอกจำนวนในคลัง (บังคับ)
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'จำนวนในคลัง *',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกจำนวนในคลัง';
                  }
                  if (int.tryParse(value) == null) {
                    return 'กรุณากรอกจำนวนเต็ม';
                  }
                  if (int.parse(value) < 0) {
                    return 'จำนวนต้องไม่น้อยกว่า 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // เลือกหมวดหมู่ (บังคับ)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่ *',
                  prefixIcon: Icon(Icons.category),
                ),
                value: _category,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // ช่องกรอกรายละเอียด (ไม่บังคับ)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด (ไม่บังคับ)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // ปุ่มดำเนินการ
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ปุ่มยกเลิก
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 8),
                  // ปุ่มบันทึก
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: const Text('บันทึก'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันบันทึกข้อมูลสินค้า
  void _saveProduct() {
    // ตรวจสอบความถูกต้องของฟอร์มและ URL
    if (_formKey.currentState!.validate() && _isValidImageUrl) {
      final Product product;

      // กรณีแก้ไข
      if (widget.product != null) {
        product = widget.product!.copyWith(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _category,
        );
      }
      // กรณีเพิ่มใหม่
      else {
        product = Product(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _category,
        );
      }

      // ส่งข้อมูลไปบันทึก
      String? imageUrl = _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim();
      widget.onSave(product, imageUrl);
    }
  }
}
