import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ArcChooser extends StatefulWidget {
  const ArcChooser({required this.arcSelectedCallback, super.key});

  final ArcSelectedCallback arcSelectedCallback;

  @override
  State<StatefulWidget> createState() => ChooserState();
}

class ChooserState extends State<ArcChooser>
    with SingleTickerProviderStateMixin {
  late Offset centerPoint;

  double userAngle = 0;

  double startAngle = 0;
  bool autoAnimationIsRunning = false;
  static double center = 270;
  static double centerInRadians = degreeToRadians(center);
  static double angle = 45;

  static double angleInRadians = degreeToRadians(angle);
  static double angleInRadiansByTwo = angleInRadians / 2;
  static double centerItemAngle = degreeToRadians(center - (angle / 2));
  late List<ArcItem> arcItems;

  Timer? timer;
  late AnimationController animation;
  double animationStart = 0;
  double animationEnd = 0;

  int currentPosition = 0;

  Offset startingPoint = Offset.zero;
  Offset endingPoint = Offset.zero;

  static double degreeToRadians(double degree) {
    return degree * (pi / 180);
  }

  static double radianToDegrees(double radian) {
    return radian * (180 / pi);
  }

  @override
  void initState() {
    super.initState();
    arcItems = <ArcItem>[];

    arcItems
      ..add(
        ArcItem(
          'MÉDIOCRE',
          [const Color(0xFFF9D976), const Color(0xfff39f86)],
          angleInRadiansByTwo + userAngle,
        ),
      )
      ..add(
        ArcItem(
          'CORRECT',
          [const Color(0xFF21e1fa), const Color(0xff3bb8fd)],
          angleInRadiansByTwo + userAngle + angleInRadians,
        ),
      )
      ..add(
        ArcItem(
          'BONNE',
          [const Color(0xFF3ee98a), const Color(0xFF41f7c7)],
          angleInRadiansByTwo + userAngle + (2 * angleInRadians),
        ),
      )
      ..add(
        ArcItem(
          'MAUVAISE',
          [const Color(0xFFfe0944), const Color(0xFFfeae96)],
          angleInRadiansByTwo + userAngle + (3 * angleInRadians),
        ),
      )
      ..add(
        ArcItem(
          'MÉDIOCRE',
          [const Color(0xFFF9D976), const Color(0xfff39f86)],
          angleInRadiansByTwo + userAngle + (4 * angleInRadians),
        ),
      )
      ..add(
        ArcItem(
          'CORRECT',
          [const Color(0xFF21e1fa), const Color(0xff3bb8fd)],
          angleInRadiansByTwo + userAngle + (5 * angleInRadians),
        ),
      )
      ..add(
        ArcItem(
          'BONNE',
          [const Color(0xFF3ee98a), const Color(0xFF41f7c7)],
          angleInRadiansByTwo + userAngle + (6 * angleInRadians),
        ),
      )
      ..add(
        ArcItem(
          'MAUVAISE',
          [const Color(0xFFfe0944), const Color(0xFFfeae96)],
          angleInRadiansByTwo + userAngle + (7 * angleInRadians),
        ),
      );

    animation = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    animation.addListener(() {
      userAngle = lerpDouble(
            animationStart,
            animationEnd,
            animation.value,
          ) ??
          0;
      setState(() {
        for (var i = 0; i < arcItems.length; i++) {
          arcItems[i].startAngle =
              angleInRadiansByTwo + userAngle + (i * angleInRadians);
        }
      });
    });

    animationEnd = 1;
    timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      autoAnimationIsRunning = true;
      animationEnd *= -1;
      await animation.animateTo(
        0.5,
        duration: const Duration(milliseconds: 600),
      );
      await animation.animateBack(
        0,
        duration: const Duration(milliseconds: 600),
      );
      // animationEnd = -1;
      // await animation.animateTo(0.5, duration: Duration(milliseconds: 500));
      // await animation.animateBack(0, duration: Duration(milliseconds: 500));
    });
  }

  @override
  void dispose() {
    animation.dispose();
    timer?.cancel();
    arcItems.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final centerX = MediaQuery.of(context).size.width / 2;
    final centerY = MediaQuery.of(context).size.height * 1.5;
    centerPoint = Offset(centerX, centerY);

    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        if (autoAnimationIsRunning) {
          autoAnimationIsRunning = false;
          timer?.cancel();
          animation.reset();
          animationEnd = 0;
        }
        startingPoint = details.globalPosition;
        final deltaX = centerPoint.dx - details.globalPosition.dx;
        final deltaY = centerPoint.dy - details.globalPosition.dy;
        startAngle = atan2(deltaY, deltaX);
      },
      onPanUpdate: _onDragUpdate,
      onPanEnd: (DragEndDetails details) {
        //find top arc item with Magic!!
        final rightToLeft = startingPoint.dx < endingPoint.dx;

//        Animate it from this values
        animationStart = userAngle;
        if (rightToLeft) {
          animationEnd += angleInRadians;
          currentPosition--;
          if (currentPosition < 0) {
            currentPosition = arcItems.length - 1;
          }
        } else {
          animationEnd -= angleInRadians;
          currentPosition++;
          if (currentPosition >= arcItems.length) {
            currentPosition = 0;
          }
        }

        widget.arcSelectedCallback.call(
          currentPosition,
          arcItems[(currentPosition >= (arcItems.length - 1))
              ? 0
              : currentPosition + 1],
        );

        animation.forward(from: 0);
      },
      child: CustomPaint(
        size: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.width * 1 / 1.5,
        ),
        painter: ChooserPainter(arcItems, angleInRadians),
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    endingPoint = details.globalPosition;
    final deltaX = centerPoint.dx - details.globalPosition.dx;
    final deltaY = centerPoint.dy - details.globalPosition.dy;
    final freshAngle = atan2(deltaY, deltaX);
    userAngle += freshAngle - startAngle;
    setState(() {
      for (var i = 0; i < arcItems.length; i++) {
        arcItems[i].startAngle =
            angleInRadiansByTwo + userAngle + (i * angleInRadians);
      }
    });
    startAngle = freshAngle;
  }
}

