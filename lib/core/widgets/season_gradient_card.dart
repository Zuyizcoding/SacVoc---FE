/// SeasonGradientCard — Thẻ kết quả với gradient theo mùa sắc.
///
/// Tuân thủ:
///   - ui-ux-design #1: Glassmorphism — BackdropFilter + gradient overlay
///   - ui-ux-design #2: 8pt grid — padding 24, borderRadius 16, spacing 8/16
///   - ui-ux-design #3: Colored shadow (opacity thấp) thay vì bóng đen cứng
///   - ui-ux-design #4: Typography phân cấp rõ ràng
///   - SHOULD S5: Season gradient background
///
/// Sử dụng:
///   SeasonGradientCard(
///     subSeason: 'Soft Autumn',
///     primarySeason: 'Autumn',
///     confidence: 0.87,
///     explanation: 'Tone da của bạn có undertone ấm...',
///     gradientFrom: Color(0xFFE9C46A),
///     gradientTo: Color(0xFF8B4513),
///   )
import 'dart:ui';
import 'package:flutter/material.dart';

class SeasonGradientCard extends StatelessWidget {
  final String subSeason;
  final String primarySeason;
  final double confidence;
  final String explanation;
  final Color gradientFrom;
  final Color gradientTo;

  const SeasonGradientCard({
    super.key,
    required this.subSeason,
    required this.primarySeason,
    required this.confidence,
    required this.explanation,
    required this.gradientFrom,
    required this.gradientTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Colored shadow (ui-ux-design #3)
      // Bóng dùng màu gradient chính với opacity thấp — cảm giác nổi tự nhiên
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // bội 8
        boxShadow: [
          BoxShadow(
            color: gradientFrom.withOpacity(0.3),  // bóng màu, KHÔNG đen
            blurRadius: 24,                         // bội 8
            offset: const Offset(0, 8),             // bội 8
            spreadRadius: 0,
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ─── Layer 1: Gradient Background ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24), // bội 8
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradientFrom, gradientTo],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Primary Season Badge ───
                  _buildSeasonBadge(),
                  const SizedBox(height: 16),  // bội 8

                  // ─── Sub-season Title (Heading — Bold) ───
                  Text(
                    subSeason,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,  // ui-ux-design #4: Heading Bold
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),  // bội 8

                  // ─── Explanation (Body — Regular) ───
                  Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,  // ui-ux-design #4: Body Regular
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 16),  // bội 8

                  // ─── Confidence Row (Caption — Light) ───
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),  // bội 8
                      Text(
                        'Độ tự tin: ${(confidence * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,  // ui-ux-design #4: Caption Light
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Layer 2: Glassmorphism Overlay (ui-ux-design #1) ───
            Positioned(
              top: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,  // bội 8
                      vertical: 8,     // bội 8
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: Text(
                      _getSeasonEmoji(primarySeason),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Badge hiển thị mùa chính (Spring/Summer/Autumn/Winter)
  Widget _buildSeasonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // bội 8
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24), // bội 8
      ),
      child: Text(
        _translateSeason(primarySeason),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Dịch tên mùa sang tiếng Việt
  String _translateSeason(String season) {
    const map = {
      'Spring': 'MÙA XUÂN',
      'Summer': 'MÙA HÈ',
      'Autumn': 'MÙA THU',
      'Winter': 'MÙA ĐÔNG',
    };
    return map[season] ?? season.toUpperCase();
  }

  /// Emoji đại diện mùa
  String _getSeasonEmoji(String season) {
    const map = {
      'Spring': '🌸',
      'Summer': '☀️',
      'Autumn': '🍂',
      'Winter': '❄️',
    };
    return map[season] ?? '✨';
  }
}
