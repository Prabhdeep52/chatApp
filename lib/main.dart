import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/screens/authScreen.dart';
import 'package:chatapp/screens/chatScreen.dart';
import 'package:chatapp/screens/waiting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
// void main() async {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'First Method',
            // You can use the library anywhere in the app even in theme
            theme: ThemeData().copyWith(
              useMaterial3: true,
              // brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 63, 17, 177)),
              // scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const ChatScreen();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const waitingScreen();
                }
                return const AuthScreen();
              },
            ),
          );
        });
  }
}
