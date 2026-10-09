import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../ocr/ocr_scanner_screen.dart';
import 'dashboard_screen.dart';

// Provider quản lý chế độ (Demo)
final lightModeProvider = StateProvider<bool>((ref) => false);
final textSizeProvider = StateProvider<double>((ref) => 1.0);

// Provider quản lý danh sách giao dịch
final transactionsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => [
  {'title': 'Highlands Coffee', 'category': 'Ăn uống', 'date': 'Hôm nay', 'amount': '-65.000 đ', 'icon': LucideIcons.coffee},
  {'title': 'GrabBike', 'category': 'Di chuyển', 'date': 'Hôm nay', 'amount': '-42.000 đ', 'icon': LucideIcons.car},
  {'title': 'Tiền lương', 'category': 'Thu nhập', 'date': 'Hôm qua', 'amount': '+25.000.000 đ', 'icon': LucideIcons.wallet},
  {'title': 'Shopee Supermarket', 'category': 'Mua sắm', 'date': '2 ngày trước', 'amount': '-1.250.000 đ', 'icon': LucideIcons.shoppingBag},
]);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);
    final textColor = isLight ? Colors.black : Colors.white;
    final bgColor = isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phân tích chi tiêu', style: TextStyle(color: textColor, fontSize: 32 * textScale, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24)),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: const Color(0xFF00E676), value: 40, title: '40%', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: const Color(0xFFFF5252), value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: const Color(0xFF29B6F6), value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    PieChartSectionData(color: const Color(0xFFFFCA28), value: 15, title: '15%', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 24),
            _buildLegendItem('Ăn uống', const Color(0xFF00E676), textColor, textScale),
            _buildLegendItem('Mua sắm', const Color(0xFFFF5252), textColor, textScale),
            _buildLegendItem('Di chuyển', const Color(0xFF29B6F6), textColor, textScale),
            _buildLegendItem('Khác', const Color(0xFFFFCA28), textColor, textScale),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, Color textColor, double textScale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: textColor, fontSize: 16 * textScale, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);
    final textColor = isLight ? Colors.black : Colors.white;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ví của tôi', style: TextStyle(color: textColor, fontSize: 32 * textScale, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildWalletCard('Tiền mặt', '2.500.000 đ', const Color(0xFF00E676), LucideIcons.banknote),
            const SizedBox(height: 16),
            _buildWalletCard('Tài khoản ngân hàng', '15.400.000 đ', const Color(0xFF29B6F6), LucideIcons.creditCard),
            const SizedBox(height: 16),
            _buildWalletCard('Ví điện tử (Momo)', '850.000 đ', const Color(0xFFFF1493), LucideIcons.smartphone),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text(amount, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);
    final textColor = isLight ? Colors.black : Colors.white;
    final bgColor = isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05);
    final dividerColor = isLight ? Colors.black12 : Colors.white12;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cài đặt', style: TextStyle(color: textColor, fontSize: 32 * textScale, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Chế độ Sáng (Light Mode)', style: TextStyle(color: textColor, fontSize: 16 * textScale)),
                    secondary: Icon(LucideIcons.sun, color: textColor),
                    value: isLight,
                    onChanged: (val) => ref.read(lightModeProvider.notifier).state = val,
                    activeColor: const Color(0xFF00E676),
                  ),
                  Divider(color: dividerColor),
                  ListTile(
                    title: Text('Cỡ chữ', style: TextStyle(color: textColor, fontSize: 16 * textScale)),
                    subtitle: Slider(
                      value: textScale,
                      min: 0.8,
                      max: 1.5,
                      activeColor: const Color(0xFF00E676),
                      onChanged: (val) => ref.read(textSizeProvider.notifier).state = val,
                    ),
                    leading: Icon(LucideIcons.aArrowUp, color: textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});
  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const WalletScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = ref.watch(lightModeProvider);
    final bgColor = isLight ? Colors.white : const Color(0xFF12141C);
    final navBgColor = isLight ? Colors.white.withOpacity(0.8) : const Color(0xFF12141C).withOpacity(0.8);
    final navBorderColor = isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 90,
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: navBgColor,
                    border: Border(top: BorderSide(color: navBorderColor, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(LucideIcons.home, 0, isLight),
                      _buildNavItem(LucideIcons.pieChart, 1, isLight),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OcrScannerScreen())),
                        child: Container(
                          height: 56, width: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: const Icon(LucideIcons.scanLine, color: Color(0xFF12141C), size: 24),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
                      ),
                      _buildNavItem(LucideIcons.wallet, 2, isLight),
                      _buildNavItem(LucideIcons.settings, 3, isLight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isLight) {
    final isSelected = _selectedIndex == index;
    final activeColor = isLight ? Colors.black : Colors.white;
    final inactiveColor = isLight ? Colors.black38 : const Color(0xFF8E8E93);
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(icon, color: isSelected ? activeColor : inactiveColor),
    );
  }
}
