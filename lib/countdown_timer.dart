import 'dart:async';

import 'package:flutter/material.dart';

import 'ddl_list.dart';

class Countdown {
  // 单例公开访问点
  factory Countdown() => _sharedInstance();

  // 静态私有成员，没有初始化
  static final Countdown _instance = Countdown._();
  static bool continueCountdown = false;
  static GlobalKey<DDLListState> ddlListKey = GlobalKey();
  Timer timer = Timer(const Duration(seconds: 5), () {});
  bool setHeight = false;
  bool immediately = false;
  bool reload = false;

  // 私有构造函数
  Countdown._();

  // 静态、同步、私有访问点
  static Countdown _sharedInstance() {
    return _instance;
  }

  // 公开方法
  void start() {
    continueCountdown = true;
    timer.cancel();
    countdown();
  }

  void stop() {
    continueCountdown = false;
  }

  void countdown() {
    timer.cancel();
    if (continueCountdown) {
      updateCountdown();
      var now = DateTime.now().millisecondsSinceEpoch % 1000;
      int duration = 1000 - now;
      timer = Timer(Duration(milliseconds: immediately ? 0 : duration), () {
        countdown();
      });
    }
  }

  void setGlobalKey(GlobalKey<DDLListState> key) {
    ddlListKey = key;
  }

  void updateCountdown() {
    if (ddlListKey.currentState != null &&
        ddlListKey.currentState?.ddlList != null &&
        (ddlListKey.currentState?.ddlList.isNotEmpty ?? false)) {
      if (!setHeight) {
        List<dynamic> ddlList = ddlListKey.currentState?.ddlList ?? [];
        for (int i = 0; i < ddlList.length; i++) {
          Column column =
              (ddlListKey.currentState?.countdownList.children[i] as Column);
          GlobalKey key =
              ((((column.children[1] as GestureDetector).child as Stack)
                          .children[0] as AnimatedContainer)
                      .child as Wrap)
                  .children[3]
                  .key as GlobalKey;
          if (key.currentContext != null &&
              key.currentContext?.size != null &&
              key.currentContext?.size?.height != null) {
            double? height = key.currentContext?.size?.height;
            if (height == null || height < 80) {
              setHeight = false;
              break;
            }
            ddlListKey.currentState?.ddlList[i]
                .addAll({'height': height + 50 + 100});
            setHeight = true;
          }
          if (i == ddlList.length - 1) {
            ddlListKey.currentState?.reload(false);
          }
        }
      } else {
        ddlListKey.currentState?.reload(() {
          if (reload) {
            reload = false;
            print('reload: true');
            return true;
          }
          print('reload: false');
          return false;
        }());
      }
    }
  }
}
