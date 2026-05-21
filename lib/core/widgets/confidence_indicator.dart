// ConfidenceIndicator — Thanh hiển thị % tự tin của AI.
//
// Tuân thủ:
//   - ui-ux-design #2: 8pt grid — height 8, borderRadius 8, padding 16
//   - ui-ux-design #3: Nền #FAFAFA, bóng mềm
//   - ui-ux-design #4: Typography phân cấp
//   - SHOULD S3: Xanh / Vàng / Đỏ theo mức confidence
//
// Sử dụng:
//   ConfidenceIndicator(confidence: 0.87, label: 'Độ tự tin')
import 'package:flutter/material.dart';

import '../theme/figma_palette.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final percentage = (confidence * 100).toInt();
    final color = _getColor();
    final backgroundColor = color.withValues(alpha: 0.12);

    return Container(
      // 8pt grid: padding 16
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16), // bội 8
        // Bóng đổ mềm — opacity thấp (ui-ux-design #3)
        boxShadow: [
          BoxShadow(
            color: FigmaPalette.shadowColor.withValues(alpha: 0.16),
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
                  color: scheme.onSurface.withValues(alpha: 0.70),
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
                            color.withValues(alpha: 0.70),
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
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  /// Màu theo mức confidence cho demo:
  ///   ≥ 80% → Xanh lá (đáng tin cậy)
  ///   45-79% → Vàng cam (best-effort / tham khảo tốt)
  ///   < 45% → Đỏ (độ chắc chắn thấp)
  Color _getColor() {
    if (confidence >= 0.8) return FigmaPalette.success;
    if (confidence >= 0.45) return FigmaPalette.warning;
    return FigmaPalette.danger;
  }

  /// Mô tả tiếng Việt theo mức confidence
  String _getDescription(int percentage) {
    if (confidence >= 0.8) return 'Kết quả đáng tin cậy ✓';
    if (confidence >= 0.6) return 'Kết quả tham khảo tốt cho demo — ảnh rõ hơn sẽ giúp chắc chắn hơn';
    if (confidence >= 0.45) {
      return 'Kết quả best-effort vẫn dùng được để tham khảo, chưa cần chụp lại ngay';
    }
    return 'Độ chắc chắn còn thấp — chỉ nên chụp lại nếu bạn cần kết quả chính xác hơn';
  }
}
