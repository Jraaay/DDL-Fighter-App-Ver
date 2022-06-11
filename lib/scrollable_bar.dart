import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_ddl_form.dart';
import 'countdown_timer.dart';
import 'ddl_list.dart';
import 'logo_title.dart';
import 'user_info.dart';

class ScrollableTabs extends StatefulWidget {
  const ScrollableTabs({Key? key}) : super(key: key);

  @override
  State<ScrollableTabs> createState() => _ScrollableTabsState();
}

class _ScrollableTabsState extends State<ScrollableTabs>
    with TickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<DDLListState> ddlListKey = GlobalKey();
    Countdown countdown = Countdown();
    countdown.setGlobalKey(ddlListKey);
    // 初始化数据
    return Scaffold(
        // 创建底部导航栏
        bottomNavigationBar: Material(
            child: SizedBox(
                height: 60.0,
                child: Theme(
                  data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: TabBar(
                    controller: _controller,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    indicator: const BoxDecoration(
                      color: Color.fromRGBO(64, 158, 255, 1),
                    ),
                    tabs: const <Tab>[
                      Tab(
                          text: 'DDL',
                          iconMargin: EdgeInsets.all(5),
                          icon: Icon(
                            Icons.event_available,
                          )),
                      Tab(
                          text: '我的',
                          iconMargin: EdgeInsets.all(5),
                          icon: Icon(
                            Icons.account_circle_outlined,
                          )),
                    ],
                    indicatorWeight: 0.1,
                  ),
                ))),
        // 创建内容区域
        body: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: TabBarView(
            // 允许左右滑动切换页面
            controller: _controller,
            children: [
              // 允许下拉刷新
              RefreshIndicator(
                child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: ListView(children: [
                      const Center(child: LogoTitle()),
                      Center(child: DDLList(key: ddlListKey)),
                      const SizedBox(height: 20),
                    ])),
                onRefresh: () async {
                  ddlListKey.currentState?.reload(true);
                },
              ),
              const UserInfo(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            SharedPreferences.getInstance().then((value) {
              if ((value.getString('token') ?? '') != '') {
                // 判断是否登录
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            AddDDLForm(ddlListKey)));
              } else {
                Fluttertoast.cancel();
                Fluttertoast.showToast(
                    msg: '请先登录',
                    gravity: ToastGravity.BOTTOM,
                    textColor: Colors.white,
                    backgroundColor: Colors.grey,
                    fontSize: 16.0);
                _controller.animateTo(1);
              }
            });
          },
          child: const Icon(Icons.add),
        ));
  }
}
