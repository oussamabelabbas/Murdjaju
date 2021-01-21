import 'dart:ui';

import 'authentication/auth.dart';
import 'myMain/palette.dart';
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
  SystemUiOverlayStyle mySystemTheme = SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Style.Colors.mainColor);
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  DocumentSnapshot snap;
  if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.phoneNumber == null) snap = await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser.uid).get();
  runApp(
    ChangeNotifierProvider<UserAuth>(
      create: (_) => UserAuth(
        FirebaseAuth.instance.currentUser,
        FirebaseAuth.instance.currentUser != null,
        FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.displayName != null,
        FirebaseAuth.instance.currentUser == null
            ? null
            : snap != null
                ? snap['phoneNumber']
                : FirebaseAuth.instance.currentUser.phoneNumber,
      ),
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
      home: Consumer<UserAuth>(
        builder: (_, auth, __) {
          if (!auth.loggedIn) return WelcomeScreen();
          if (!auth.haveData) return FillDataScreen();
          return HomeScreen();
        },
      ),
    );
  }
}
