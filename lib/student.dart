import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educanet/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:voice_message_package/voice_message_package.dart';

import 'login.dart';
import 'main.dart';

class Student extends StatefulWidget {

  final String? userId;
  const Student({super.key, this.userId});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  String? soundRef;
  String? soundUrl;

  String? userId;
  @override
  void initState() {
    userId = widget.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        return buildItem(snapshot.data?.docs[index]);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  buildItem(doc) {
    return (userId != doc['id'])
        ? GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChatScreen(docs: doc,),
        ));
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        color: Colors.pink,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Container(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(doc['name']
                      .toString()
                      .split(' ')
                      .first
                      .substring(0, 1) +
                      doc['name'].toString().split(' ')[1].substring(0, 1)),
                ),
                title: Text(
                  doc['name'],
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ),
      ),
    )
        : Container();
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }
}
