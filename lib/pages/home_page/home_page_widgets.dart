import 'package:flutter/material.dart';
import 'package:taluxi_common/taluxi_common.dart';

class CustomElevatedButton extends StatefulWidget {
  const CustomElevatedButton({
    required this.child,
    super.key,
    this.elevation = 6,
    this.width,
    this.height,
    this.onTap,
  });

  final Widget child;
  final double? width;
  final double? height;
  final double? elevation;
  final VoidCallback? onTap;

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  double? buttonElevation;
  bool buttonIsDown = false;
  final double buttonRadius = 12;

  @override
  void initState() {
    super.initState();
    buttonElevation = widget.elevation;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        width: widget.width,
        height: widget.height != null
            ? widget.height! + (widget.elevation ?? 0)
            : null,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0A500), Color(0xFFDF7E00)],
                  ),
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
              ),
            ),
            AnimatedPositioned(
              bottom: buttonElevation,
              duration: const Duration(milliseconds: 350),
              onEnd: () {
                if (buttonIsDown) widget.onTap?.call();
                setState(() {
                  buttonElevation = widget.elevation;
                  buttonIsDown = false;
                });
              },
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: mainLinearGradient,
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
      // onTap: widget.onTap,
      onTapDown: (_) => setState(() {
        buttonElevation = 0;
        buttonIsDown = true;
        // widget.onTap();
      }),
    );
  }
}
