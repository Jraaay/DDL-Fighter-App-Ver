import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  bool logined = false;
  String username = "";
  bool admin = false;
  String usernameForLogin = "";
  String passwordForLogin = "";
  String passowrdAgain = "";
  bool register = false;
  @override
  Widget build(BuildContext context) {
    final prefs = SharedPreferences.getInstance();
    return FutureBuilder(future: prefs.then((value) {
      return value;
    }), builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        SharedPreferences prefs = snapshot.data;
        String token = prefs.getString('token') ?? '';
        if (token != '') {
          String payload = token.split('.')[1];
          Map<String, dynamic> payloadMap = json
              .decode(utf8.decode(base64.decode(base64.normalize(payload))));
          username = payloadMap['username'] ?? '';
          admin = payloadMap['admin'] ?? false;
          logined = true;
          return loginedWidget();
        }
        return unloginedWidget();
      } else {
        return const CircularProgressIndicator(
            color: Color.fromRGBO(64, 158, 255, 1), strokeWidth: 3);
      }
    });
  }

  Widget loginedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.account_circle_outlined, size: 60, color: Colors.blue),
        const SizedBox(height: 10),
        Text(
          '已登录为：$username',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          child: const Text('退出登录'),
          onPressed: () {
            SharedPreferences.getInstance().then((value) {
              value.remove('token');
              setState(() {
                logined = false;
              });
            });
          },
        ),
      ],
    );
  }

  Widget unloginedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.no_accounts_outlined, size: 60, color: Colors.grey),
        const SizedBox(height: 20),
        Form(
            autovalidateMode: AutovalidateMode.always,
            child: Column(
                children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextFormField(
                            maxLines: 1,
                            minLines: 1,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '用户名',
                              prefixIcon: Icon(Icons.account_circle_outlined),
                            ),
                            validator: (value) {
                              if (value?.length == null ||
                                  (value != null && value.length < 4)) {
                                return '用户名长度不能小于4';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              usernameForLogin = value;
                            },
                          )),
                      const SizedBox(height: 20),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '密码',
                              prefixIcon: Icon(Icons.password_outlined),
                            ),
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            onChanged: (value) {
                              passwordForLogin = value;
                            },
                          )),
                      const SizedBox(height: 20),
                    ] +
                    (register
                        ? [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: '确认密码',
                                    prefixIcon: Icon(Icons.password_outlined),
                                  ),
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  validator: (value) {
                                    if (value != passwordForLogin) {
                                      return '两次输入的密码不一致';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    passowrdAgain = value;
                                  },
                                )),
                            const SizedBox(height: 20),
                          ]
                        : []))),
        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 400),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromRGBO(64, 158, 255, 1)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              onPressed: () {
                if (register) {
                  if (usernameForLogin.length < 4) {
                    return;
                  }
                  if (passowrdAgain != passwordForLogin) {
                    return;
                  }
                } else {
                  if (usernameForLogin.length < 4) {
                    return;
                  }
                }
                registerOrLogin();
              },
              child: Text(register ? '注册' : '登录'),
            )),
        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(maxWidth: 400),
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                    const Color.fromRGBO(64, 158, 255, 1)),
              ),
              onPressed: () {
                changeRegister();
              },
              child: Text(register ? '返回登录' : '注册'),
            )),
      ],
    );
  }

  void registerOrLogin() {
    Uri uri = Uri.https('ddltest.jray.xyz', register ? '/register' : '/login');
    var body = {
      'username': usernameForLogin,
      'password': passwordForLogin,
    };
    Dio().post(uri.toString(), data: json.encoder.convert(body)).then((value) {
      if (value.statusCode == 200) {
        if (value.data['status'] == 'success') {
          String token = value.data['token'];
          SharedPreferences.getInstance().then((value) {
            value.setString('token', token);
            if (register) {
              value.getKeys();
              List<String> ddlId = [];
              List<bool> finish = [];
              for (String key in value.getKeys()) {
                if (key != 'token') {
                  ddlId.add(key);
                  finish.add(true);
                }
              }
              Uri uri = Uri.https('ddltest.jray.xyz', '/setstatus');
              var body = {
                'ddlId': ddlId,
                'finish': finish,
                'token': token,
              };

              Dio()
                  .post(uri.toString(), data: json.encoder.convert(body))
                  .then((value) {
                if (value.statusCode == 200) {
                  if (value.data['status'] == 'success') {
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
                        msg: '同步失败',
                        gravity: ToastGravity.BOTTOM,
                        textColor: Colors.white,
                        backgroundColor: Colors.grey,
                        fontSize: 16.0);
                  }
                }
              });
            } else {
              Fluttertoast.cancel();
              Fluttertoast.showToast(
                  msg: '登录成功',
                  gravity: ToastGravity.BOTTOM,
                  textColor: Colors.white,
                  backgroundColor: Colors.grey,
                  fontSize: 16.0);
            }
            setState(() {});
          });
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('错误'),
                  content: Text(value.data['message']),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('确定'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('网络错误'),
                content: Text('错误代码：${value.statusCode}'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('确定'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    });
  }

  void changeRegister() {
    setState(() {
      register = !register;
    });
  }
}
