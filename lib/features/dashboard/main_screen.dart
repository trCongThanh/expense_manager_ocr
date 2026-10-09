import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../ocr/ocr_scanner_screen.dart';
import 'dashboard_screen.dart';

// Screens tạm thời
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Màn hình Phân tích (Analytics)', style: TextStyle(color: Colors.white, fontSize: 20)));
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Màn hình Ví (Wallet)', style: TextStyle(color: Colors.white, fontSize: 20)));
}

// Provider quản lý chế độ (Demo)
final lightModeProvider = StateProvider<bool>((ref) => false);
final textSizeProvider = StateProvider<double>((ref) => 1.0);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cài đặt', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Chế độ Sáng (Light Mode)', style: TextStyle(color: Colors.white, fontSize: 16 * textScale)),
                    secondary: const Icon(LucideIcons.sun, color: Colors.white),
                    value: isLight,
                    onChanged: (val) => ref.read(lightModeProvider.notifier).state = val,
                    activeColor: const Color(0xFF00E676),
                  ),
                  const Divider(color: Colors.white12),
                  ListTile(
                    title: Text('Cỡ chữ', style: TextStyle(color: Colors.white, fontSize: 16 * textScale)),
                    subtitle: Slider(
                      value: textScale,
                      min: 0.8,
                      max: 1.5,
                      activeColor: const Color(0xFF00E676),
                      onChanged: (val) => ref.read(textSizeProvider.notifier).state = val,
                    ),
                    leading: const Icon(LucideIcons.aArrowUp, color: Colors.white),
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const WalletScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12141C),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          _buildGlassBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 90,
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF12141C).withOpacity(0.7),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(LucideIcons.home, 0),
                _buildNavItem(LucideIcons.pieChart, 1),
                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OcrScannerScreen()),
                    );
                  },
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.scanLine,
                      color: Color(0xFF12141C),
                      size: 24,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
                ),
                
                _buildNavItem(LucideIcons.wallet, 2),
                _buildNavItem(LucideIcons.settings, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF8E8E93),
      ),
    );
  }
}
