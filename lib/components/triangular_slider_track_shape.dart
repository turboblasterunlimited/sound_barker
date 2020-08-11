import 'package:flutter/material.dart';

class TriangularSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  final color;
  const TriangularSliderTrackShape(this.color,
      {this.disabledThumbGapWidth = 2.0});

  final double disabledThumbGapWidth;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    Paint _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final first = Offset(trackRect.left, trackRect.center.dy);
    final second = Offset(trackRect.right, trackRect.top);
    final third = Offset(trackRect.right, trackRect.bottom);

    var path = Path();
    path.moveTo(first.dx, first.dy);
    path.lineTo(second.dx, second.dy);
    path.lineTo(third.dx, third.dy);
    path.close();
    context.canvas.drawPath(path, _paint);
  }
}
