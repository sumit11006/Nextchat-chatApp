import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nexchat/services/shared_pref.dart';
import 'package:nexchat/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? name, email, username, imageUrl, userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    print("User ID used for upload: $userId");

  }

  Future<void> getUserDetails() async {
    SharedPreferenceHelper prefs = SharedPreferenceHelper();
    name = await prefs.getUserDisplayName();
    email = await prefs.getUserEmail();
    username = await prefs.getUserUsername();
    imageUrl = await prefs.getUserImage();
    userId = await prefs.getUserId();

    setState(() {});
  }

  Future<void> _changeProfilePic() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null && userId != null) {
      setState(() => isLoading = true);

      File imageFile = File(pickedImage.path);

      // Get actual file extension
      String extension = pickedImage.path.split('.').last;
      String fileName = "$userId.$extension";

      Reference ref = FirebaseStorage.instance.ref().child("profilePics/$fileName");

      try {
        await ref.putFile(imageFile);
        String newImageUrl = await ref.getDownloadURL();

        // Update Firestore
        await FirebaseFirestore.instance.collection("users").doc(userId).update({
          "Image": newImageUrl,
        });

        // Update SharedPrefs
        await SharedPreferenceHelper().saveUserImage(newImageUrl);

        // Update UI
        setState(() {
          imageUrl = newImageUrl;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile picture updated successfully")),
        );
      } catch (e) {
        print("Upload error: $e");
        setState(() => isLoading = false);
      }
    }
  }

  void _logout() async {
    await AuthMethods().signOutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Account"), centerTitle: true),
      body: isLoading || imageUrl == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(imageUrl!),
            backgroundColor: Colors.grey[300],
          ),
          TextButton(
            onPressed: _changeProfilePic,
            child: Text("Change Picture"),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Name"),
            subtitle: Text(name ?? ''),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email"),
            subtitle: Text(email ?? ''),
          ),
          ListTile(
            leading: Icon(Icons.alternate_email),
            title: Text("Username"),
            subtitle: Text(username ?? ''),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
