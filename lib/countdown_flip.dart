import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/flip_num_text.dart';

import 'countdown_timer.dart';
import 'ddl_list.dart';

class CountdownFlip extends StatefulWidget {
  final int endTime;
  bool selfChange = false;
  int status = 0;
  GlobalKey<DDLListState> ddlListKey;

  CountdownFlip(this.endTime, this.status, this.selfChange, this.ddlListKey,
      {Key? key})
      : super(key: key);

  @override
  State<CountdownFlip> createState() => _CountdownFlipState();
}

class _CountdownFlipState extends State<CountdownFlip> {
  late Timer timer = Timer.periodic(const Duration(seconds: 0), (Timer t) {
    if (widget.selfChange) {
      setState(() {
        widget.status = widget.endTime - t.tick;
      });
    }
  });

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    int dur =
        ((widget.endTime - currentTime.millisecondsSinceEpoch / 1000)).floor();
    List<int> durs = [
      (dur % (3600 * 24) / 3600 / 10).floor(),
      (dur % (3600 * 24) / 3600 % 10).floor(),
      (dur % 3600 / 60 / 10).floor(),
      (dur % 3600 / 60 % 10).floor(),
      (dur % 60 / 10).floor(),
      (dur % 60 % 10).floor()
    ];
    int dur_1 = ((widget.endTime - (currentTime.millisecondsSinceEpoch / 1000)))
            .floor() +
        1;
    List<int> durs_1 = [
      (dur_1 % (3600 * 24) / 3600 / 10).floor(),
      (dur_1 % (3600 * 24) / 3600 % 10).floor(),
      (dur_1 % 3600 / 60 / 10).floor(),
      (dur_1 % 3600 / 60 % 10).floor(),
      (dur_1 % 60 / 10).floor(),
      (dur_1 % 60 % 10).floor()
    ];
    int day = (dur / (3600 * 24)).floor();
    if (dur < 0) {
      Countdown countdown = Countdown();
      countdown.reload = true;
      print("set true");
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          StatelessCountdownFlip(0),
          Text("天"),
          StatelessCountdownFlip(0),
          StatelessCountdownFlip(0),
          Text("时"),
          StatelessCountdownFlip(0),
          StatelessCountdownFlip(0),
          Text("分"),
          StatelessCountdownFlip(0),
          StatelessCountdownFlip(0),
          Text("秒")
        ],
      );
    }
    for (int i = 0; i < '$day'.length; i++) {
      durs.add(int.parse('$day'.substring(i, i + 1)));
    }
    int day_1 = (dur_1 / (3600 * 24)).floor();
    for (int i = 0; i < '$day_1'.length; i++) {
      durs_1.add(int.parse('$day_1'.substring(i, i + 1)));
    }
    if (widget.status == 1) {
      return widget.endTime != 3376656000
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                    for (var i = 6; i < durs.length; i++)
                      FlipNumText(durs[i], 9, durs_1[i]),
                  ] +
                  [const Text("天")] +
                  [
                    FlipNumText(durs[0], 2, durs_1[0]),
                    FlipNumText(durs[1], 3, durs_1[1]),
                  ] +
                  [const Text("时")] +
                  [
                    FlipNumText(durs[2], 5, durs_1[2]),
                    FlipNumText(durs[3], 9, durs_1[3]),
                  ] +
                  [const Text("分")] +
                  [
                    FlipNumText(durs[4], 5, durs_1[4]),
                    FlipNumText(durs[5], 9, durs_1[5]),
                  ] +
                  [const Text("秒")],
            )
          : const SizedBox(height: 0);
    } else if (widget.status == 0) {
      timer.cancel();
      timer = Timer(const Duration(milliseconds: 100), () {
        setState(() {
          widget.selfChange = true;
          widget.status = 1;
        });
      });
      return widget.endTime != 3376656000
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                    for (var i = 6; i < durs.length; i++)
                      StatelessCountdownFlip(durs_1[i]),
                  ] +
                  [const Text("天")] +
                  [
                    StatelessCountdownFlip(durs_1[0]),
                    StatelessCountdownFlip(durs_1[1]),
                  ] +
                  [const Text("时")] +
                  [
                    StatelessCountdownFlip(durs_1[2]),
                    StatelessCountdownFlip(durs_1[3]),
                  ] +
                  [const Text("分")] +
                  [
                    StatelessCountdownFlip(durs_1[4]),
                    StatelessCountdownFlip(durs_1[5]),
                  ] +
                  [const Text("秒")],
            )
          : const SizedBox(height: 0);
    }
    return const SizedBox(height: 0);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CountdownFlip oldWidget) {
    if (widget.selfChange) {
      widget.status = 0;
    }
    super.didUpdateWidget(oldWidget);
  }
}

class StatelessCountdownFlip extends StatelessWidget {
  final int _num;
  const StatelessCountdownFlip(this._num, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    return Container(
      padding: const EdgeInsets.all(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRectText(_num, Alignment.topCenter, color),
          const Padding(
            padding: EdgeInsets.only(top: 0.75),
          ),
          ClipRectText(_num, Alignment.bottomCenter, color),
        ],
      ),
    );
  }
}
