import 'package:chatapp/widgets/user_image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:chat_app/screens/signUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  bool haveAccount = true;
  var isUploading = false;
  var savedEmail = '';
  var savedPassword = '';
  var enteredUsername = '';
  File? selectedImage;

  void submit() async {
    final isValid = form.currentState?.validate() ?? false;

    if (!isValid) {
      return; //show error message
    }

    form.currentState?.save();

    if (haveAccount) {
      //login logic
      try {
        setState(() {
          isUploading = true;
        });
        final _userCredentials = await _firebase.signInWithEmailAndPassword(
            email: savedEmail, password: savedPassword);
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? "Authentication Failed.")));
        setState(() {
          isUploading = false;
        });
      }
    } else {
      //create account

      try {
        setState(() {
          isUploading = true;
        });
        final _userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: savedEmail, password: savedPassword);
        print(_userCredentials);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("UserImages")
            .child('${_userCredentials.user!.uid} .jpg');

        await storageRef.putFile(selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("Users")
            .doc(_userCredentials.user!.uid)
            .set({
          "username": enteredUsername,
          "e-mail": savedEmail,
          "image-url": imageUrl,
        });
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? "Authentication Failed.")));
        print(error.message);
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(25.sp, 0, 25.sp, 0),
              child: Form(
                key: form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: haveAccount ? 100.h : 50.h,
                    ),
                    Text(
                      haveAccount ? "Log in" : "Create an account",
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                    ),
                    haveAccount
                        ? Text(
                            "Welcome back! Please enter your details.",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          )
                        : SizedBox(
                            height: 10.h,
                          ),
                    haveAccount
                        ? SizedBox(
                            height: 25.h,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: UserImagePicker(
                                      onPickImage: ((pickedImage) {
                                    selectedImage = pickedImage;
                                  })),
                                )
                              ]),
                    TextFormField(
                      onSaved: (value) {
                        savedEmail = value!;
                      },
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email address!';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    if (!haveAccount)
                      TextFormField(
                        onSaved: (value) {
                          enteredUsername = value!;
                        },
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length < 4) {
                            return 'Please enter a valid username(atleast 4 words)';
                          }
                          return null;
                        },
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: "Username",
                          hintText: "Enter your Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    if (!haveAccount)
                      SizedBox(
                        height: 20.h,
                      ),
                    TextFormField(
                      onSaved: (value) {
                        savedPassword = value!;
                      },
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Please enter a valid password!';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    if (isUploading)
                      const Center(child: CircularProgressIndicator()),
                    if (!isUploading)
                      OutlinedButton(
                        onPressed: submit,
                        style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(Size(350.w, 40.h)),
                          shape: MaterialStateProperty.all(
                            const ContinuousRectangleBorder(
                              borderRadius: BorderRadiusDirectional.all(
                                Radius.circular(13),
                              ),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 48, 130, 201),
                          ),
                        ),
                        child: Text(
                          haveAccount ? "Sign in" : "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: haveAccount ? 30.h : 8.h,
                    ),
                    haveAccount
                        ? OutlinedButton(
                            onPressed: () => null,
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                const BorderSide(width: 1, color: Colors.grey),
                              ),
                              fixedSize:
                                  MaterialStateProperty.all(Size(350.w, 40.h)),
                              shape: MaterialStateProperty.all(
                                const ContinuousRectangleBorder(
                                  borderRadius: BorderRadiusDirectional.all(
                                    Radius.circular(13),
                                  ),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                            child: Text(
                              "Sign In with Google",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 16.sp,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 1.h,
                          ),
                    SizedBox(
                      height: 30.h,
                    ),
                    haveAccount
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    haveAccount = !haveAccount;
                                  });
                                },
                                child: Text(
                                  "Click to Create an account",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        const Color.fromARGB(255, 94, 99, 251),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    haveAccount = !haveAccount;
                                  });
                                },
                                child: Text(
                                  "Click to sign in ",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        const Color.fromARGB(255, 94, 99, 251),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
