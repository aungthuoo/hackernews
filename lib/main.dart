import 'package:flutter/material.dart';
import 'package:hackernews/topArticleList.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Hacker News",
        home: TopArticleList());
  }
}
