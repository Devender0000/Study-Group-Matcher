import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:studygroupmatcher/api.dart';
import 'package:studygroupmatcher/homescreen.dart';
import 'package:studygroupmatcher/signup.dart';
import 'package:studygroupmatcher/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();

  TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Login",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 30),
              child: Container(
                height: 45,
                child: Center(child: CupertinoTextField(controller: _email)),
              ),
            ),

            Text(
              "Password",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 50),
              child: Container(
                height: 45,
                child: Center(
                  child: CupertinoTextField(
                    controller: _password,
                    obscureText: true,
                  ),
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Color(0xff0E64D2),

                borderRadius: BorderRadius.circular(5),
              ),
              width: double.infinity,
              height: 50,
              child: CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () {
                  login();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account ?",
                    style: TextStyle(
                      color: Color(0xff0D0E0E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xff160062),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    var response = await https.post(
      Uri.parse(Backend.url + "login"),

      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },

      body: jsonEncode({"email": _email.text, "password": _password.text}),
    );

    if (response.statusCode == 200) {
      var responsejson = jsonDecode(response.body);

      User.authToken = responsejson["token"];

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      var responsejson = jsonDecode(response.body);

      Fluttertoast.showToast(msg: responsejson["error"]);
    }
  }
}