// draw the arc and other stuff
class ChooserPainter extends CustomPainter {
  ChooserPainter(this.arcItems, this.angleInRadians) {
    angleInRadiansByTwo = angleInRadians / 2;

    angleInRadians1 = angleInRadians / 6;
    angleInRadians2 = angleInRadians / 3;
    angleInRadians3 = angleInRadians * 4 / 6;
    angleInRadians4 = angleInRadians * 5 / 6;
  }

  //debugging Paint
  final debugPaint = Paint()
    ..color = Colors.red.withAlpha(100) //0xFFF9D976
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final linePaint = Paint()
    ..color = Colors.black.withAlpha(65) //0xFFF9D976
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square;

  final whitePaint = Paint()
    ..color = Colors.white //0xFFF9D976
    ..strokeWidth = 1.0
    ..style = PaintingStyle.fill;

  List<ArcItem> arcItems;
  double angleInRadians;
  late double angleInRadiansByTwo;
  late double angleInRadians1;
  late double angleInRadians2;
  late double angleInRadians3;
  late double angleInRadians4;

  @override
  void paint(Canvas canvas, Size size) {
    //common calc
    final centerX = size.width / 2;
    final centerY = size.height * 1.6;
    final center = Offset(centerX, centerY);
    final radius = sqrt((size.width * size.width) / 2);

//    var mainRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
//    canvas.drawRect(mainRect, debugPaint);

    //for white arc at bottom
    final leftX = centerX - radius;
    final topY = centerY - radius;
    final rightX = centerX + radius;
    final bottomY = centerY + radius;

    //for items
    final radiusItems = radius * 1.5;
    final leftX2 = centerX - radiusItems;
    final topY2 = centerY - radiusItems;
    final rightX2 = centerX + radiusItems;
    final bottomY2 = centerY + radiusItems;

    //for shadow
    final radiusShadow = radius * 1.13;
    final leftX3 = centerX - radiusShadow;
    final topY3 = centerY - radiusShadow;
    final rightX3 = centerX + radiusShadow;
    final bottomY3 = centerY + radiusShadow;

    final radiusText = radius * 1.30;
    final radius4 = radius * 1.12;
    final radius5 = radius * 1.06;
    final arcRect = Rect.fromLTRB(leftX2, topY2, rightX2, bottomY2);

    final dummyRect = Rect.fromLTRB(0, 0, size.width, size.height);

    canvas.clipRect(dummyRect);

    for (var i = 0; i < arcItems.length; i++) {
      canvas.drawArc(
        arcRect,
        arcItems[i].startAngle,
        angleInRadians,
        true,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            colors: arcItems[i].colors,
          ).createShader(dummyRect),
      );

      //Draw text
      final span = TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 32,
          color: Colors.white,
        ),
        text: arcItems[i].text,
      );
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      //find additional angle to make text in center
      final f = tp.width / 2;
      final t = sqrt((radiusText * radiusText) + (f * f));

      final additionalAngle = acos(
        ((t * t) + (radiusText * radiusText) - (f * f)) / (2 * t * radiusText),
      );

      final tX = center.dx +
          radiusText *
              cos(
                arcItems[i].startAngle + angleInRadiansByTwo - additionalAngle,
              ); // - (tp.width/2);
      final tY = center.dy +
          radiusText *
              sin(
                arcItems[i].startAngle + angleInRadiansByTwo - additionalAngle,
              ); // - (tp.height/2);

      canvas
        ..save()
        ..translate(tX, tY)
