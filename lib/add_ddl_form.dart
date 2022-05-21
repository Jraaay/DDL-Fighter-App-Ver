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

  AddDDLForm(this.ddlListKey, {Key? key}) : super(key: key);

  @override
  State<AddDDLForm> createState() => _AddDDLFormState();
}

class _AddDDLFormState extends State<AddDDLForm> {
  DateTime _dateTime = DateTime.now();
  String title = '';
  String description = '';
  String platform = '';
  @override
  Widget build(BuildContext context) {
    GestureDetector timeWidget;
    timeWidget = GestureDetector(
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
                  '${addZero(_dateTime.year)}-${addZero(_dateTime.month)}-${addZero(_dateTime.day)} ${addZero(_dateTime.hour)}:${addZero(_dateTime.minute)}:${addZero(_dateTime.second)}'),
        ),
        onTap: () {
          Pickers.showDatePicker(
            context,
            mode: DateMode.YMDHMS,
            pickerStyle: NoTitleStyle(),
            selectDate: PDuration(
              year: _dateTime.year,
              month: _dateTime.month,
              day: _dateTime.day,
              hour: _dateTime.hour,
              minute: _dateTime.minute,
              second: _dateTime.second,
            ),
            onChanged: (PDuration selectDate) {
              setState(() {
                _dateTime = DateTime(
                  selectDate.year ?? _dateTime.year,
                  selectDate.month ?? _dateTime.month,
                  selectDate.day ?? _dateTime.day,
                  selectDate.hour ?? _dateTime.hour,
                  selectDate.minute ?? _dateTime.minute,
                  selectDate.second ?? _dateTime.second,
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
                    child: const Text("添加", style: TextStyle(fontSize: 16)),
                    onPressed: () {
                      SharedPreferences.getInstance().then((value) {
                        String token = value.getString('token') ?? '';
                        Uri uri = Uri.https('ddltest.jray.xyz', '/addddl');
                        Map body = {
                          'token': token,
                          'subject': title,
                          'detail': description,
                          'platform': platform,
                          'endTime':
                              (_dateTime.millisecondsSinceEpoch / 1000).floor(),
                        };
                        Dio().post(uri.toString(), data: body).then((value) {
                          if (value.statusCode == 200) {
                            if (value.data['status'] == 'success') {
                              Fluttertoast.cancel();
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
