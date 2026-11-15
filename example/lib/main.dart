import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fastutils/fastutils.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'FastUtils Demo', home: MainAppPage());
  }
}

class MainAppPage extends StatefulWidget {
  const MainAppPage({super.key});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  late Future<void> _init;
  String result = "";

  @override
  void initState() {
    _init = initialize();
    super.initState();
  }

  Future<void> initialize() async {
    await Future.delayed(Duration.zero);

    if (mounted) FastUtils().initFastUtils(context, 'testapp');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: Center(child: Column(children: [])),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
