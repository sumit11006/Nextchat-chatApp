import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/onboarding.dart';
import 'pages/login_page.dart';
import 'pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const NexChatApp());
}

class NexChatApp extends StatefulWidget {
  const NexChatApp({super.key});

  @override
  State<NexChatApp> createState() => _NexChatAppState();
}

class _NexChatAppState extends State<NexChatApp> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);


    if (_auth.currentUser != null) {
      _updateOnlineStatus(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = _auth.currentUser;
    if (user == null) return;

    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _updateOnlineStatus(false);
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          "online": isOnline,
          "lastSeen": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexChat',
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboarding(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
