// lib/screens/data/import_export_screen.dart
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:shop_management_app/services/data_service.dart';

// หน้าจอนำเข้าและส่งออกข้อมูล
class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  // ตัวควบคุมช่องข้อความสำหรับ JSON
  final _membersController = TextEditingController();
  final _productsController = TextEditingController();
  final _salesController = TextEditingController();
  // ตัวแปรสถานะการโหลด
  bool _isLoading = false;

  // ล้างทรัพยากรเมื่อปิดหน้าจอ
  @override
  void dispose() {
    _membersController.dispose();
    _productsController.dispose();
    _salesController.dispose();
    super.dispose();
  }

  // แสดง Dialog ยืนยันการนำเข้า
  Future<bool> _confirmImport(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการนำเข้า'),
        content: const Text(
            'การนำเข้าจะลบข้อมูลเดิมทั้งหมด ต้องการดำเนินการต่อหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  // ฟังก์ชันนำเข้าข้อมูล
  Future<void> _importData(String collection, TextEditingController controller,
      DataService dataService) async {
    // ตรวจสอบว่า JSON ไม่ว่าง
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณาวาง JSON ก่อน'), backgroundColor: Colors.red),
      );
      return;
    }

    // ขอยืนยันจากผู้ใช้
    if (!await _confirmImport(context)) return;

    // เริ่มโหลด
    setState(() {
      _isLoading = true;
    });

    // นำเข้า JSON ลง Firestore
    final success =
        await dataService.importCollection(collection, controller.text);
    setState(() {
      _isLoading = false;
    });

    // แสดงผลลัพธ์
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'นำเข้าข้อมูลสำเร็จ' : 'นำเข้าข้อมูลล้มเหลว'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    // ล้างช่องถ้าสำเร็จ
    if (success) {
      controller.clear();
    }
  }

  // ฟังก์ชันส่งออกข้อมูล
  Future<void> _exportData(String collection, DataService dataService) async {
    // เริ่มโหลด
    setState(() {
      _isLoading = true;
    });

    // ดึง JSON ตามประเภทข้อมูล
    String json;
    switch (collection) {
      case 'members':
        json = await dataService.exportMembers();
        break;
      case 'products':
        json = await dataService.exportProducts();
        break;
      case 'sales':
        json = await dataService.exportSales();
        break;
      default:
        return;
    }

    // หยุดโหลด
    setState(() {
      _isLoading = false;
    });

    // คัดลอก JSON ไปยังคลิปบอร์ด
    await FlutterClipboard.copy(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('คัดลอก JSON ไปยังคลิปบอร์ดแล้ว'),
          backgroundColor: Colors.green),
    );
  }

  // ฟังก์ชันวาง JSON จากคลิปบอร์ด
  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    final text = await FlutterClipboard.paste();
    controller.text = text;
  }

  // ฟังก์ชันสร้าง UI สำหรับแต่ละส่วน (สมาชิก, สินค้า, การขาย)
  Widget _buildSection(String title, TextEditingController controller,
      String collection, DataService dataService) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // ช่องสำหรับวาง JSON
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'วาง JSON $titleที่นี่',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () => _pasteFromClipboard(controller),
                  tooltip: 'วางจากคลิปบอร์ด',
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ปุ่มนำเข้าและส่งออก
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: Text('นำเข้า$title'),
                    onPressed: _isLoading
                        ? null
                        : () =>
                            _importData(collection, controller, dataService),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text('ส่งออก$title'),
                    onPressed: _isLoading
                        ? null
                        : () => _exportData(collection, dataService),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึง DataService จาก Provider
    final dataService = Provider.of<DataService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('นำเข้า/ส่งออกข้อมูล'),
      ),
      body: Stack(
        children: [
          // เนื้อหาหลัก
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนสมาชิก
                _buildSection(
                    'สมาชิก', _membersController, 'members', dataService),
                const SizedBox(height: 16),
                // ส่วนสินค้า
                _buildSection(
                    'สินค้า', _productsController, 'products', dataService),
                const SizedBox(height: 16),
                // ส่วนการขาย
                _buildSection('การขาย', _salesController, 'sales', dataService),
              ],
            ),
          ),
          // แสดงตัวโหลดเมื่อกำลังทำงาน
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
