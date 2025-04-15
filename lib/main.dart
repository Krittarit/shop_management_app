// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop_management_app/screens/dashboard_screen.dart';
import 'package:shop_management_app/screens/member/member_list.dart';
import 'package:shop_management_app/screens/product/product_list.dart';
import 'package:shop_management_app/screens/sale/sale_form.dart';
import 'package:shop_management_app/screens/sale/sale_history.dart';
import 'package:shop_management_app/screens/data/import_export_screen.dart';
import 'package:shop_management_app/services/member_service.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:shop_management_app/services/sale_service.dart';
import 'package:shop_management_app/services/data_service.dart';
import 'package:shop_management_app/services/theme_provider.dart';

// ฟังก์ชันหลักของแอป
void main() async {
  // ทำให้แน่ใจว่า Flutter พร้อมทำงาน
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่ารูปแบบวันที่สำหรับภาษาไทย
  await initializeDateFormatting('th_TH', null);

  // เริ่มต้นการเชื่อมต่อกับ Firebase
  await Firebase.initializeApp();

  // เริ่มรันแอป
  runApp(const MyApp());
}

// คลาสหลักของแอป
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // กำหนด Providers สำหรับจัดการ State
      providers: [
        // Provider สำหรับจัดการข้อมูลสมาชิก
        ChangeNotifierProvider(create: (context) => MemberService()),
        // Provider สำหรับจัดการข้อมูลสินค้า
        ChangeNotifierProvider(create: (context) => ProductService()),
        // Provider สำหรับจัดการข้อมูลการขาย
        ChangeNotifierProvider(create: (context) => SaleService()),
        // Provider สำหรับจัดการการนำเข้า/ส่งออกข้อมูล
        ChangeNotifierProvider(create: (context) => DataService()),
        // Provider สำหรับจัดการ Theme
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        // Consumer เพื่อรับการเปลี่ยนแปลง Theme
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // ชื่อแอป
            title: 'KittaShop',
            // ดึง Theme จาก ThemeProvider
            theme: themeProvider.getTheme(),
            // ตั้งค่า Locale เป็นภาษาไทย
            locale: const Locale('th', 'TH'),
            // รองรับภาษาไทยและอังกฤษ
            supportedLocales: const [
              Locale('th', 'TH'),
              Locale('en', 'US'),
            ],
            // ตั้งค่า Localization สำหรับภาษา
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // เส้นทางเริ่มต้น
            initialRoute: '/',
            // กำหนดเส้นทางไปยังหน้าต่าง ๆ
            routes: {
              '/': (context) => const DashboardScreen(),
              '/members': (context) => const MemberListScreen(),
              '/products': (context) => const ProductListScreen(),
              '/sales/new': (context) => const SaleFormScreen(),
              '/sales/history': (context) => const SaleHistoryScreen(),
              '/data/import_export': (context) => const ImportExportScreen(),
            },
          );
        },
      ),
    );
  }
}
