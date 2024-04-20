import 'package:flutter/material.dart';

import 'review_page_widgets/arc_chooser.dart';
import 'review_page_widgets/smile_painter.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  int slideValue = 200;
  int lastAnimPosition = 2;
  double _herperTextOpacity = 1;

  late AnimationController animationController;

  List<ArcItem> arcItems = <ArcItem>[];

  late ArcItem badArcItem;
  late ArcItem ughArcItem;
  late ArcItem okArcItem;
  late ArcItem goodArcItem;
  late Color startColor;
  late Color endColor;

  @override
  void initState() {
    super.initState();

    badArcItem = ArcItem(
      'MAUVAISE',
      [const Color(0xFFfe0944), const Color(0xFFfeae96)],
      0,
    );
    ughArcItem = ArcItem(
      'MÉDIOCRE',
      [const Color(0xFFF9D976), const Color(0xfff39f86)],
      0,
    );
    okArcItem = ArcItem(
      'CORRECT',
      [const Color(0xFF21e1fa), const Color(0xff3bb8fd)],
      0,
    );
    goodArcItem =
        ArcItem('BONNE', [const Color(0xFF3ee98a), const Color(0xFF41f7c7)], 0);

    arcItems
      ..add(badArcItem)
      ..add(ughArcItem)
      ..add(okArcItem)
      ..add(goodArcItem);

    startColor = const Color(0xFF21e1fa);
    endColor = const Color(0xff3bb8fd);

    animationController = AnimationController(
      value: 0,
      upperBound: 400,
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {
          slideValue = animationController.value.toInt();

          double ratio;

          if (slideValue <= 100) {
            ratio = animationController.value / 100;
            startColor =
                Color.lerp(badArcItem.colors[0], ughArcItem.colors[0], ratio)!;
            endColor =
                Color.lerp(badArcItem.colors[1], ughArcItem.colors[1], ratio)!;
          } else if (slideValue <= 200) {
            ratio = (animationController.value - 100) / 100;
            startColor =
                Color.lerp(ughArcItem.colors[0], okArcItem.colors[0], ratio)!;
            endColor =
                Color.lerp(ughArcItem.colors[1], okArcItem.colors[1], ratio)!;
          } else if (slideValue <= 300) {
            ratio = (animationController.value - 200) / 100;
            startColor =
                Color.lerp(okArcItem.colors[0], goodArcItem.colors[0], ratio)!;
            endColor =
                Color.lerp(okArcItem.colors[1], goodArcItem.colors[1], ratio)!;
          } else if (slideValue <= 400) {
            ratio = (animationController.value - 300) / 100;
            startColor =
                Color.lerp(goodArcItem.colors[0], badArcItem.colors[0], ratio)!;
            endColor =
                Color.lerp(goodArcItem.colors[1], badArcItem.colors[1], ratio)!;
          }
        });
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: MediaQuery.of(context).padding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Comment qualifieriez-vous l'expérience fournie "
                      'par le conducteur ?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    (MediaQuery.of(context).size.width / 2.3) + 60,
                  ),
                  painter: SmilePainter(slideValue),
                ),
                AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: _herperTextOpacity,
                  child: const Text(
                    'Faites tourner le cercle pour choisir',
                    textScaler: TextScaler.linear(1.2),
                  ),
                ),
                Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ArcChooser(
                        arcSelectedCallback: (int pos, ArcItem item) {
                          setState(() {
                            _herperTextOpacity = 0;
                          });
                          var animPosition = pos - 2;
                          if (animPosition > 3) {
                            animPosition = animPosition - 4;
                          }

                          if (animPosition < 0) {
                            animPosition = 4 + animPosition;
                          }

                          if (lastAnimPosition == 3 && animPosition == 0) {
                            animationController.animateTo(4 * 100.0);
                          } else if (lastAnimPosition == 0 &&
                              animPosition == 3) {
                            animationController
                              ..forward(from: 4 * 100.0)
                              ..animateTo(animPosition * 100.0);
                          } else if (lastAnimPosition == 0 &&
                              animPosition == 1) {
                            animationController
                              ..forward(from: 0)
                              ..animateTo(animPosition * 100.0);
                          } else {
                            animationController.animateTo(animPosition * 100.0);
                          }
                          lastAnimPosition = animPosition;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Material(
                        borderRadius: BorderRadius.circular(25),
                        elevation: 8,
                        child: InkWell(
                          onTap: () {
                            debugPrint(lastAnimPosition.toString());
                          },
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [startColor, endColor],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'VALIDER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 42,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
