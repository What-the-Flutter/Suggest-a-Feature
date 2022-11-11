import 'package:flutter/material.dart';

final Paint _hidingGradientPaint = Paint();
final Paint _hidingSolidPaint = Paint();
const _hidingGradientHeight = 56.0;

void renderHidings({
  required Canvas canvas,
  required Size size,
  required BuildContext context,
  required double contentMarginTop,
  required double contentMarginBottom,
  required Color backgroundColor,
}) {
  final topGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundColor, backgroundColor.withOpacity(0.0)],
  );
  final bottomGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundColor.withOpacity(0.0), backgroundColor],
  );
  final topRectGradient = Rect.fromLTWH(0, contentMarginTop - 2, size.width, _hidingGradientHeight);
  final bottomRectGradient = Rect.fromLTWH(
    0,
    size.height - _hidingGradientHeight - contentMarginBottom,
    size.width,
    _hidingGradientHeight + 2,
  );

  canvas.drawRect(
    topRectGradient,
    _hidingGradientPaint..shader = topGradient.createShader(topRectGradient),
  );
  canvas.drawRect(
    bottomRectGradient,
    _hidingGradientPaint..shader = bottomGradient.createShader(bottomRectGradient),
  );

  final topRectSolid = Rect.fromLTWH(0, 0, size.width, contentMarginTop);
  final bottomRectSolid = Rect.fromLTWH(
    0,
    size.height - contentMarginBottom,
    size.width,
    contentMarginBottom,
  );

  _hidingSolidPaint.color = backgroundColor;

  canvas.drawRect(topRectSolid, _hidingSolidPaint);
  canvas.drawRect(bottomRectSolid, _hidingSolidPaint);
}
