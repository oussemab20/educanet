import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educanet/student.dart';
import 'package:educanet/teacher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'chat.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'register.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: NavDrawer(),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: Text('Home'),
            leading: Icon(Icons.home),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            ),
          ),
          ListTile(
            title: Text('Chat'),
            leading: Icon(Icons.chat),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ChatPage()),
            ),
          ),
          ListTile(
            title: Text('Teacher'),
            leading: Icon(Icons.person),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Teacher()),
            ),
          ),
          ListTile(
            title: Text('Student'),
            leading: Icon(Icons.person),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => Student()),
            ),
          ),
        ],
      ),
    );
  }
}