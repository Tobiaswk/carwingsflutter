import 'package:flutter/material.dart';

class WidgetPulse extends StatefulWidget {
  final Widget _widget;
  final double _fromSize;
  final double _toSize;
  final Duration _duration;

  @override
  _WidgetPulseState createState() =>
      _WidgetPulseState(_widget, _fromSize, _toSize, _duration);

  WidgetPulse(this._widget, this._fromSize, this._toSize, this._duration);
}

class _WidgetPulseState extends State<WidgetPulse>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  Widget _widget;
  final double _fromSize;
  final double _toSize;
  final Duration _duration;

  _WidgetPulseState(this._widget, this._fromSize, this._toSize, this._duration);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _animationController.repeat(reverse: true);
        }
      });

    _animation =
        Tween(begin: _fromSize, end: _toSize).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: _widget,
      builder: (BuildContext context, Widget _widget) {
        return Transform.scale(
          scale: _animation.value,
          child: _widget,
        );
      },
    );
  }
}
