import 'dart:ui';

import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth.dart';
import 'myMain/palette.dart';
import 'providers/loading_provider.dart';
import 'screens/authentification_screen.dart';
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

import 'screens/welcome_screen.dart';

void main() async {
  SystemUiOverlayStyle mySystemTheme = SystemUiOverlayStyle.dark.copyWith(systemNavigationBarColor: Colors.black, statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();
  await Firebase.initializeApp();
  // await FirebaseAuth.instance.signOut();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ChangeNotifierProvider<UserAuth>(create: (context) => UserAuth(), child: MyApp()));
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
          return HomeScreen();
        },
      ),
    );
  }
}
