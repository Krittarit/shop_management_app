// lib/screens/product/product_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shop_management_app/models/product.dart';
import 'package:shop_management_app/screens/product/product_form.dart';
import 'package:shop_management_app/screens/product/product_detail.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = ''; // คำค้นหา
  String? _selectedCategory; // หมวดหมู่ที่เลือก

  @override
  void initState() {
    super.initState();
    // ตรวจสอบพารามิเตอร์เพื่อแสดง Dialog เพิ่มสินค้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showAddDialog'] == true) {
        _showAddProductDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึง ProductService
    final productService = Provider.of<ProductService>(context);
    List<Product> products = productService.products;

    // กรองตามหมวดหมู่
    if (_selectedCategory != null) {
      products = products
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // กรองตามคำค้นหา
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        final name = product.name.toLowerCase();
        final description = (product.description ?? '').toLowerCase();
        final search = _searchQuery.toLowerCase();
        return name.contains(search) || description.contains(search);
      }).toList();
    }

    // ดึงรายการหมวดหมู่
    final categories = productService.getAllCategories();

    // ตั้งค่ารูปแบบเงิน
    final currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿');

    return Scaffold(
      // แถบด้านบน
      appBar: AppBar(
        title: const Text('จัดการสินค้า'),
        actions: [
          // ปุ่มค้นหา
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ProductSearchDelegate(
                  productService.products,
                  (product) => _navigateToProductDetail(product),
                  currencyFormat,
                ),
              );
            },
          ),
        ],
      ),
      // เนื้อหาหลัก
      body: Column(
        children: [
          // ช่องค้นหาและตัวกรอง
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ช่องค้นหา
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'ค้นหาสินค้า',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // ตัวกรองหมวดหมู่
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // ตัวกรอง "ทั้งหมด"
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: const Text('ทั้งหมด'),
                          selected: _selectedCategory == null,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                      ),
                      // ตัวกรองตามหมวดหมู่
                      ...categories.map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // รายการสินค้า
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text('ไม่พบสินค้า'),
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductListItem(
                          context, product, currencyFormat);
                    },
                  ),
          ),
        ],
      ),
      // ปุ่มเพิ่มสินค้า
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // สร้างรายการสินค้า
  Widget _buildProductListItem(
      BuildContext context, Product product, NumberFormat currencyFormat) {
    final productService = Provider.of<ProductService>(context, listen: false);

    return Slidable(
      // ปุ่มเลื่อนซ้าย (แก้ไข)
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showEditProductDialog(product),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'แก้ไข',
          ),
        ],
      ),
      // ปุ่มเลื่อนขวา (ลบ)
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteProductDialog(product),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'ลบ',
          ),
        ],
      ),
      // รายการสินค้า
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          // รูปภาพสินค้า
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.inventory),
                    ),
                  )
                : const Icon(Icons.inventory),
          ),
          // ชื่อและข้อมูล
          title: Text(product.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyFormat.format(product.price),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'หมวดหมู่: ${product.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          // จำนวนสต็อก
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'คงเหลือ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${product.stock} ชิ้น',
                style: TextStyle(
                  color: product.stock > 0 ? Colors.black : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onTap: () => _navigateToProductDetail(product),
        ),
      ),
    );
  }

  // นำทางไปหน้ารายละเอียดสินค้า
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  // แสดง Dialog เพิ่มสินค้า
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ProductFormScreen(
          onSave: (Product newProduct, String? imageUrl) async {
            final productService =
                Provider.of<ProductService>(context, listen: false);
            await productService.addProduct(newProduct, imageUrl: imageUrl);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('เพิ่มสินค้าเรียบร้อยแล้ว'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // แสดง Dialog แก้ไขสินค้า
  void _showEditProductDialog(Product product) {
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

  // แสดง Dialog ลบสินค้า
  void _showDeleteProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบสินค้า'),
        content: Text('คุณต้องการลบ ${product.name} หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              final productService =
                  Provider.of<ProductService>(context, listen: false);
              await productService.deleteProduct(product.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ลบสินค้าเรียบร้อยแล้ว'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// คลาสสำหรับการค้นหาสินค้าแบบเต็มหน้าจอ
class _ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  final Function(Product) onProductSelected;
  final NumberFormat currencyFormat;

  _ProductSearchDelegate(
      this.products, this.onProductSelected, this.currencyFormat);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products.where((product) {
      final name = product.name.toLowerCase();
      final description = (product.description ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.inventory),
                    ),
                  )
                : const Icon(Icons.inventory),
          ),
          title: Text(product.name),
          subtitle: Text(currencyFormat.format(product.price)),
          trailing: Text('${product.stock} ชิ้น'),
          onTap: () {
            close(context, product);
            onProductSelected(product);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products.where((product) {
      final name = product.name.toLowerCase();
      final description = (product.description ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || description.contains(searchQuery);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.inventory),
                    ),
                  )
                : const Icon(Icons.inventory),
          ),
          title: Text(product.name),
          subtitle: Text(currencyFormat.format(product.price)),
          trailing: Text('${product.stock} ชิ้น'),
          onTap: () {
            close(context, product);
            onProductSelected(product);
          },
        );
      },
    );
  }
}
