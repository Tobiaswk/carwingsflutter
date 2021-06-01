import 'package:flutter/material.dart';

class RotatingWheelProgressIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RotatingWheelProgressIndicatorState();
  }
}

class _RotatingWheelProgressIndicatorState
    extends State<RotatingWheelProgressIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
        turns: _animation,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: ImageIcon(
            AssetImage('images/wheel.png'),
            size: 90.0,
            color: Colors.white,
          ),
        ));
  }
}
