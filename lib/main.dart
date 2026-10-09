import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Hive
  await Hive.initFlutter();
  
  // Register adapters here
  // Hive.registerAdapter(ExpenseAdapter());
  
  // Open boxes
  // await Hive.openBox('expenses');

  runApp(
    const ProviderScope(
      child: ExpenseManagerApp(),
    ),
  );
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu OCR',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF12141C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF12141C),
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto', // Sử dụng font mặc định hoặc import Google Fonts
      ),
      home: const DashboardScreen(),
    );
  }
}
