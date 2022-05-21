import 'dart:math';

import 'package:flutter/material.dart';

class FlipNumText extends StatefulWidget {
  final int num;
  final int maxNum;
  final int _stateNum;

  const FlipNumText(this.num, this.maxNum, this._stateNum, {Key? key})
      : super(key: key);

  @override
  FlipNumTextState createState() => FlipNumTextState();
}

class _MyBounceOutCurve1 extends Curve {
  const _MyBounceOutCurve1._();

  @override
  double transformInternal(double t) {
    return _bounce1(t);
  }

  double _bounce1(double t) {
    if (t < 0.5) {
      return 0;
    }
    t = t * 2 - 1;
    if (t < sqrt(2) - 1) {
      return (t + 1) * (t + 1) - 1;
    } else {
      return (3 + 2 * sqrt(2)) *
              (t + 1 - (1 + 1 / sqrt(2))) *
              (t + 1 - (1 + 1 / sqrt(2))) +
          0.5;
    }
  }
}

class _MyBounceOutCurve2 extends Curve {
  const _MyBounceOutCurve2._();

  @override
  double transformInternal(double t) {
    return _bounce2(t);
  }

  double _bounce2(double t) {
    if (t > 0.5) {
      return 1;
    }
    return 4 * t * t;
  }
}

class FlipNumTextState extends State<FlipNumText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation1;
  late Animation _animation2;
  static const Curve myBounceOut1 = _MyBounceOutCurve1._();
  static const Curve myBounceOut2 = _MyBounceOutCurve2._();

  final double _zeroAngle = 0.0001;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() {
        setState(() {});
      });

    _animation1 = Tween(begin: pi / 2, end: _zeroAngle)
        .animate(CurvedAnimation(parent: _controller, curve: myBounceOut1));
    _animation2 = Tween(begin: _zeroAngle, end: pi / 2)
        .animate(CurvedAnimation(parent: _controller, curve: myBounceOut2));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.num != widget._stateNum) {
      _controller.forward();
    }
    Color color = Colors.white;
    return Container(
      padding: const EdgeInsets.all(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: <Widget>[
                  ClipRectText(widget.num, Alignment.topCenter, color),
                ] +
                (widget.num != widget._stateNum
                    ? [
                        Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.006)
                              ..rotateX(_animation2.value),
                            alignment: Alignment.bottomCenter,
                            child: ClipRectText(
                                widget._stateNum, Alignment.topCenter, color)),
                      ]
                    : []),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 0.75),
          ),
          Stack(
            children: <Widget>[
                  ClipRectText(widget._stateNum, Alignment.bottomCenter, color),
                ] +
                (widget.num != widget._stateNum
                    ? [
                        Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.006)
                              ..rotateX(-_animation1.value),
                            alignment: Alignment.topCenter,
                            child: ClipRectText(
                                widget.num, Alignment.bottomCenter, color)),
                      ]
                    : []),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ClipRectText extends StatelessWidget {
  final int _value;
  final Alignment _alignment;
  final Color _color;

  const ClipRectText(this._value, this._alignment, this._color, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = 20;
    return ClipRect(
      child: Align(
        alignment: _alignment,
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          alignment: Alignment.center,
          width: width,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(64, 158, 255, 1),
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Text(
            "$_value",
            style: TextStyle(
              fontSize: width - 3,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
