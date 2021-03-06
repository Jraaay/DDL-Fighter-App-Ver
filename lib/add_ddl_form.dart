import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ddl_list.dart';
import 'utils.dart';

class AddDDLForm extends StatefulWidget {
  GlobalKey<DDLListState> ddlListKey;
  DateTime? dateTime;
  String? title;
  String? description;
  String? platform;
  int? ddlId;
  bool change;

  AddDDLForm(this.ddlListKey,
      {Key? key,
      this.dateTime,
      this.title,
      this.description,
      this.platform,
      this.ddlId,
      this.change = false})
      : super(key: key);

  @override
  State<AddDDLForm> createState() => _AddDDLFormState();
}

class _AddDDLFormState extends State<AddDDLForm> {
  DateTime? _dateTime;
  String? title;
  String? description;
  String? platform;
  @override
  Widget build(BuildContext context) {
    // 获取是否有传入的信息，因为复用了新增和修改DDL页面
    _dateTime ??= widget.dateTime ?? DateTime.now();
    title ??= widget.title ?? '';
    description ??= widget.description ?? '';
    platform ??= widget.platform ?? '';
    GestureDetector timeWidget;
    // 定义一个用来选择时间的widget
    timeWidget = GestureDetector(
        // 有一个用来显示时间的Text，并且点击时会弹出时间选择器
        child: TextFormField(
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'DDL时间',
            labelStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_month_outlined),
          ),
          readOnly: true,
          controller: TextEditingController(
              text:
                  '${addZero(_dateTime!.year)}-${addZero(_dateTime!.month)}-${addZero(_dateTime!.day)} ${addZero(_dateTime!.hour)}:${addZero(_dateTime!.minute)}:${addZero(_dateTime!.second)}'),
        ),
        onTap: () {
          // 弹出时间选择器
          Pickers.showDatePicker(
            context,
            mode: DateMode.YMDHMS,
            pickerStyle: NoTitleStyle(),
            selectDate: PDuration(
              year: _dateTime!.year,
              month: _dateTime!.month,
              day: _dateTime!.day,
              hour: _dateTime!.hour,
              minute: _dateTime!.minute,
              second: _dateTime!.second,
            ),
            onChanged: (PDuration selectDate) {
              // 时间选择器变化时调用，更新时间
              setState(() {
                _dateTime = DateTime(
                  selectDate.year ?? _dateTime!.year,
                  selectDate.month ?? _dateTime!.month,
                  selectDate.day ?? _dateTime!.day,
                  selectDate.hour ?? _dateTime!.hour,
                  selectDate.minute ?? _dateTime!.minute,
                  selectDate.second ?? _dateTime!.second,
                );
              });
            },
          );
        });
    return Material(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Add DDL'),
      ),
      body: Container(
          alignment: Alignment.center,
          child: Form(
            child: Column(children: [
              SizedBox(height: MediaQuery.of(context).size.width * 0.1),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.title_outlined),
                        border: OutlineInputBorder(),
                        labelText: 'DDL标题',
                        labelStyle: TextStyle(color: Colors.grey)),
                    initialValue: title,
                    onChanged: (String value) {
                      title = value;
                    },
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextFormField(
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(),
                        labelText: 'DDL详情',
                        labelStyle: TextStyle(color: Colors.grey)),
                    initialValue: description,
                    onChanged: (String value) {
                      description = value;
                    },
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextFormField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.chat_outlined),
                        border: OutlineInputBorder(),
                        labelText: 'DDL平台',
                        labelStyle: TextStyle(color: Colors.grey)),
                    initialValue: platform,
                    onChanged: (String value) {
                      platform = value;
                    },
                  )),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: timeWidget,
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    child: Text(widget.change ? "修改" : "添加",
                        style: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      // 点击添加按钮或修改按钮时，发送请求给后端处理
                      SharedPreferences.getInstance().then((value) {
                        String token = value.getString('token') ?? '';
                        Uri uri = Uri.https('ddltest.jray.xyz',
                            widget.change ? '/modddl' : '/addddl');
                        Map body = {
                          'token': token,
                          'subject': title,
                          'detail': description,
                          'platform': platform,
                          'endTime': (_dateTime!.millisecondsSinceEpoch / 1000)
                              .floor(),
                          'ddlId': widget.ddlId ?? 0
                        };
                        Dio().post(uri.toString(), data: body).then((value) {
                          if (value.statusCode == 200) {
                            if (value.data['status'] == 'success') {
                              Fluttertoast.cancel();
                              // 发送请求成功时，弹出提示框
                              Fluttertoast.showToast(
                                  msg: '添加成功',
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  backgroundColor: Colors.grey,
                                  fontSize: 16.0);
                              widget.ddlListKey.currentState?.reload(true);
                              Navigator.pop(context);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // 发送请求失败时，弹出提示框
                                    return AlertDialog(
                                      title: const Text('添加失败'),
                                      content: Text('${value.data["message"]}'),
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
                          } else {
                            // 发送请求失败时，弹出提示框
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('网络错误'),
                                    content: Text('${value.statusCode}'),
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
                      });
                    },
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: OutlinedButton(
                    child: const Text("取消", style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 20),
            ]),
          )),
    ));
  }
}
