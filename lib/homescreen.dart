import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:studygroupmatcher/addbio.dart';
import 'package:studygroupmatcher/api.dart';
import 'package:studygroupmatcher/myfriends.dart';
import 'package:studygroupmatcher/user.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  var findfriendslist = [];
  var pendingrequestsList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: new AppBar(
        title: Text("Study Group Matcher"),

        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyFriends()),
                );
              },
              child: CircleAvatar(
                child: Icon(Icons.group),
                backgroundColor: Color(0xffF5F5F5),
                radius: 20,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Friend Requests",
                style: TextStyle(
                  color: Colors.black,

                  fontWeight: FontWeight.w600,

                  fontSize: 18,
                ),
              ),
              pendingrequestsList.length > 0
                  ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pendingrequestsList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        // height: 90,
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        width: double.infinity,

                        // color: Colors.red,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${pendingrequestsList[index]["fullname"]}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          175,
                                      child: Text(
                                        "${pendingrequestsList[index]["bio"]}",
                                      ),
                                    ),
                                  ],
                                ),

                                Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Color(0xff0E64D2),

                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.all(0),
                                    color: Color(0xff0E64D2),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        10,
                                        20,
                                        10,
                                      ),
                                      child: Text(
                                        "Accept",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () async {
                                      String token = User.authToken;
                                      var response = await https.post(
                                        Uri.parse(Backend.url + "acceptfriend"),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer $token',
                                        },

                                        body: jsonEncode({
                                          "senderId":
                                              pendingrequestsList[index]["_id"],
                                        }),
                                      );

                                      if (response.statusCode == 200) {
                                        var responsejson = jsonDecode(
                                          response.body,
                                        );

                                        // User.authToken = responsejson["token"];

                                        Fluttertoast.showToast(
                                          textColor: Colors.green,
                                          msg: responsejson["message"],
                                        );
                                      } else {
                                        var responsejson = jsonDecode(
                                          response.body,
                                        );

                                        Fluttertoast.showToast(
                                          textColor: Colors.red,
                                          msg: responsejson["error"],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                            Divider(
                              color: Colors.black.withOpacity(0.3),
                              // height: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                  : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text("No Pending Requests"),
                  ),

              Text(
                "Find Friends",
                style: TextStyle(
                  color: Colors.black,

                  fontWeight: FontWeight.w600,

                  fontSize: 18,
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: findfriendslist.length,
                itemBuilder: (context, index) {
                  return Container(
                    // height: 90,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    width: double.infinity,

                    // color: Colors.red,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  findfriendslist[index]["fullname"],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                Container(
                                  width:
                                      MediaQuery.of(context).size.width - 175,
                                  child: ListView.builder(
                                    itemCount:
                                        findfriendslist[index]["reasons"]
                                            .length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),

                                    itemBuilder: (context, index1) {
                                      return Text(
                                        "○ " +
                                            findfriendslist[index]["reasons"][index1],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              width: 120,
                              decoration: BoxDecoration(
                                color: Color(0xff5BC236),

                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: CupertinoButton(
                                padding: EdgeInsets.all(0),
                                color: Color(0xff5BC236),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    10,
                                    20,
                                    10,
                                  ),
                                  child: Text(
                                    "Request",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                onPressed: () async {
                                  String token = User.authToken;
                                  var response = await https.post(
                                    Uri.parse(Backend.url + "addfriend"),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token',
                                    },

                                    body: jsonEncode({
                                      "targetId": findfriendslist[index]["_id"],
                                    }),
                                  );

                                  if (response.statusCode == 200) {
                                    var responsejson = jsonDecode(
                                      response.body,
                                    );

                                    // User.authToken = responsejson["token"];

                                    Fluttertoast.showToast(
                                      textColor: Colors.green,
                                      msg: responsejson["message"],
                                    );
                                  } else {
                                    var responsejson = jsonDecode(
                                      response.body,
                                    );

                                    Fluttertoast.showToast(
                                      textColor: Colors.red,
                                      msg: responsejson["error"],
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        Divider(
                          color: Colors.black.withOpacity(0.3),
                          // height: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> findfriends() async {
    String token = User.authToken;
    var response = await https.get(
      Uri.parse(Backend.url + "findfriends"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);

      var matches = jsondata["data"]["matches"];

      print(matches);

      setState(() {
        findfriendslist = matches;
      });
    }
  }

  Future<void> pendingrequests() async {
    String token = User.authToken;
    var response = await https.get(
      Uri.parse(Backend.url + "getfriendrequests"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        pendingrequestsList = jsondata;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyprofile();
  }

  Future<void> verifyprofile() async {
    String token = User.authToken;

    var response = await https.get(
      Uri.parse(Backend.url + "getuserprofile"),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      var responsejson = jsonDecode(response.body);
      print(responsejson);

      if (responsejson["bio"] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddbioScreen()),
        );
      } else {
        findfriends();
        pendingrequests();
      }

      // Fluttertoast.showToast(
      //   msg: responsejson["user"],
      //   textColor: Colors.green,
      // );
    }

    try {} catch (ee) {}
  }
}
