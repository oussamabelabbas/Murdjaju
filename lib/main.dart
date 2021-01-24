import 'dart:ui';

import 'providers/auth.dart';
import 'myMain/palette.dart';
import 'providers/loading_provider.dart';
import 'screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'style/theme.dart' as Style;

import 'screens/fillData_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  SystemUiOverlayStyle mySystemTheme = SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.black);
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  DocumentSnapshot snap;
  if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.phoneNumber == null) snap = await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser.uid).get();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserAuth>(
          create: (context) => UserAuth(
            FirebaseAuth.instance.currentUser,
            FirebaseAuth.instance.currentUser != null,
            FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.displayName != null,
            FirebaseAuth.instance.currentUser == null
                ? null
                : snap != null
                    ? snap['phoneNumber']
                    : FirebaseAuth.instance.currentUser.phoneNumber,
          ),
        ),
        ChangeNotifierProvider<LoadingProvider>(
          create: (context) => LoadingProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Palette.white,
      theme: ThemeData(
        splashFactory: InkSplash.splashFactory,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.montserrat().fontFamily,
        accentColor: Style.Colors.secondaryColor,
        splashColor: Style.Colors.secondaryColor,
        iconTheme: IconThemeData(
          color: Colors.white,
          opacity: .9,
        ),
      ),
      home: Stack(
        children: [
          Consumer<UserAuth>(
            builder: (_, auth, __) {
              if (!auth.loggedIn) return WelcomeScreen();
              if (!auth.haveData) return FillDataScreen();
              return HomeScreen();
            },
          ),
          Consumer<LoadingProvider>(
            builder: (_, loading, __) {
              if (loading.appIsLoading)
                return Container(
                  color: Style.Colors.mainColor.withOpacity(.2),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              return SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
