import 'package:flutter/material.dart';
import 'tracking_input.dart';
import 'package:flutter/services.dart';

void main() {
  /// Androidボタンを削除します。このアプリの目的上、画面上には必要ありません。
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  new MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: TrackingInput(),
    );
  }
}
/*
* 必要なもの:
* to import .flr
* 水のcontroller
* 加算とサブウォーターの計算とアニメーションへの相関
* リセットプログレスボタン
* カップ数の目標を設定する
*/
