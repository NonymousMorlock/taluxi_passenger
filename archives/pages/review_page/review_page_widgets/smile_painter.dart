import 'dart:ui';

import 'package:flutter/material.dart';

class SmilePainter extends CustomPainter {
  SmilePainter(this.slideValue);

  //debugging Paint
  final debugPaint = Paint()
    ..color = Colors.grey //0xFFF9D976
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final whitePaint = Paint()
    ..color = Colors.white //0xFFF9D976
    ..style = PaintingStyle.fill;

  int slideValue = 200;

  late ReviewState badReview;
  late ReviewState ughReview;
  late ReviewState okReview;
  late ReviewState goodReview;

  late double centerCenter;
  late double leftCenter;
  late double rightCenter;

  late double smileHeight;
  late double halfWidth;
  late double halfHeight;

  late double radius;
  late double diameter;
  late double startingY;
  late double startingX;

  late double endingX;
  late double endingY;

  late double oneThirdOfDia;

  late double oneThirdOfDiaByTwo;

  late double eyeRadius;

  late double eyeRadiusbythree;

  late double eyeRadiusbytwo;

  Size? lastSize;

  late ReviewState currentState;

  @override
  void paint(Canvas canvas, Size size) {
    if (size != lastSize) {
      lastSize = size;

      smileHeight = size.width / 2;
      halfWidth = size.width / 2;
      halfHeight = smileHeight / 2;

      radius = 0.0;
      eyeRadius = 10.0;
      if (smileHeight < size.width) {
        radius = halfHeight - 16.0;
      } else {
        radius = halfWidth - 16.0;
      }
      eyeRadius = radius / 6.5;
      eyeRadiusbythree = eyeRadius / 3;
      eyeRadiusbytwo = eyeRadius / 2;

      diameter = radius * 2;
      //left top corner
      startingX = halfWidth - radius;
      startingY = halfHeight - radius;

      oneThirdOfDia = diameter / 3;
      oneThirdOfDiaByTwo = oneThirdOfDia / 2;

      //bottom right corner
      endingX = halfWidth + radius;
      endingY = halfHeight + radius;

      final leftSmileX = startingX + (radius / 2);

      badReview = ReviewState(
        Offset(leftSmileX, endingY - (oneThirdOfDiaByTwo * 1.5)),
        Offset(
          startingX + oneThirdOfDia,
          startingY + radius + oneThirdOfDiaByTwo,
        ),
        Offset(endingX - radius, startingY + radius + oneThirdOfDiaByTwo),
        Offset(
          endingX - oneThirdOfDia,
          startingY + radius + oneThirdOfDiaByTwo,
        ),
        Offset(endingX - (radius / 2), endingY - (oneThirdOfDiaByTwo * 1.5)),
        const Color(0xFFfe0944),
        const Color(0xFFfeae96),
        const Color(0xFFfe5c6e),
        '',
      );

      ughReview = ReviewState(
        Offset(leftSmileX, endingY - (radius / 2)),
        Offset(diameter, endingY - oneThirdOfDia),
        Offset(endingX - radius, endingY - oneThirdOfDia),
        Offset(endingX - (radius / 2), endingY - oneThirdOfDia),
        Offset(endingX - (radius / 2), endingY - oneThirdOfDia),
        const Color(0xFFF9D976),
        const Color(0xfff39f86),
        const Color(0xFFf6bc7e),
        '',
      );

      okReview = ReviewState(
        Offset(leftSmileX, endingY - (oneThirdOfDiaByTwo * 1.5)),
        Offset(diameter, endingY - (oneThirdOfDiaByTwo * 1.5)),
        Offset(endingX - radius, endingY - (oneThirdOfDiaByTwo * 1.5)),
        Offset(startingX + radius, endingY - (oneThirdOfDiaByTwo * 1.5)),
        Offset(endingX - (radius / 2), endingY - (oneThirdOfDiaByTwo * 1.5)),
        const Color(0xFF21e1fa),
        const Color(0xff3bb8fd),
        const Color(0xFF28cdfc),
        '',
      );

      goodReview = ReviewState(
        Offset(startingX + (radius / 2), endingY - (oneThirdOfDiaByTwo * 2)),
        Offset(
          startingX + oneThirdOfDia,
          startingY + (diameter - oneThirdOfDiaByTwo),
        ),
        Offset(endingX - radius, startingY + (diameter - oneThirdOfDiaByTwo)),
        Offset(
          endingX - oneThirdOfDia,
          startingY + (diameter - oneThirdOfDiaByTwo),
        ),
        Offset(endingX - (radius / 2), endingY - (oneThirdOfDiaByTwo * 2)),
        const Color(0xFF3ee98a),
        const Color(0xFF41f7c7),
        const Color(0xFF41f7c6),
        '',
      );

      //get max width of text, that is width of GOOD text
      final spanGood = TextSpan(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 52,
          color: okReview.titleColor,
        ),
        text: '',
      );
      final tpGood =
          TextPainter(text: spanGood, textDirection: TextDirection.ltr)
            ..layout();
      final goodWidth = tpGood.width;
      final halfGoodWidth = goodWidth / 2;

      //center points of BIG labels
      centerCenter = halfWidth;
      leftCenter = centerCenter - goodWidth;
      rightCenter = centerCenter + goodWidth;
    }

