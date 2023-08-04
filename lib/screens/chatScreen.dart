import 'package:chatapp/widgets/chat_message.dart';
import 'package:chatapp/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotif() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print("token");
    print(token);
  }

  @override
  void initState() {
    super.initState();
    setupPushNotif();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("chat App"),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: Icon(
                  Icons.exit_to_app_outlined,
                  color: Theme.of(context).primaryColor,
                ))
          ],
        ),
        body: Column(
          children: [
            const Expanded(child: ChatMessages()),
            Container(
                margin: EdgeInsets.only(bottom: 15.h, left: 8.w, right: 8.w),
                child: const NewMessage()),
          ],
        ));
  }
}