//      canvas.rotate(arcItems[i].startAngle + angleInRadiansByTwo);
        ..rotate(
          arcItems[i].startAngle +
              angleInRadians +
              angleInRadians +
              angleInRadiansByTwo,
        );
      tp.paint(canvas, Offset.zero);
      canvas
        ..restore()

        //big lines
        ..drawLine(
          Offset(
            center.dx + radius4 * cos(arcItems[i].startAngle),
            center.dy + radius4 * sin(arcItems[i].startAngle),
          ),
          center,
          linePaint,
        )
        ..drawLine(
          Offset(
            center.dx +
                radius4 * cos(arcItems[i].startAngle + angleInRadiansByTwo),
            center.dy +
                radius4 * sin(arcItems[i].startAngle + angleInRadiansByTwo),
          ),
          center,
          linePaint,
        )

        //small lines
        ..drawLine(
          Offset(
            center.dx + radius5 * cos(arcItems[i].startAngle + angleInRadians1),
            center.dy + radius5 * sin(arcItems[i].startAngle + angleInRadians1),
          ),
          center,
          linePaint,
        )
        ..drawLine(
          Offset(
            center.dx + radius5 * cos(arcItems[i].startAngle + angleInRadians2),
            center.dy + radius5 * sin(arcItems[i].startAngle + angleInRadians2),
          ),
          center,
          linePaint,
        )
        ..drawLine(
          Offset(
            center.dx + radius5 * cos(arcItems[i].startAngle + angleInRadians3),
            center.dy + radius5 * sin(arcItems[i].startAngle + angleInRadians3),
          ),
          center,
          linePaint,
        )
        ..drawLine(
          Offset(
            center.dx + radius5 * cos(arcItems[i].startAngle + angleInRadians4),
            center.dy + radius5 * sin(arcItems[i].startAngle + angleInRadians4),
          ),
          center,
          linePaint,
        );
    }

    //shadow
    final shadowPath = Path()
      ..addArc(
        Rect.fromLTRB(leftX3, topY3, rightX3, bottomY3),
        ChooserState.degreeToRadians(180),
        ChooserState.degreeToRadians(180),
      );
    canvas
      ..drawShadow(shadowPath, Colors.black, 18, true)

      //bottom white arc
      ..drawArc(
        Rect.fromLTRB(leftX, topY, rightX, bottomY),
        ChooserState.degreeToRadians(180),
        ChooserState.degreeToRadians(180),
        true,
        whitePaint,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

typedef ArcSelectedCallback = void Function(int position, ArcItem arcitem);

class ArcItem {
  ArcItem(this.text, this.colors, this.startAngle);

  String text;
  List<Color> colors;
  double startAngle;
}
