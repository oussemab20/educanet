import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatScreen extends StatefulWidget {

  final dynamic docs;
  const ChatScreen({super.key, this.docs});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String? chatRoomID, userID;
  final TextEditingController _tec = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isPlayingMsg = false, isRecording = false, isSending = false;

  @override
  void initState() {
    getRoomId();
    super.initState();
  }

  getRoomId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    userID = _prefs.getString('id');
    String anotherUserID = widget.docs['id'];

    // LOGIC TO SELECT DESIRED CHAT ROOM FROM COUD FIRESTORE
    if ((userID?.compareTo(anotherUserID) ?? 0) > 0) {
      chatRoomID = '$userID - $anotherUserID';
    } else {
      chatRoomID = '$anotherUserID - $userID';
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.docs['rool']
                  .toString()
                  .split(' ')
                  .first
                  .substring(0, 1)),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(child: Text(widget.docs['name'], overflow: TextOverflow.ellipsis,)),
          ],
        ),
        // CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS
        // I WILL SHORTLY ADD AGORA CALL FEATURE FOR BOTH AUDIO AND VIDEO
        // IF SOMEONE DOES BEFORE ME YOU ARE WELCOME TO CONTRIBUTE HERE
        actions: const [
          Icon(Icons.add_call),
          SizedBox(
            width: 5,
          ),
          Icon(Icons.video_call),
          SizedBox(
            width: 5,
          ),
          Icon(Icons.more_vert),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: chatRoomID != null
            ? FirebaseFirestore.instance
            .collection('messages')
            .doc(chatRoomID)
            .collection("$chatRoomID")
            .orderBy('timestamp', descending: true)
            .snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            print(chatRoomID);
            print(snapshot.data?.docs.length);
            // return Text('hello');
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return buildItem(
                        snapshot.data?.docs[index],
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      !isRecording?
                      Expanded(flex: 4,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20)),
                          child: TextField(
                            decoration: const InputDecoration(
                                hintText: 'Type Here',
                                border: InputBorder.none),
                            controller: _tec,
                          ),
                        ),
                      ) : SizedBox(),
                      Expanded(
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                             child: SocialMediaRecorder(
                               maxRecordTimeInSecond: 60,
                               backGroundColor: Colors.white,
                               recordIcon: Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Icon(Icons.mic,color: Colors.black,),
                               ),
                               startRecording: () {
                                 setState(() {
                                   isRecording = true;
                                 });
                               },
                               stopRecording: (time) {

                               },
                               sendRequestFunction: (soundFile, time) {
                                 setState(() {
                                   isRecording = false;
                                 });
                                 final firebaseStorageRef = FirebaseStorage.instance.ref()
                                     .child('profilepics/audio${DateTime.now().millisecondsSinceEpoch.toString()}}.jpg');

                                 var task = firebaseStorageRef.putFile(soundFile);
                                 task.then((value) async {
                                   print('##############done#########');
                                   var audioURL = await value.ref.getDownloadURL();
                                   String strVal = audioURL.toString();
                                   await sendAudioMsg(strVal);
                                 }).catchError((e) {
                                   print(e);
                                 });
                               },
                               encode: AudioEncoderType.AAC,
                             ),


                            // child: GestureDetector(
                            //   onLongPress: () {
                            //     startRecord();
                            //     setState(() {
                            //       isRecording = true;
                            //     });
                            //   },
                            //   onLongPressEnd: (details) {
                            //     stopRecord();
                            //     setState(() {
                            //       isRecording = false;
                            //     });
                            //   },
                            //   child: Container(
                            //       padding: const EdgeInsets.all(10),
                            //       child: const Icon(
                            //         Icons.mic,
                            //         color: Colors.white,
                            //         size: 20,
                            //       )),
                            // )
                        ),
                      ),
                      !isRecording?
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                        decoration: const BoxDecoration(
                            color: Colors.pink, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            sendMsg();
                            _tec.clear();
                          },
                        ),
                      ): SizedBox(),
                    ],
                  ),
                )
              ],
            );
          } else {
            return const Center(
              child: SizedBox(
                height: 36,
                width: 36,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  sendMsg() {
    setState(() {
      isSending = true;
    });
    String msg = _tec.text.trim();
    print('here');
    if (msg.isNotEmpty) {
      var ref = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatRoomID)
          .collection("$chatRoomID")
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(ref, {
          "senderId": userID,
          "anotherUserId": widget.docs['id'],
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": msg,
          "type": 'text'
        });
      });
      scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 500), curve: Curves.bounceInOut);
      setState(() {
        isSending = false;
      });
    } else {
      print("Hello");
    }
  }

  sendAudioMsg(String audioMsg) async {
    if (audioMsg.isNotEmpty) {
      var ref = FirebaseFirestore.instance
          .collection('messages')
          .doc(chatRoomID)
          .collection("$chatRoomID")
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(ref, {
          "senderId": userID,
          "anotherUserId": widget.docs['id'],
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "content": audioMsg,
          "type": 'audio'
        });
      }).then((value) {
        setState(() {
          isSending = false;
        });
      });
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
    } else {
      print("Hello");
    }
  }

  buildItem(doc) {
    print("MSG " + doc['content']);
    var day = DateTime.fromMillisecondsSinceEpoch(int.parse(doc['timestamp']))
        .day
        .toString();
    var month = DateTime.fromMillisecondsSinceEpoch(int.parse(doc['timestamp']))
        .month
        .toString();
    var year = DateTime.fromMillisecondsSinceEpoch(int.parse(doc['timestamp']))
        .year
        .toString()
        .substring(2);
    var date = '$day-$month-$year';
    var hour =
        DateTime.fromMillisecondsSinceEpoch(int.parse(doc['timestamp'])).hour;
    var min =
        DateTime.fromMillisecondsSinceEpoch(int.parse(doc['timestamp'])).minute;
    var ampm;
    if (hour > 12) {
      hour = hour % 12;
      ampm = 'pm';
    } else if (hour == 12) {
      ampm = 'pm';
    } else if (hour == 0) {
      hour = 12;
      ampm = 'am';
    } else {
      ampm = 'am';
    }
    if (doc['type'].toString() == 'audio') {
      return Padding(
        padding: EdgeInsets.only(
            top: 8,
            left: ((doc['senderId'] == userID) ? 64 : 10),
            right: ((doc['senderId'] == userID) ? 10 : 64)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (doc['senderId'] == userID)
                ? Colors.greenAccent
                : Colors.orangeAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: VoiceMessageView(
            controller: VoiceController(
              /// audioSrc: 'https://dl.solahangs.com/Music/1403/02/H/128/Hiphopologist%20-%20Shakkak%20%28128%29.mp3',
              audioSrc: '${doc['content']}',
              onComplete: () {
                /// do something on complete
              },
              onPause: () {
                /// do something on pause
              },
              onPlaying: () {
                /// do something on playing
              },
              onError: (err) {
                /// do somethin on error
              },
              maxDuration: const Duration(seconds: 60),
              isFile: false,
            ),
            innerPadding: 12,
            cornerRadius: 20,
          )
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(
            top: 8,
            left: ((doc['senderId'] == userID) ? 64 : 10),
            right: ((doc['senderId'] == userID) ? 10 : 64)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (doc['senderId'] == userID)
                ? Colors.grey
                : Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(doc['content'] + "\n"),
              Text("$date $hour:$min" + ampm,
                style: const TextStyle(fontSize: 10),
              )
            ],
          ),
        ),
      );
    }
  }


  Future _loadFile(String url) async {
    final bytes = await readBytes(Uri.parse(url));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        recordFilePath = file.path;
        isPlayingMsg = true;
        print(isPlayingMsg);
      });
      await play();
      setState(() {
        isPlayingMsg = false;
        print(isPlayingMsg);
      });
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();

      RecordMp3.instance.start("$recordFilePath", (type) {
        setState(() {});
      });
    } else {

    }
    setState(() {});
  }

  void stopRecord() async {
    bool s = RecordMp3.instance.stop();
    if (s) {
      setState(() {
        isSending = true;
      });

      await uploadAudio();

      setState(() {
        isPlayingMsg = false;
      });
    }
  }

  String? recordFilePath;

  Future<void> play() async {
    if (recordFilePath != null && File("$recordFilePath").existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(DeviceFileSource("$recordFilePath"),);
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = "${storageDirectory.path}/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }

  uploadAudio() {
    final firebaseStorageRef = FirebaseStorage.instance.ref()
        .child('profilepics/audio${DateTime.now().millisecondsSinceEpoch.toString()}}.jpg');

    var task = firebaseStorageRef.putFile(File("$recordFilePath"));
    task.then((value) async {
      print('##############done#########');
      var audioURL = await value.ref.getDownloadURL();
      String strVal = audioURL.toString();
      await sendAudioMsg(strVal);
    }).catchError((e) {
      print(e);
    });
  }

}
