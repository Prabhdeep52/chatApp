import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/widgets/messageBubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Chat")
          .orderBy("TimeOfCreation", descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Messages Found!"),
          );
        } else if (chatSnapshots.hasError) {
          return const Center(
            child: Text("Something Went Wrong!"),
          );
        }

        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40.h, left: 10.w, right: 10.w),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId = chatMessage["UserId"];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage["UserId"] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessage['Text'],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage["imageUrl"],
                  username: chatMessage["Username"],
                  message: chatMessage["Text"],
                  isMe: authenticatedUser.uid == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
