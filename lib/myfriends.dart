import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:studygroupmatcher/api.dart';
import 'package:studygroupmatcher/friendprofile.dart';
import 'package:studygroupmatcher/user.dart';

class MyFriends extends StatefulWidget {
  const MyFriends({super.key});

  @override
  State<MyFriends> createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriends> {
  var friendslist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: Text("My Friends"),

        backgroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              friendslist.length > 0
                  ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: friendslist.length,
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
                                      "${friendslist[index]["fullname"]}",
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
                                        "${friendslist[index]["bio"]}",
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
                                        "View",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProfileView(
                                                bio: friendslist[index]["bio"],
                                                email:
                                                    friendslist[index]["email"],
                                                fullname:
                                                    friendslist[index]["fullname"],
                                                mobilenumber:
                                                    friendslist[index]["mobilenumber"],
                                              ),
                                        ),
                                      );
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
                  : Text("No Friends"),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> myfriends() async {
    String token = User.authToken;
    var response = await https.get(
      Uri.parse(Backend.url + "getfriends"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      print(jsondata);
      setState(() {
        friendslist = jsondata;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myfriends();
  }
}
