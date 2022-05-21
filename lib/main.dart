import 'package:flutter/material.dart';
import 'dart:async';
import 'scrollable_bar.dart';

void main() {
  Future.delayed(const Duration(milliseconds: 100), () {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'DDL Fighter',
      home: ScrollableTabs(),
    );
  }
}
