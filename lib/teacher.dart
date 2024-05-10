
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educanet/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';

class Teacher extends StatefulWidget {

  final String? userId;
  const Teacher({super.key, this.userId});

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {


  String? userId;
  @override
  void initState() {
    getUserId();
    super.initState();
  }

  getUserId() async {
    final _prefs = await SharedPreferences.getInstance();
    userId = _prefs.getString('id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepOrange,
        title: Text('students'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_sharp),
            onPressed: () async {
              final _prefs = await SharedPreferences.getInstance();
              _prefs.setString('id', '');
              await _prefs.clear().then((value) => Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage())));
            },
          ),
          // CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS

        ],
      ),
      body: Stack(
        children: [
          // buildFloatingSearchBar(),
          Positioned(
            top: 70,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users').where('rool', isEqualTo: 'Student')
                    .snapshots(),
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
            ),
          ),
          // buildFloatingSearchBar(),
        ],
      ),
      // CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {  },
        child: Icon(
          Icons.message,
          color: Colors.white,
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
        color: Colors.deepOrange,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Container(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(doc['rool']
                      .toString()
                      .substring(0, 1)),
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

// CONTRIBUTION ON THIS IS WELCOMED FOR FLUTTER ENTHUSIATS
// Widget buildFloatingSearchBar() {
//   final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
//   List<dynamic> searchResult = [];
//   return FloatingSearchBar(
//     borderRadius: BorderRadius.circular(30),
//     hint: 'Search Chats',
//     scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
//     transitionDuration: const Duration(milliseconds: 500),
//     transitionCurve: Curves.easeInOut,
//     physics: const BouncingScrollPhysics(),
//     axisAlignment: isPortrait ? 0.0 : -1.0,
//     openAxisAlignment: 0.0,
//     openWidth: isPortrait ? 600 : 500,
//     debounceDelay: const Duration(milliseconds: 500),
//     onQueryChanged: (query) {},
//     backdropColor: Colors.pink,
//     automaticallyImplyBackButton: false,
//     transition: CircularFloatingSearchBarTransition(),
//     actions: [
//       FloatingSearchBarAction.back(
//         color: Colors.pink,
//         showIfClosed: false,
//       ),
//       FloatingSearchBarAction.searchToClear(
//         color: Colors.pink,
//         showIfClosed: true,
//       ),
//     ],
//     builder: (context, transition) {
//       return ClipRRect(
//         child: Material(
//             color: Colors.white,
//             elevation: 4.0,
//             child: Container(
//               decoration:
//               BoxDecoration(borderRadius: BorderRadius.circular(20)),
//               height: MediaQuery.of(context).size.height * 0.9,
//               child: ListView.builder(
//                 itemCount: 0,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {},
//                     child: Container(
//                       margin:
//                       EdgeInsets.symmetric(horizontal: 38, vertical: 10),
//                       padding: EdgeInsets.all(10),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(blurRadius: 2, color: Colors.grey)
//                           ]),
//                       height: 60,
//                       width: 300,
//                       child: Text(
//                         ' ',
//                         maxLines: 3,
//                         style: TextStyle(fontSize: 15),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             )),
//       );
//     },
//   );
// }

}