    if (slideValue <= 100) {
      tweenText(badReview, ughReview, slideValue / 100, canvas);
    } else if (slideValue <= 200) {
      tweenText(ughReview, okReview, (slideValue - 100) / 100, canvas);
    } else if (slideValue <= 300) {
      tweenText(okReview, goodReview, (slideValue - 200) / 100, canvas);
    } else if (slideValue <= 400) {
      tweenText(goodReview, badReview, (slideValue - 300) / 100, canvas);
    }

    //draw the outer circle------------------------------------------

    final centerPoint = Offset(halfWidth, halfHeight);
    final circlePaint = genGradientPaint(
      Rect.fromCircle(
        center: centerPoint,
        radius: radius,
      ),
      currentState.startColor,
      currentState.endColor,
      PaintingStyle.stroke,
    )..strokeCap = StrokeCap.round;

    canvas
      ..drawCircle(centerPoint, radius, circlePaint)
      //---------------------------------------------------------------

      //draw smile curve with path ------------------------------------------
      ..drawPath(getSmilePath(currentState), circlePaint);

    //---------------------------------------------------------------

    //draw eyes---------------------------------------------------
    //ele calc
    final leftEyeX = startingX + oneThirdOfDia;
    final eyeY = startingY + (oneThirdOfDia + oneThirdOfDiaByTwo / 4);
    final rightEyeX = startingX + (oneThirdOfDia * 2);

    final leftEyePoint = Offset(leftEyeX, eyeY);
    final rightEyePoint = Offset(rightEyeX, eyeY);

    final leftEyePaintFill = genGradientPaint(
      Rect.fromCircle(center: leftEyePoint, radius: eyeRadius),
      currentState.startColor,
      currentState.endColor,
      PaintingStyle.fill,
    );

    final rightEyePaintFill = genGradientPaint(
      Rect.fromCircle(center: rightEyePoint, radius: eyeRadius),
      currentState.startColor,
      currentState.endColor,
      PaintingStyle.fill,
    );

    canvas
      ..drawCircle(leftEyePoint, eyeRadius, leftEyePaintFill)
      ..drawCircle(rightEyePoint, eyeRadius, rightEyePaintFill);

    //draw the edges of BAD Review
    if (slideValue <= 100 || slideValue > 300) {
      var diff = -1.toDouble();
      var tween = -1.toDouble();

      if (slideValue <= 100) {
        diff = slideValue / 100;
        tween = lerpDouble(
          eyeY - (eyeRadiusbythree * 0.6),
          eyeY - eyeRadius,
          diff,
        )!;
      } else if (slideValue > 300) {
        diff = (slideValue - 300) / 100;
        tween = lerpDouble(
          eyeY - eyeRadius,
          eyeY - (eyeRadiusbythree * 0.6),
          diff,
        )!;
      }

      final polygonPath = <Offset>[
        Offset(leftEyeX - eyeRadiusbytwo, eyeY - eyeRadius),
        Offset(leftEyeX + eyeRadius, tween),
        Offset(leftEyeX + eyeRadius, eyeY - eyeRadius),
      ];

      final clipPath = Path()..addPolygon(polygonPath, true);

      canvas.drawPath(clipPath, whitePaint);

      final polygonPath2 = <Offset>[
        Offset(rightEyeX + eyeRadiusbytwo, eyeY - eyeRadius),
        Offset(rightEyeX - eyeRadius, tween),
        Offset(rightEyeX - eyeRadius, eyeY - eyeRadius),
      ];

      final clipPath2 = Path()..addPolygon(polygonPath2, true);

      canvas.drawPath(clipPath2, whitePaint);
    }

