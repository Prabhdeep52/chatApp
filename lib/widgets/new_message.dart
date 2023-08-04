import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final newMessagecontroller = TextEditingController();

  @override
  void dispose() {
    newMessagecontroller.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = newMessagecontroller.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // FocusScope.of(context).unfocus();
    newMessagecontroller.clear();

    //send message to firebase and then clear the text field
    final CurrentUser = FirebaseAuth.instance.currentUser!;
    //now getting the username and userimage which wee have already stored
    final CurrentUserData = await FirebaseFirestore.instance
        .collection("Users")
        .doc(CurrentUser.uid)
        .get();

    FirebaseFirestore.instance.collection("Chat").add({
      "Text": enteredMessage,
      "TimeOfCreation": DateTime.now(),
      "UserId": CurrentUser.uid,
      "Username": CurrentUserData.data()!["username"],
      "imageUrl": CurrentUserData.data()!["image-url"],
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color.fromARGB(255, 182, 181, 181),
        ),
        height: 50.h,
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(bottom: 6.h, left: 20.w),
              child: TextField(
                controller: newMessagecontroller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                style: TextStyle(
                    fontSize: 20.sp,
                    color: const Color.fromARGB(255, 58, 58, 58)),
                cursorColor: const Color.fromARGB(255, 85, 85, 85),
                cursorHeight: 30.h,
                decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: "Type here ....",
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 109, 109, 109),
                        fontSize: 17),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none,
                    )),
              ),
            )),
            IconButton(
                onPressed: () {
                  submitMessage();
                },
                icon: SizedBox(
                  height: 40.h,
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.black,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
