import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark, custom }

class ThemeProvider extends ChangeNotifier {
  ThemeType _currentTheme = ThemeType.light;
  final String _themeKey = 'theme_preference';

  ThemeType get currentTheme => _currentTheme;

  // Constructor - โหลดธีมจาก SharedPreferences
  ThemeProvider() {
    _loadThemePreference();
  }

  // โหลดการตั้งค่าธีมที่บันทึกไว้
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      if (themeIndex >= 0 && themeIndex < ThemeType.values.length) {
        _currentTheme = ThemeType.values[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      // กรณีมีข้อผิดพลาด ให้ใช้ธีม Light เป็นค่าเริ่มต้น
      _currentTheme = ThemeType.light;
    }
  }

  // บันทึกการตั้งค่าธีม
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      // กรณีมีข้อผิดพลาดในการบันทึก ข้ามไป
    }
  }

  // เปลี่ยนธีมแอพ
  void setTheme(ThemeType theme) {
    _currentTheme = theme;
    _saveThemePreference();
    notifyListeners();
  }

  // ฟังก์ชันกำหนดธีมแบบ Light
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // ฟังก์ชันกำหนดธีมแบบ Dark
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[900],
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      scaffoldBackgroundColor: Colors.grey[850],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  // ฟังก์ชันกำหนดธีมแบบ Custom (UIIAIuiIUA)
  ThemeData getCustomTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple, // เปลี่ยนสีหลักเป็นสีม่วง
        brightness: Brightness.light,
        primary: Colors.purple,
        secondary: Colors.amber,
        tertiary: Colors.teal,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 4, // เพิ่ม elevation
        backgroundColor: Colors.purple, // สีพื้นหลัง AppBar เป็นสีม่วง
        foregroundColor: Colors.white, // ตัวอักษรเป็นสีขาว
      ),
      cardTheme: CardTheme(
        elevation: 5, // เพิ่ม elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ความโค้งมากขึ้น
        ),
      ),
      scaffoldBackgroundColor: Colors.purple[50], // พื้นหลังเป็นสีม่วงอ่อนๆ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber, // ปุ่มเป็นสีเหลืองอำพัน
          foregroundColor: Colors.black, // ตัวอักษรในปุ่มเป็นสีดำ
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // ปุ่มโค้งมากขึ้น
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white, // พื้นหลังช่องกรอกข้อมูลเป็นสีขาว
        contentPadding: const EdgeInsets.all(16),
      ),
      iconTheme: const IconThemeData(
        color: Colors.purple, // ไอคอนเป็นสีม่วง
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
      ),
      // สีสำหรับ FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
    );
  }

  // ฟังก์ชันสำหรับรับ ThemeData ตามธีมปัจจุบัน
  ThemeData getTheme() {
    switch (_currentTheme) {
      case ThemeType.light:
        return getLightTheme();
      case ThemeType.dark:
        return getDarkTheme();
      case ThemeType.custom:
        return getCustomTheme();
    }
  }
}
