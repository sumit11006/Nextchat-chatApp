import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseMethods{
  Future addUser(Map<String ,dynamic>userInfoMap,String id )async{
        return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }
  Future addMessage(String chatRoomId,String messageId,Map<String ,dynamic>messageInfoMap)async{
    return await FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).collection("chats").doc(messageId).set(messageInfoMap);
  }
 upDatedLastMessageSend(String chatRoomId,Map<String ,dynamic>lastMessageMapInfoMap){
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .update(lastMessageMapInfoMap);

 }
  Future<QuerySnapshot> search(String input) async {
    String query = input.toUpperCase();
    String nextQuery = query.substring(0, query.length - 1) +
        String.fromCharCode(query.codeUnitAt(query.length - 1) + 1);

    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: query)
        .where("username", isLessThan: nextQuery)
        .get();
  }
createChatRoom(String chatRoomId,Map<String ,dynamic>chatRoomInfoMap)async{
 final snapshot=await FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).get();
if(snapshot.exists){
  return true;
}
else{
  return FirebaseFirestore.instance.collection("chatRoom").doc(chatRoomId).set(chatRoomInfoMap);
}
}
}