    //draw the balls of UGH Review
    if (slideValue > 0 && slideValue < 200) {
      var diff = -1.toDouble();
      var leftTweenX = -1.toDouble();
      var leftTweenY = -1.toDouble();

      var rightTweenX = -1.toDouble();
      // double rightTweenY = -1.0;

      if (slideValue <= 100) {
//      bad to ugh
        diff = slideValue / 100;
        leftTweenX = lerpDouble(leftEyeX - eyeRadius, leftEyeX, diff)!;
        leftTweenY = lerpDouble(eyeY - eyeRadius, eyeY, diff)!;

        rightTweenX = lerpDouble(rightEyeX + eyeRadius, rightEyeX, diff)!;
        // rightTweenY =
        lerpDouble(eyeY, eyeY - (eyeRadius + eyeRadiusbythree), diff);
      } else {
//      ugh to ok
        diff = (slideValue - 100) / 100;

        leftTweenX = lerpDouble(leftEyeX, leftEyeX - eyeRadius, diff)!;
        leftTweenY = lerpDouble(eyeY, eyeY - eyeRadius, diff)!;

        rightTweenX = lerpDouble(rightEyeX, rightEyeX + eyeRadius, diff)!;
        // rightTweenY =
        lerpDouble(eyeY - (eyeRadius + eyeRadiusbythree), eyeY, diff);
      }

      canvas
        ..drawOval(
          Rect.fromLTRB(
            leftEyeX - (eyeRadius + eyeRadiusbythree),
            eyeY - (eyeRadius + eyeRadiusbythree),
            leftTweenX,
            leftTweenY,
          ),
          whitePaint,
        )
        ..drawOval(
          Rect.fromLTRB(
            rightTweenX,
            eyeY,
            rightEyeX + (eyeRadius + eyeRadiusbythree),
            eyeY - (eyeRadius + eyeRadiusbythree),
          ),
          whitePaint,
        );
    }

    //---------------------------------------------------------------

