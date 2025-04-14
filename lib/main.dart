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
import 'package:shop_management_app/services/member_service.dart';
import 'package:shop_management_app/services/product_service.dart';
import 'package:shop_management_app/services/sale_service.dart';
import 'package:shop_management_app/services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MemberService()),
        ChangeNotifierProvider(create: (context) => ProductService()),
        ChangeNotifierProvider(create: (context) => SaleService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'KittaShop',
            theme: themeProvider.getTheme(),
            // เพิ่มการรองรับ localization
            locale: const Locale('th', 'TH'),
            supportedLocales: const [
              Locale('th', 'TH'),
              Locale('en', 'US'), // fallback
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const DashboardScreen(),
              '/members': (context) => const MemberListScreen(),
              '/products': (context) => const ProductListScreen(),
              '/sales/new': (context) => const SaleFormScreen(),
              '/sales/history': (context) => const SaleHistoryScreen(),
            },
          );
        },
      ),
    );
  }
}
