/// ColorPaletteRow — Hiển thị 6 màu hex với animation stagger.
///
/// Tuân thủ:
///   - ui-ux-design #2: 8pt grid spacing
///   - ui-ux-design #3: bóng đổ mềm cho mỗi ô màu
///   - Tính năng #19: Bảng màu cá nhân 6 hex
///
/// Sử dụng:
///   ColorPaletteRow(
///     hexColors: ['#8B4513', '#D2691E', '#A0522D', '#CD853F', '#DEB887', '#F4A460'],
///   )
import 'package:flutter/material.dart';

class ColorPaletteRow extends StatefulWidget {
  final List<String> hexColors;

  const ColorPaletteRow({
    super.key,
    required this.hexColors,
  });

  @override
  State<ColorPaletteRow> createState() => _ColorPaletteRowState();
}

class _ColorPaletteRowState extends State<ColorPaletteRow>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Stagger animation: mỗi màu delay 100ms (SHOULD — result reveal)
    _controllers = List.generate(
      widget.hexColors.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutBack))
        .toList();

    // Bắt đầu stagger
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.hexColors.length, (index) {
        final color = _hexToColor(widget.hexColors[index]);

        return ScaleTransition(
          scale: _animations[index],
          child: Container(
            width: 48,   // bội 8
            height: 48,  // bội 8
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              // Bóng đổ mềm bằng chính màu đó (ui-ux-design #3)
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,   // bội 8
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Convert hex string → Color
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
