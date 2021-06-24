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

  late final AnimationController _controllerCar = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<AlignmentGeometry> _offsetAnimationCar =
      Tween<AlignmentGeometry>(
    begin: Alignment(0.0, 0.0),
    end: Alignment(2.0, 0.0),
  ).animate(CurvedAnimation(
    parent: _controllerCar,
    curve: Curves.elasticInOut,
  ));

  @override
  void dispose() {
    _controller.dispose();
    _controllerCar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlignTransition(
            alignment: _offsetAnimationCar,
            child: RotationTransition(
                turns: _animation,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ImageIcon(
                    AssetImage('images/wheel.png'),
                    size: 90.0,
                    color: Colors.white,
                  ),
                ))),
        Center(
          child: RotationTransition(
              turns: _animation,
              child: ImageIcon(
                AssetImage('images/wheel.png'),
                size: 90.0,
                color: Colors.white24,
              )),
        )
      ],
    );
  }
}