    //drawing stuff for debugging-----------------------------------

//    canvas.drawRect(
//        Rect.fromLTRB(0.0, 0.0, size.width, smileHeight), debugPaint);
//    canvas.drawRect(
//        Rect.fromLTRB(startingX, startingY, endingX, endingY), debugPaint);
//
//    canvas.drawLine(
//        Offset(startingX, startingY), Offset(endingX, endingY), debugPaint);
//    canvas.drawLine(
//        Offset(endingX, startingY), Offset(startingX, endingY), debugPaint);
//    canvas.drawLine(Offset(startingX + radius, startingY),
//        Offset(startingX + radius, endingY), debugPaint);
//    canvas.drawLine(Offset(startingX, startingY + radius),
//        Offset(endingX, startingY + radius), debugPaint);
//
//    //horizontal lines
//    canvas.drawLine(Offset(startingX, startingY + oneThirdOfDia),
//        Offset(endingX, startingY + oneThirdOfDia), debugPaint);
//    canvas.drawLine(Offset(startingX, endingY - oneThirdOfDia),
//        Offset(endingX, endingY - oneThirdOfDia), debugPaint);
//    canvas.drawLine(Offset(startingX, endingY - oneThirdOfDiaByTwo),
//        Offset(endingX, endingY - oneThirdOfDiaByTwo), debugPaint);
//
//    //vertical lines
//    canvas.drawLine(Offset(startingX + oneThirdOfDiaByTwo, startingY),
//        Offset(startingX + oneThirdOfDiaByTwo, endingY), debugPaint);
//    canvas.drawLine(Offset(startingX + oneThirdOfDia, startingY),
//        Offset(startingX + oneThirdOfDia, endingY), debugPaint);
//    canvas.drawLine(Offset(endingX - oneThirdOfDia, startingY),
//        Offset(endingX - oneThirdOfDia, endingY), debugPaint);
//    canvas.drawLine(Offset(endingX - oneThirdOfDiaByTwo, startingY),
//        Offset(endingX - oneThirdOfDiaByTwo, endingY), debugPaint);
    //--------------------------------------------------------------
  }

  void tweenText(
    ReviewState centerReview,
    ReviewState rightReview,
    double diff,
    Canvas canvas,
  ) {
    currentState = ReviewState.lerp(centerReview, rightReview, diff);

    final spanCenter = TextSpan(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 52,
        color: centerReview.titleColor.withAlpha(255 - (255 * diff).round()),
      ),
      text: centerReview.title,
    );
    final tpCenter =
        TextPainter(text: spanCenter, textDirection: TextDirection.ltr);

    final spanRight = TextSpan(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 52,
        color: rightReview.titleColor.withAlpha((255 * diff).round()),
      ),
      text: rightReview.title,
    );
    final tpRight =
        TextPainter(text: spanRight, textDirection: TextDirection.ltr);

    tpCenter.layout();
    tpRight.layout();

    final centerOffset =
        Offset(centerCenter - (tpCenter.width / 2), smileHeight);
    final centerToLeftOffset =
        Offset(leftCenter - (tpCenter.width / 2), smileHeight);

    final rightOffset = Offset(rightCenter - (tpRight.width / 2), smileHeight);
    final rightToCenterOffset =
        Offset(centerCenter - (tpRight.width / 2), smileHeight);

    tpCenter.paint(
      canvas,
      Offset.lerp(centerOffset, centerToLeftOffset, diff)!,
    );
    tpRight.paint(canvas, Offset.lerp(rightOffset, rightToCenterOffset, diff)!);
  }

  Path getSmilePath(ReviewState state) {
    return Path()..moveTo(state.leftOffset.dx, state.leftOffset.dy)
      ..quadraticBezierTo(
      state.leftHandle.dx,
      state.leftHandle.dy,
      state.centerOffset.dx,
      state.centerOffset.dy,
    )
      ..quadraticBezierTo(
      state.rightHandle.dx,
      state.rightHandle.dy,
      state.rightOffset.dx,
      state.rightOffset.dy,
    );
  }

  Paint genGradientPaint(
    Rect rect,
    Color startColor,
    Color endColor,
    PaintingStyle style,
  ) {
    final Gradient gradient = LinearGradient(
      colors: <Color>[
        startColor,
        endColor,
      ],
    );

    return Paint()
      ..strokeWidth = 10.0
      ..style = style
      ..shader = gradient.createShader(rect);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ReviewState {
  ReviewState(
    this.leftOffset,
    this.leftHandle,
    this.centerOffset,
    this.rightHandle,
    this.rightOffset,
    this.startColor,
    this.endColor,
    this.titleColor,
    this.title,
  );

  //create new state between given two states.
  factory ReviewState.lerp(ReviewState start, ReviewState end, double ratio) {
    final startColor = Color.lerp(start.startColor, end.startColor, ratio);
    final endColor = Color.lerp(start.endColor, end.endColor, ratio);

    return ReviewState(
      Offset.lerp(start.leftOffset, end.leftOffset, ratio)!,
      Offset.lerp(start.leftHandle, end.leftHandle, ratio)!,
      Offset.lerp(start.centerOffset, end.centerOffset, ratio)!,
      Offset.lerp(start.rightHandle, end.rightHandle, ratio)!,
      Offset.lerp(start.rightOffset, end.rightOffset, ratio)!,
      startColor!,
      endColor!,
      start.titleColor,
      start.title,
    );
  }

  //smile points
  Offset leftOffset;
  Offset centerOffset;
  Offset rightOffset;

  Offset leftHandle;
  Offset rightHandle;

  String title;
  Color titleColor;

  Color startColor;
  Color endColor;
}
