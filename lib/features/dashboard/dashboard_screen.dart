import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../ocr/ocr_scanner_screen.dart';
import 'main_screen.dart'; 

final privacyModeProvider = StateProvider<bool>((ref) => false);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(privacyModeProvider);
    final isLight = ref.watch(lightModeProvider);
    final textScale = ref.watch(textSizeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Phụ thuộc vào MainScreen
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(ref, isPrivacyMode, isLight, textScale),
            _buildChartSection(isLight),
            _buildRecentTransactions(ref, isPrivacyMode, isLight, textScale),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, bool isPrivacyMode, bool isLight, double textScale) {
    final textColor = isLight ? Colors.black : Colors.white;
    final secondaryTextColor = isLight ? Colors.black54 : const Color(0xFF8E8E93);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng số dư',
                      style: TextStyle(color: secondaryTextColor, fontSize: 16 * textScale, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    _buildObscurableText(
                      '18.500.000 đ',
                      isObscured: isPrivacyMode,
                      style: TextStyle(color: textColor, fontSize: 36 * textScale, fontWeight: FontWeight.bold, letterSpacing: -1),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                
                Container(
                  decoration: BoxDecoration(
                    color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(isPrivacyMode ? LucideIcons.eyeOff : LucideIcons.eye, color: textColor),
                    onPressed: () => ref.read(privacyModeProvider.notifier).state = !isPrivacyMode,
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Thu nhập',
                    amount: '+25.000.000 đ',
                    icon: LucideIcons.arrowDownLeft,
                    color: const Color(0xFF00E676),
                    isObscured: isPrivacyMode,
                    isLight: isLight,
                    textScale: textScale,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Chi tiêu',
                    amount: '-6.500.000 đ',
                    icon: LucideIcons.arrowUpRight,
                    color: const Color(0xFFFF5252),
                    isObscured: isPrivacyMode,
                    isLight: isLight,
                    textScale: textScale,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isObscured,
    required bool isLight,
    required double textScale,
  }) {
    final cardBg = isLight ? color.withOpacity(0.1) : color.withOpacity(0.1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: isLight ? Colors.black54 : const Color(0xFF8E8E93), fontSize: 14 * textScale, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _buildObscurableText(
            amount,
            isObscured: isObscured,
            style: TextStyle(color: color, fontSize: 18 * textScale, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isLight) {
    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLight ? Colors.black.withOpacity(0.02) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(24),
        ),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const titles = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          titles[value.toInt()],
                          style: TextStyle(color: isLight ? Colors.black54 : const Color(0xFF8E8E93), fontSize: 12),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3)],
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
    );
  }

  Widget _buildRecentTransactions(WidgetRef ref, bool isPrivacyMode, bool isLight, double textScale) {
    final textColor = isLight ? Colors.black : Colors.white;
    final secondaryTextColor = isLight ? Colors.black54 : const Color(0xFF8E8E93);
    final itemBgColor = isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.03);
    final iconBgColor = isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05);

    final transactions = ref.watch(transactionsProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 8),
                child: Text(
                  'Giao dịch gần đây',
                  style: TextStyle(color: textColor, fontSize: 18 * textScale, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn(delay: 400.ms);
            }
            final item = transactions[index - 1];
            final isIncome = item['amount'].toString().startsWith('+');
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: itemBgColor, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(16)),
                    child: Icon(item['icon'] as IconData, color: textColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String, style: TextStyle(color: textColor, fontSize: 16 * textScale, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${item['category']} • ${item['date']}', style: TextStyle(color: secondaryTextColor, fontSize: 12 * textScale)),
                      ],
                    ),
                  ),
                  _buildObscurableText(
                    item['amount'] as String,
                    isObscured: isPrivacyMode,
                    style: TextStyle(
                      color: isIncome ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                      fontSize: 16 * textScale,
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

  Widget _buildObscurableText(String text, {required bool isObscured, required TextStyle style}) {
    if (!isObscured) return Text(text, style: style);
    return ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Text(text, style: style));
  }
}
