import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:studygroupmatcher/api.dart';
import 'package:studygroupmatcher/homescreen.dart';
import 'package:studygroupmatcher/user.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _fullName = TextEditingController();

  TextEditingController _mobileNumber = TextEditingController();
  TextEditingController _emailId = TextEditingController();
  TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Create an account",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Full Name",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
              child: Container(
                height: 45,
                child: Center(child: CupertinoTextField(controller: _fullName)),
              ),
            ),
            Text(
              "Mobile NO",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
              child: Container(
                height: 45,
                child: Center(
                  child: CupertinoTextField(controller: _mobileNumber),
                ),
              ),
            ),

            Text(
              "Email",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
              child: Container(
                height: 45,
                child: Center(child: CupertinoTextField(controller: _emailId)),
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
                    "Sign up",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () {
                  signup();
                },
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xff0D0E0E),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xff2F89FC),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signup() async {
    var response = await https.post(
      Uri.parse(Backend.url + "signup"),

      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },

      body: jsonEncode({
        "fullname": _fullName.text,

        "mobilenumber": _mobileNumber.text,
        "email": _emailId.text,
        "password": _password.text,
      }),
    );

    if (response.statusCode == 200) {
      var responsejson = jsonDecode(response.body);

      User.authToken = responsejson["token"];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      // var responsejson = jsonDecode(response.body);

      Fluttertoast.showToast(msg: response.body);
    }
  }
}
