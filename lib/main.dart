import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/dashboard/main_screen.dart';

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

class ExpenseManagerApp extends ConsumerWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);

    return MaterialApp(
      title: 'Quản Lý Chi Tiêu OCR',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: isLight ? Colors.white : const Color(0xFF12141C),
        colorScheme: isLight ? const ColorScheme.light(
          primary: Color(0xFF00E676),
          surface: Colors.white,
          onSurface: Colors.black,
        ) : const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF12141C),
          onSurface: Colors.white,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 14 * textScale),
          bodyLarge: TextStyle(fontSize: 16 * textScale),
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}
