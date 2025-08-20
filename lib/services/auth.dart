import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexchat/pages/home.dart';
import 'package:nexchat/services/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  /// 🔁 Mark previously signed-in user as offline using stored userId
  Future<void> markOldUserOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance(); // ✅ FIXED
      final oldUserId = prefs.getString("USERKEY");
      print("Old user ID: $oldUserId");

      if (oldUserId != null) {
        await FirebaseFirestore.instance.collection("users").doc(oldUserId).update({
          "online": false,
          "lastSeen": FieldValue.serverTimestamp(),
        });
        await prefs.clear();
      }
    } catch (e) {
      print("Error marking old user offline: $e");
    }
  }


  /// ✅ Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await markOldUserOffline();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // 🔄 force chooser

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In cancelled')),
        );
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        String username = user.email!.replaceAll("@gmail.com", "").toUpperCase();
        String firstLetter = username[0];

        // 🔐 Save locally
        final prefs = await SharedPreferenceHelper().getPrefs();
        await prefs.setString("USERKEY", user.uid);
        await prefs.setString("USERNAMEKEY", user.displayName ?? "");
        await prefs.setString("USEREMAILKEY", user.email ?? "");
        await prefs.setString("USERIMAGEKEY", user.photoURL ?? "");
        await prefs.setString("USERUSERNAMEKEY", username);

        // 🔥 Store in Firestore
        final userMap = {
          "Name": user.displayName,
          "Email": user.email,
          "Image": user.photoURL,
          "Id": user.uid,
          "username": username,
          "SearchKey": firstLetter,
          "online": true,
          "lastSeen": DateTime.now(),
        };

        await DataBaseMethods().addUser(userMap, user.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Sign-In failed: $e'),
          ),
        );
      }
    }
  }

  /// 🚪 Sign out and update online status
  Future<void> signOutUser(BuildContext context) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
          "online": false,
          "lastSeen": FieldValue.serverTimestamp(),
        });

        await auth.signOut();
        await GoogleSignIn().signOut();

        final prefs = await SharedPreferenceHelper().getPrefs();
        await prefs.clear();

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print("❌ Sign-out Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Sign-out failed: $e'),
          ),
        );
      }
    }
  }
}
