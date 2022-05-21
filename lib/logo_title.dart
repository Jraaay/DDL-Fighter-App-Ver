import 'package:flutter/material.dart';

class LogoTitle extends StatefulWidget {
  const LogoTitle({Key? key}) : super(key: key);

  @override
  State<LogoTitle> createState() => _LogoTitleState();
}

class _LogoTitleState extends State<LogoTitle> {
  int num = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(
            height: 20,
          ),
          Image(image: AssetImage('assets/logo.png'), width: 150),
          Text(
            'DDL Fighter App Ver',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'By Jray',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 20),
        ]);
  }
}
