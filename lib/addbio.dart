import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:studygroupmatcher/api.dart';
import 'package:studygroupmatcher/homescreen.dart';
import 'package:studygroupmatcher/user.dart';

class AddbioScreen extends StatefulWidget {
  const AddbioScreen({super.key});

  @override
  State<AddbioScreen> createState() => _AddbioScreenState();
}

class _AddbioScreenState extends State<AddbioScreen> {
  TextEditingController _biotext = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: new AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Add Bio",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _biotext,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your message',
                  ),
                  maxLines: null, // Makes it multiline (expands as user types)
                  keyboardType: TextInputType.multiline,
                ),
              ),
              height: 300,
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(12),

                border: Border.all(color: Colors.black.withOpacity(0.4)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: Container(
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
                      "Next",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onPressed: () {
                    submitbio();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitbio() async {
    // _biotext
    String token = User.authToken;
    var response = await https.post(
      Uri.parse(Backend.url + "addbio"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode({"bio": _biotext.text}),
    );

    if (response.statusCode == 200) {
      var responsejson = jsonDecode(response.body);

      // User.authToken = responsejson["token"];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      var responsejson = jsonDecode(response.body);

      Fluttertoast.showToast(msg: responsejson["error"]);
    }
  }
}
