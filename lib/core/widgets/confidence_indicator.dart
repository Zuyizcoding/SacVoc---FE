/// ConfidenceIndicator — Thanh hiển thị % tự tin của AI.
///
/// Tuân thủ:
///   - ui-ux-design #2: 8pt grid — height 8, borderRadius 8, padding 16
///   - ui-ux-design #3: Nền #FAFAFA, bóng mềm
///   - ui-ux-design #4: Typography phân cấp
///   - SHOULD S3: Xanh (≥80%) / Vàng (60-79%) / Đỏ (<60%)
///
/// Sử dụng:
///   ConfidenceIndicator(confidence: 0.87, label: 'Độ tự tin')
import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  /// Giá trị 0.0 → 1.0 (VD: 0.87 = 87%)
  final double confidence;

  /// Nhãn hiển thị bên trái (mặc định: "Độ tự tin AI")
  final String label;

  /// Hiện giá trị % bên phải hay không
  final bool showPercentage;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.label = 'Độ tự tin AI',
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toInt();
    final color = _getColor();
    final backgroundColor = color.withOpacity(0.12);

    return Container(
      // 8pt grid: padding 16
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),        // ui-ux-design #3: nền sáng
        borderRadius: BorderRadius.circular(16), // bội 8
        // Bóng đổ mềm — opacity thấp (ui-ux-design #3)
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,              // bội 8
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Label + Percentage ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label (Body — Regular | ui-ux-design #4)
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                ),
              ),
              // Percentage (Heading — SemiBold | ui-ux-design #4)
              if (showPercentage)
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8), // bội 8

          // ─── Progress Bar ───
          ClipRRect(
            borderRadius: BorderRadius.circular(8), // bội 8
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 8,   // bội 8
                  width: double.infinity,
                  color: backgroundColor,
                ),
                // Filled portion — animated
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  height: 8,  // bội 8
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: confidence.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        // Gradient nhẹ cho thanh — đẹp hơn flat color
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.7),
                            color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // bội 8

          // ─── Description text (Caption — Light | ui-ux-design #4) ───
          Text(
            _getDescription(percentage),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Màu theo mức confidence (SHOULD S3)
  ///   ≥ 80% → Xanh lá (kết quả đáng tin cậy)
  ///   60-79% → Vàng cam (khá chắc)
  ///   < 60% → Đỏ (ảnh kém, cần chụp lại)
  Color _getColor() {
    if (confidence >= 0.8) return const Color(0xFF4CAF50);  // Green
    if (confidence >= 0.6) return const Color(0xFFFF9800);  // Orange
    return const Color(0xFFF44336);                          // Red
  }

  /// Mô tả tiếng Việt theo mức confidence
  String _getDescription(int percentage) {
    if (confidence >= 0.8) return 'Kết quả đáng tin cậy ✓';
    if (confidence >= 0.6) return 'Kết quả tham khảo — chụp ảnh rõ hơn sẽ chính xác hơn';
    return 'Ảnh chưa đủ rõ — hãy chụp lại với ánh sáng tốt hơn';
  }
}
