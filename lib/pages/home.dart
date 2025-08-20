import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nexchat/pages/account.dart';
import 'package:nexchat/pages/chat_page.dart';
import 'package:nexchat/services/database.dart';
import '../services/shared_pref.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? myUsername, myName, myEmail, myPicture;
  QuerySnapshot? searchResult;
  QuerySnapshot? allUsers;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getSharedPref();
    fetchAllUsers();
  }

  getSharedPref() async {
    myUsername = await SharedPreferenceHelper().getUserUsername();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  void fetchAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection("users").get();
    allUsers = snapshot;
    setState(() {});
  }

  void onSearch() async {
    String input = searchController.text.trim();
    if (input.isNotEmpty) {
      final result = await DataBaseMethods().search(input.toUpperCase());
      setState(() {
        searchResult = result;
      });
    }
  }

  String getChatRoomIdByUsername(String a, String b) {
    return (a.compareTo(b) > 0) ? "${b}_$a" : "${a}_$b";
  }

  @override
  Widget build(BuildContext context) {
    final docs = (searchResult ?? allUsers)?.docs ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color(0xFF075E54),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NexChat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [

                      const SizedBox(width: 25),
                      IconButton(
                        icon: const Icon(Icons.account_circle_sharp, size: 40, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountPage()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey[300],
              child: TextField(
                controller: searchController,
                onSubmitted: (_) => onSearch(),
                decoration: InputDecoration(
                  hintText: 'Search Username',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        searchResult = null;
                      });
                    },
                  ),
                  prefixIcon: const Icon(size: 29, Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Chat/User List
            Expanded(
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final user = docs[index];
                  if (user["username"] == myUsername) return const SizedBox();

                  String otherUsername = user["username"];
                  String chatRoomId = getChatRoomIdByUsername(myUsername!, otherUsername);

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).get(),
                    builder: (context, snapshot) {
                      String subtitleText = user["username"];
                      String timeText = "";

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        if (data["lastMessage"] != null && data["lastMessage"].toString().isNotEmpty) {
                          subtitleText = data["lastMessage"];
                          timeText = data["lastMessageSendTs"] ?? "";
                        }
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user["Image"]),
                          ),
                          title: Text(user["Name"] ?? ''),
                          subtitle: Text(subtitleText),
                          trailing: Text(timeText, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          onTap: () async {
                            Map<String, dynamic> chatRoomInfo = {
                              "users": [myUsername, otherUsername],
                              "chatRoomId": chatRoomId,
                            };

                            await DataBaseMethods().createChatRoom(chatRoomId, chatRoomInfo);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  userName: user["username"],
                                  name: user["Name"],
                                  avatar: user["Image"],
                                  status: user["online"] ?? false,
                                  userId: user["Id"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF075E54),
        child: const Icon(Icons.chat_bubble),
        onPressed: () {},
      ),
    );
  }
}
