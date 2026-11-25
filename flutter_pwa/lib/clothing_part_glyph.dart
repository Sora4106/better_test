import 'package:flutter/material.dart';

class ClothingVisibilityButton extends StatelessWidget {
  const ClothingVisibilityButton({
    super.key,
    required this.part,
    required this.label,
    required this.visible,
    required this.onPressed,
  });

  final String part;
  final String label;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      tooltip: visible ? '隱藏於提示詞：$label' : '已隱藏於提示詞，點擊恢復：$label',
      isSelected: visible,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(40),
        shape: const CircleBorder(),
        backgroundColor:
            visible ? colors.secondaryContainer : colors.surfaceContainerHigh,
      ),
      icon: ClothingPartGlyph(
        part: part,
        color: visible ? colors.onSecondaryContainer : colors.onSurfaceVariant,
        strikeColor: visible ? null : colors.error,
      ),
    );
  }
}

/// Clothing pictograms share a 24 × 24 outline grid.
class ClothingPartGlyph extends StatelessWidget {
  const ClothingPartGlyph({
    super.key,
    required this.part,
    required this.color,
    this.strikeColor,
  });

  final String part;
  final Color color;
  final Color? strikeColor;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size.square(24),
        painter: _ClothingPartPainter(part, color, strikeColor),
      );
}

class _ClothingPartPainter extends CustomPainter {
  const _ClothingPartPainter(this.part, this.color, this.strikeColor);

  final String part;
  final Color color;
  final Color? strikeColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final ink = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void line(List<double> points, {bool close = false}) {
      final path = Path()..moveTo(points[0], points[1]);
      for (var i = 2; i < points.length; i += 2) {
        path.lineTo(points[i], points[i + 1]);
      }
      if (close) path.close();
      canvas.drawPath(path, ink);
    }

    void oval(double x, double y, double w, double h) =>
        canvas.drawOval(Rect.fromLTWH(x, y, w, h), ink);

    switch (part) {
      case 'top' || 'upper':
        line([
          8,
          4,
          10,
          6,
          14,
          6,
          16,
          4,
          22,
          8,
          19,
          12,
          17,
          10,
          17,
          21,
          7,
          21,
          7,
          10,
          5,
          12,
          2,
          8
        ], close: true);
      case 'sleeves':
        line([8, 4, 12, 6, 7, 19, 2, 17], close: true);
        line([16, 4, 12, 6, 17, 19, 22, 17], close: true);
        line([4, 14, 8, 16]);
        line([16, 16, 20, 14]);
      case 'pants':
        line([6, 3, 18, 3, 20, 21, 14, 21, 12, 10, 10, 21, 4, 21], close: true);
        line([6, 6, 18, 6]);
      case 'shorts':
        line([6, 5, 18, 5, 21, 17, 14, 18, 12, 12, 10, 18, 3, 17], close: true);
        line([5, 8, 19, 8]);
      case 'skirt' || 'lower':
        line([8, 5, 16, 5, 21, 19, 3, 19], close: true);
        line([7, 8, 17, 8]);
        line([10, 9, 8, 18]);
        line([14, 9, 16, 18]);
      case 'onepiece':
        line([7, 3, 10, 3, 12, 6, 14, 3, 17, 3, 15, 10, 21, 21, 3, 21, 9, 10],
            close: true);
        line([9, 10, 15, 10]);
      case 'outerwear':
        line([
          8,
          3,
          12,
          6,
          16,
          3,
          20,
          6,
          22,
          19,
          18,
          19,
          17,
          12,
          17,
          21,
          7,
          21,
          7,
          12,
          6,
          19,
          2,
          19,
          4,
          6
        ], close: true);
        line([8, 3, 12, 11, 16, 3]);
        line([12, 11, 12, 20]);
      case 'underwear':
        line([8, 3, 9, 8, 15, 8, 16, 3, 18, 3, 17, 21, 7, 21, 6, 3],
            close: true);
      case 'bra':
        line([
          3,
          10,
          6,
          5,
          9,
          5,
          12,
          11,
          15,
          5,
          18,
          5,
          21,
          10,
          21,
          15,
          16,
          17,
          12,
          15,
          8,
          17,
          3,
          15
        ], close: true);
      case 'panties':
        line([3, 6, 21, 6, 19, 12, 15, 16, 14, 19, 10, 19, 9, 16, 5, 12],
            close: true);
        line([4, 9, 20, 9]);
      case 'socks' || 'legwear':
        line([10, 3, 18, 3, 17, 15, 10, 21, 6, 21, 4, 18, 5, 15, 10, 12],
            close: true);
        line([10, 6, 18, 6]);
      case 'shoes' || 'footwear':
        line([
          3,
          10,
          6,
          9,
          8,
          13,
          12,
          13,
          13,
          9,
          17,
          12,
          21,
          14,
          22,
          17,
          21,
          20,
          3,
          20
        ], close: true);
        line([3, 17, 22, 17]);
      case 'head' || 'headwear':
        line([5, 15, 7, 7, 10, 5, 14, 5, 17, 7, 19, 15]);
        line([6, 12, 18, 12]);
        oval(2, 14, 20, 5);
      case 'accessory':
        line([5, 4, 4, 7, 6, 13, 10, 16, 14, 16, 18, 13, 20, 7, 19, 4]);
        line([12, 14, 16, 18, 12, 22, 8, 18], close: true);
      case 'weapon':
        line([7, 14, 17, 4, 21, 3, 20, 7, 10, 17], close: true);
        line([5, 12, 12, 19]);
        line([8, 16, 4, 20]);
      case 'armor':
        line([12, 3, 20, 6, 19, 15, 16, 19, 12, 22, 8, 19, 5, 15, 4, 6],
            close: true);
        line([12, 7, 12, 17]);
        line([8, 11, 16, 11]);
      case 'equipment':
        line([3, 8, 21, 8, 21, 20, 3, 20], close: true);
        line([8, 8, 8, 4, 16, 4, 16, 8]);
        line([3, 12, 21, 12]);
      case 'trim' || 'silhouette':
        oval(3, 3, 18, 18);
        oval(7, 8, 2, 2);
        oval(13, 6, 2, 2);
        oval(15, 12, 2, 2);
        oval(8, 14, 3, 3);
      default:
        line([10, 6, 10, 4, 12, 2, 14, 4, 14, 6, 12, 8, 12, 10]);
        line([12, 10, 3, 16, 3, 18, 21, 18, 21, 16], close: true);
    }

    if (strikeColor case final strike?) {
      // A horizontal bar stays distinguishable at small sizes.
      ink
        ..color = strike
        ..strokeWidth = 2.5;
      canvas.drawLine(const Offset(1.5, 12), const Offset(22.5, 12), ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ClothingPartPainter oldDelegate) =>
      part != oldDelegate.part ||
      color != oldDelegate.color ||
      strikeColor != oldDelegate.strikeColor;
}
