import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import '../services/database.dart';
import '../services/shared_pref.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String name;
  final String avatar;
  final bool status;
  final String userName;
  final Timestamp? lastSeen;

  const ChatPage({
    super.key,
    required this.name,
    required this.avatar,
    required this.status,
    required this.userName,
    required this.userId,
    this.lastSeen,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? myUsername, myName, myEmail, myPicture, chatRoomId;
  final TextEditingController messagecontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;
  // bool _isRecording=false;
  // String? _filePath;
  // FlutterSoundRecorder _recorder=FlutterSoundRecorder();
  // Future<void>_initialize()async{
  //   await _recorder.openRecorder();
  //   await _requestPermission();
  //   var tempDir=await getTemporaryDirectory();
  //   _filePath = '${tempDir.path}/audio.aac';
  //
  // }
  // Future<void>_requestPermission ()async{
  //   var status=await Permission.microphone.request();
  //   if(!status.isGranted){
  //     await Permission.microphone.request();
  //   }
  // }
  // Future<void>_startRecording()async{
  //   await _recorder.startRecorder(toFile: _filePath);
  //   setState(() {
  //     _isRecording=true;
  //     Navigator.pop(context);
  //     openRecording();
  //   });
  // }
  // Future<void>_stopRecording()async{
  //   await _recorder.stopRecorder();
  //   setState(() {
  //     _isRecording=false;
  //     Navigator.pop(context);
  //     openRecording();
  //   });
  // }
  //

  @override
  void initState() {
    super.initState();
   // _initialize();
    getSharedPref();

    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }
  //Future<void>_uploadFile()async{
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     backgroundColor: Colors.redAccent,
  //     content: Text("your audio file is uploading  please wait...",
  //         style:TextStyle(fontSize: 20)),
  //   ));
  //   File file=File(_filePath!);
  //   try{
  //     TaskSnapshot snapshot=
  //         await FirebaseStorage.instance.ref('uploads/audio.aac').put
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getSharedPref() async {
    myUsername = await SharedPreferenceHelper().getUserUsername();
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
    chatRoomId = getChatRoomIdByUsername(widget.userName, myUsername!);

    Map<String, dynamic> chatRoomInfoMap = {
      "users": [myUsername, widget.userName],
      "chatRoomId": chatRoomId,
      "lastMessage": "",
      "lastMessageSendBy": "",
      "lastMessageSendTs": "",
      "time": FieldValue.serverTimestamp(),
    };

    await DataBaseMethods().createChatRoom(chatRoomId!, chatRoomInfoMap);
    setState(() {});
  }

  String getChatRoomIdByUsername(String a, String b) {
    return a.codeUnitAt(0) > b.codeUnitAt(0) ? "$b\_$a" : "$a\_$b";
  }

  addMessages(bool sendClicked) async {
    if (messagecontroller.text.trim().isEmpty) return;

    String message = messagecontroller.text.trim();
    messagecontroller.clear();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('h:mma').format(now);

    Map<String, dynamic> messageInfoMap = {
      "message": message,
      "sendBy": myUsername,
      "type": "text",
      "ts": formattedDate,
      "time": FieldValue.serverTimestamp(),
      "imgUrl": myPicture,
    };

    String messageId = randomAlphaNumeric(10);

    try {
      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId!)
          .collection("messages")
          .doc(messageId)
          .set(messageInfoMap);

      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(chatRoomId!)
          .update({
        "lastMessage": message,
        "lastMessageSendBy": myUsername,
        "lastMessageSendTs": formattedDate,
        "time": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error adding message: $e");
    }
  }

  void recordAudio() {}

  @override
  Widget build(BuildContext context) {
    if (chatRoomId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        elevation: 2,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.avatar)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600)),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text("Loading...");
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final bool isOnline = data['online'] ?? false;
                      final Timestamp? lastSeen = data['lastSeen'];

                      String statusText = "Offline";
                      if (isOnline) {
                        statusText = "Online";
                      } else if (lastSeen != null) {
                        DateTime seen = lastSeen.toDate();
                        DateTime now = DateTime.now();
                        bool isToday = seen.day == now.day &&
                            seen.month == now.month &&
                            seen.year == now.year;
                        bool isYesterday =
                            seen.day == now.subtract(Duration(days: 1)).day;

                        if (isToday) {
                          statusText = "Last seen today at ${DateFormat('hh:mm a').format(seen)}";
                        } else if (isYesterday) {
                          statusText = "Last seen yesterday at ${DateFormat('hh:mm a').format(seen)}";
                        } else {
                          statusText = "Last seen on ${DateFormat('dd MMM yyyy').format(seen)}";
                        }
                      }

                      return Text(statusText,
                          style: TextStyle(
                            fontSize: 16,
                            color: isOnline ? Colors.green : Colors.grey[500],
                          ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chatRoom")
                  .doc(chatRoomId)
                  .collection("messages")
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                DateTime? previousDate;

                for (var msg in messages) {
                  final Timestamp? timestamp = msg['time'];
                  DateTime messageDate = timestamp?.toDate() ?? DateTime.now();
                  final String formattedTime = msg['ts'] ?? '';
                  final bool isMe = msg['sendBy'] == myUsername;

                  if (previousDate == null ||
                      previousDate.day != messageDate.day ||
                      previousDate.month != messageDate.month ||
                      previousDate.year != messageDate.year) {
                    messageWidgets.add(
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(messageDate),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                    previousDate = messageDate;
                  }

                  messageWidgets.add(
                    Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          gradient: isMe
                              ? const LinearGradient(
                            colors: [
                              Color(0xFF833AB4),
                              Color(0xFFF77737),
                              Color(0xFFE1306C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isMe ? null : const Color(0xFF24BFD3),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 18),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0, right: 40.0),
                              child: Text(
                                msg['message'],
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 6,
                              child: Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isMe ? Colors.white70 : Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  children: messageWidgets,
                );
              },
            ),
          ),
          // Message input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, size: 30),
                    onPressed: recordAudio,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: messagecontroller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.emoji_emotions),
                            onPressed: () {
                              if (_isKeyboardVisible) {
                                FocusScope.of(context).unfocus(); // Close keyboard
                              } else {
                                FocusScope.of(context).requestFocus(_focusNode); // Open keyboard
                              }
                            },
                          ),
                          suffixIcon: const Icon(Icons.attach_file_sharp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF075E54),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_sharp, size: 30),
                      color: Colors.white,
                      onPressed: () => addMessages(true),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
