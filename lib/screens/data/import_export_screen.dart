import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:provider/provider.dart';
import 'package:shop_management_app/services/data_service.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  final _membersController = TextEditingController();
  final _productsController = TextEditingController();
  final _salesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _membersController.dispose();
    _productsController.dispose();
    _salesController.dispose();
    super.dispose();
  }

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

  Future<void> _importData(String collection, TextEditingController controller,
      DataService dataService) async {
    if (controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณาวาง JSON ก่อน'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!await _confirmImport(context)) return;

    setState(() {
      _isLoading = true;
    });

    final success =
        await dataService.importCollection(collection, controller.text);
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'นำเข้าข้อมูลสำเร็จ' : 'นำเข้าข้อมูลล้มเหลว'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      controller.clear();
    }
  }

  Future<void> _exportData(String collection, DataService dataService) async {
    setState(() {
      _isLoading = true;
    });

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

    setState(() {
      _isLoading = false;
    });

    await FlutterClipboard.copy(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('คัดลอก JSON ไปยังคลิปบอร์ดแล้ว'),
          backgroundColor: Colors.green),
    );
  }

  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    final text = await FlutterClipboard.paste();
    controller.text = text;
  }

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
    final dataService = Provider.of<DataService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('นำเข้า/ส่งออกข้อมูล'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                    'สมาชิก', _membersController, 'members', dataService),
                const SizedBox(height: 16),
                _buildSection(
                    'สินค้า', _productsController, 'products', dataService),
                const SizedBox(height: 16),
                _buildSection('การขาย', _salesController, 'sales', dataService),
              ],
            ),
          ),
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
