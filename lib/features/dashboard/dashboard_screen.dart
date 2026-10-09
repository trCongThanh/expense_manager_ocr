import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../ocr/ocr_scanner_screen.dart';

// Provider quản lý trạng thái Chế độ riêng tư (Privacy Mode)
final privacyModeProvider = StateProvider<bool>((ref) => false);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(privacyModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF12141C),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(ref, isPrivacyMode),
                _buildChartSection(),
                _buildRecentTransactions(isPrivacyMode),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
            _buildGlassBottomNav(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, bool isPrivacyMode) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng chi tiêu tháng này',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    // Nút Privacy Mode
                    GestureDetector(
                      onTap: () {
                        ref.read(privacyModeProvider.notifier).state = !isPrivacyMode;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isPrivacyMode ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: isPrivacyMode ? const Color(0xFF00E676) : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        LucideIcons.bell,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildObscurableText(
              '14.500.000 ₫',
              isObscured: isPrivacyMode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(duration: 500.ms).moveY(begin: 10, end: 0),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSummaryCard(
                  title: 'Thu nhập',
                  amount: '+25.000.000',
                  color: const Color(0xFF00E676),
                  icon: LucideIcons.arrowDownLeft,
                  isPrivacyMode: isPrivacyMode,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                const SizedBox(width: 16),
                _buildSummaryCard(
                  title: 'Đã chi',
                  amount: '-14.500.000',
                  color: const Color(0xFFFF5252),
                  icon: LucideIcons.arrowUpRight,
                  isPrivacyMode: isPrivacyMode,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
    required bool isPrivacyMode,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            _buildObscurableText(
              amount,
              isObscured: isPrivacyMode,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 1),
                    FlSpot(2, 4),
                    FlSpot(3, 2),
                    FlSpot(4, 5),
                    FlSpot(5, 3),
                  ],
                  isCurved: true,
                  color: const Color(0xFF00E676),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF00E676).withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }

  Widget _buildRecentTransactions(bool isPrivacyMode) {
    final transactions = [
      {
        'title': 'Highlands Coffee',
        'category': 'Ăn uống',
        'date': 'Hôm nay',
        'amount': '-65.000 ₫',
        'icon': LucideIcons.coffee
      },
      {
        'title': 'GrabBike',
        'category': 'Di chuyển',
        'date': 'Hôm nay',
        'amount': '-42.000 ₫',
        'icon': LucideIcons.car
      },
      {
        'title': 'Tiền lương',
        'category': 'Thu nhập',
        'date': 'Hôm qua',
        'amount': '+25.000.000 ₫',
        'icon': LucideIcons.wallet
      },
      {
        'title': 'Shopee Supermarket',
        'category': 'Mua sắm',
        'date': '2 ngày trước',
        'amount': '-1.250.000 ₫',
        'icon': LucideIcons.shoppingBag
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16, top: 8),
                child: Text(
                  'Giao dịch gần đây',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms);
            }
            final item = transactions[index - 1];
            final isIncome = item['amount'].toString().startsWith('+');
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item['category']} • ${item['date']}',
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildObscurableText(
                    item['amount'] as String,
                    isObscured: isPrivacyMode,
                    style: TextStyle(
                      color: isIncome ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100))).slideY(begin: 0.2);
          },
          childCount: transactions.length + 1,
        ),
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
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.home, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.pieChart, color: Color(0xFF8E8E93)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OcrScannerScreen(),
                      ),
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.wallet, color: Color(0xFF8E8E93)),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.settings, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper để làm mờ Text khi bật Privacy Mode
  Widget _buildObscurableText(String text, {required bool isObscured, required TextStyle style}) {
    if (!isObscured) {
      return Text(text, style: style);
    }
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Text(text, style: style),
    );
  }
}
