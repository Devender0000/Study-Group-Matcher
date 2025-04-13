import 'package:flutter/material.dart';
import 'package:studygroupmatcher/addbio.dart';
import 'package:studygroupmatcher/friendprofile.dart';
import 'package:studygroupmatcher/homescreen.dart';
import 'package:studygroupmatcher/login.dart';
import 'package:studygroupmatcher/myfriends.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
      // home: AddbioScreen(),
      // home: Homescreen(),
      // home: MyFriends(),
      // home: ProfileView(),
    );
  }
}
