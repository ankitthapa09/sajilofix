import 'package:flutter/material.dart';

class GradientOutlineInputBorder extends OutlineInputBorder {
  final Gradient gradient;

  const GradientOutlineInputBorder({
    required this.gradient,
    super.borderRadius,
    super.borderSide,
    super.gapPadding,
  });

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    // This app uses external labels (e.g. LabeledField) so we can ignore the
    // label gap and paint a full outline.
    final adjustedRect = rect.deflate(borderSide.width / 2);
    final rrect = borderRadius.toRRect(adjustedRect);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderSide.width
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  GradientOutlineInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
    Gradient? gradient,
  }) {
    return GradientOutlineInputBorder(
      gradient: gradient ?? this.gradient,
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      gapPadding: gapPadding ?? this.gapPadding,
    );
  }

  @override
  OutlineInputBorder scale(double t) {
    return GradientOutlineInputBorder(
      gradient: gradient,
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
      gapPadding: gapPadding * t,
    );
  }
}
