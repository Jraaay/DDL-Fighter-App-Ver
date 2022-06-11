import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_app/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_ddl_form.dart';
import 'countdown_flip.dart';
import 'countdown_timer.dart';

class DDLList extends StatefulWidget {
  const DDLList({Key? key}) : super(key: key);

  @override
  State<DDLList> createState() => DDLListState();
}

class DDLListState extends State<DDLList> {
  Column countdownList = Column();
  List ddlList = [];
  bool _refresh = true;
  bool synced = false;
  late Future<SharedPreferences> prefs;

  @override
  void initState() {
    super.initState();
    prefs = SharedPreferences.getInstance();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      Countdown countdown = Countdown();
      countdown.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_refresh) {
      Countdown countdown = Countdown();
      countdown.immediately = true;
      countdown.start();
      Uri uri = Uri.https('ddltest.jray.xyz', '/ddl');
      // 请求获得ddl列表
      return FutureBuilder(
          future: prefs,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              // 如果有登录信息，则请求ddl完成信息列表
              return FutureBuilder<List<dynamic>>(
                future: Dio()
                    .post(uri.toString(),
                        data: snapshot.data.getString('token') != null
                            ? {'token': snapshot.data.getString('token')}
                            : null)
                    .then((response) {
                  if (response.statusCode == 200) {
                    return response.data;
                  } else {
                    return [];
                  }
                }),
                builder: (BuildContext context,
                    AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    List<dynamic> data = snapshot.data as List;
                    data.sort((a, b) => a['endTime'] - b['endTime']);
                    ddlList = data;
                    Countdown countdown = Countdown();
                    countdown.setHeight = false;
                    synced = false;
                    return myBuild();
                  } else {
                    return const CircularProgressIndicator(
                        color: Color.fromRGBO(64, 158, 255, 1), strokeWidth: 3);
                  }
                },
              );
            } else {
              // 如果没有登录信息，则返回loading
              return const CircularProgressIndicator(
                  color: Color.fromRGBO(64, 158, 255, 1), strokeWidth: 3);
            }
          });
    } else {
      // 同上，但是不请求ddl列表
      return FutureBuilder(
          future: prefs,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              SharedPreferences prefs = snapshot.data;
              String? token = prefs.getString("token");
              if (token != null && synced == false) {
                Uri uri = Uri.https('ddltest.jray.xyz', '/getstatus');
                Dio().post(uri.toString(), data: {'token': token}).then((res) {
                  if (res.statusCode == 200) {
                    if (res.data['status'] == 'success') {
                      List ddlList = res.data['data'];
                      prefs.clear();
                      prefs.setString('token', token);
                      for (var i = 0; i < ddlList.length; i++) {
                        prefs.setBool('${ddlList[i]}', true);
                      }
                      synced = true;
                      Countdown countdown = Countdown();
                      countdown.immediately = false;
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                          msg: '同步成功',
                          gravity: ToastGravity.BOTTOM,
                          textColor: Colors.white,
                          backgroundColor: Colors.grey,
                          fontSize: 16.0);
                    } else {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                          msg: res.data['message'],
                          gravity: ToastGravity.BOTTOM,
                          textColor: Colors.white,
                          backgroundColor: Colors.grey,
                          fontSize: 16.0);
                    }
                  } else {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                        msg: '网络错误：${res.statusCode}',
                        gravity: ToastGravity.BOTTOM,
                        textColor: Colors.white,
                        backgroundColor: Colors.grey,
                        fontSize: 16.0);
                  }
                });
              } else {
                Countdown countdown = Countdown();
                countdown.immediately = false;
              }
              return myBuild(prefs: prefs);
            } else {
              return const CircularProgressIndicator(
                  color: Color.fromRGBO(64, 158, 255, 1), strokeWidth: 3);
            }
          });
    }
  }

  Column myBuild({SharedPreferences? prefs}) {
    // 创建ddl列表页面
    var children = <Widget>[];
    for (var item in ddlList) {
      children += [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.only(left: 3),
            child: Text(getTimeFormat(item['endTime']),
                style: const TextStyle(color: Colors.grey)),
          ),
          GestureDetector(
            child: Stack(
                children: <Widget>[
                      AnimatedContainer(
                        constraints: BoxConstraints(
                          maxWidth: 400,
                          maxHeight: (prefs == null ||
                                  prefs.getBool(
                                          (item['id'] as int).toString()) ==
                                      null
                              ? (item['height'] ?? double.infinity)
                              : 70),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(235, 238, 245, 1)),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 232, 232, 232),
                              offset: Offset(0.0, 0.0),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width * 0.8,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: Wrap(
                            clipBehavior: Clip.hardEdge,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.center,
                                child: Text(item['subject'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 20),
                              CountdownFlip(item['endTime'], 0, false,
                                  widget.key as GlobalKey<DDLListState>),
                              Wrap(
                                key: GlobalKey(),
                                clipBehavior: Clip.hardEdge,
                                spacing: 10,
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      "内容：",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '        ${(item['detail'] as String).replaceAll('\n', '\n        ')}',
                                      style: const TextStyle(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: const Text(
                                      "上交方式：",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '        ${item['platform']}',
                                      style: const TextStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    ] +
                    (item['user'] != null
                        ? [
                            Positioned(
                                left: 0.1,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.only(top: 6, left: 1),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                    color: Color.fromRGBO(236, 245, 255, 1),
                                  ),
                                  width: 70,
                                  height: 35,
                                  child: const Text("个人DDL",
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(64, 158, 255, 1))),
                                )),
                            Positioned(
                                right: 10,
                                child: SizedBox(
                                    width: 50,
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('提示'),
                                                content:
                                                    const Text('确定要删除该DDL吗？'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('取消'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('确定'),
                                                    onPressed: () {
                                                      SharedPreferences
                                                              .getInstance()
                                                          .then((value) {
                                                        String token =
                                                            value.getString(
                                                                    'token') ??
                                                                '';
                                                        Uri uri = Uri.https(
                                                            'ddltest.jray.xyz',
                                                            '/delddl');
                                                        Dio().post(
                                                            uri.toString(),
                                                            data: {
                                                              'token': token,
                                                              'ddlId':
                                                                  item['id'],
                                                            }).then((value) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          if (value
                                                                  .statusCode ==
                                                              200) {
                                                            Fluttertoast
                                                                .cancel();
                                                            Fluttertoast.showToast(
                                                                msg: '删除成功',
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                fontSize: 16.0);
                                                            reload(true);
                                                          } else {
                                                            Fluttertoast
                                                                .cancel();
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    '网络错误：${value.statusCode}',
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                fontSize: 16.0);
                                                          }
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: const Text('删除'),
                                    ))),
                            Positioned(
                                right: 60,
                                child: SizedBox(
                                    width: 50,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        AddDDLForm(
                                                          widget.key
                                                              as GlobalKey<
                                                                  DDLListState>,
                                                          dateTime: DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  item['endTime'] *
                                                                      1000),
                                                          title:
                                                              item['subject'],
                                                          description:
                                                              item['detail'],
                                                          platform:
                                                              item['platform'],
                                                          ddlId: item['id'],
                                                          change: true,
                                                        )));
                                      },
                                      child: const Text('修改'),
                                    )))
                          ]
                        : [])),
            onTap: () async {
              Countdown countdown = Countdown();
              countdown.stop();
              final prefs = await SharedPreferences.getInstance();
              var cur = prefs.getBool((item['id'] as int).toString());
              if (cur != null && cur) {
                prefs.remove((item['id'] as int).toString());
              } else {
                prefs.setBool((item['id'] as int).toString(), true);
              }
              String? token = prefs.getString('token');
              if (token != null) {
                Uri uri = Uri.https('ddltest.jray.xyz', '/setstatus');
                Dio().post(uri.toString(), data: {
                  'token': prefs.getString('token'),
                  'ddlId': [item['id']],
                  'finish': [cur == null ? true : !cur]
                }).then((res) {
                  if (res.statusCode == 200) {
                    if (res.data['status'] == 'success') {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                          msg: '同步成功',
                          gravity: ToastGravity.BOTTOM,
                          textColor: Colors.white,
                          backgroundColor: Colors.grey,
                          fontSize: 16.0);
                    } else {
                      Fluttertoast.cancel();
                      Fluttertoast.showToast(
                          msg: res.data['message'],
                          gravity: ToastGravity.BOTTOM,
                          textColor: Colors.white,
                          backgroundColor: Colors.grey,
                          fontSize: 16.0);
                    }
                  } else {
                    Fluttertoast.cancel();
                    Fluttertoast.showToast(
                        msg: '网络错误：${res.statusCode}',
                        gravity: ToastGravity.BOTTOM,
                        textColor: Colors.white,
                        backgroundColor: Colors.grey,
                        fontSize: 16.0);
                  }
                });
              }
              countdown.start();
              reload(false);
            },
          ),
        ])
      ];
    }
    countdownList = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children +
          [
            const Text("———— 没有更多啦 ————",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center)
          ],
    );
    return countdownList;
  }

  void reload(bool refresh) {
    setState(() {
      _refresh = refresh;
      if (!_refresh) {
        ddlList = ddlList;
      } else {
        Countdown countdown = Countdown();
        countdown.setHeight = false;
        ddlList = [];
      }
    });
  }

  String getCountDown(int endTime, DateTime currentTime) {
    String ans = '';
    if (endTime == 3376656000) {
      ans += "还没有确定时间呢...";
    } else {
      ans +=
          '${DateTime.fromMicrosecondsSinceEpoch(endTime * 1000000).difference(currentTime).inDays} 天 ';
      ans +=
          '${addZero(DateTime.fromMicrosecondsSinceEpoch(endTime * 1000000).difference(currentTime).inHours % 24)} 时 ';
      ans +=
          '${addZero(DateTime.fromMicrosecondsSinceEpoch(endTime * 1000000).difference(currentTime).inMinutes % 60)} 分 ';
      ans +=
          '${addZero(DateTime.fromMicrosecondsSinceEpoch(endTime * 1000000).difference(currentTime).inSeconds % 60)} 秒';
    }
    return ans;
  }

  String getTimeFormat(int time) {
    if (time == 3376656000) {
      return "还没有确定时间呢...";
    } else {
      var dateTime = DateTime.fromMicrosecondsSinceEpoch((time) * 1000000);
      Map<int, String> week = {
        1: '一',
        2: '二',
        3: '三',
        4: '四',
        5: '五',
        6: '六',
        7: '日',
      };
      return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${addZero(dateTime.hour)}:${addZero(dateTime.minute)}:${addZero(dateTime.second)} 周${week[dateTime.weekday]}';
    }
  }
}
