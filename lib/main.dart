import 'package:christmas_wish/home/game_home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChristmasTreeGame());
}

class ChristmasTreeGame extends StatelessWidget {
  const ChristmasTreeGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Christmas Tree Decorator',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Comic Sans MS',
      ),
      home: const GameHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

