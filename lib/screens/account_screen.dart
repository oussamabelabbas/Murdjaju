import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/authentication/auth.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../style/theme.dart' as Style;

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<UserAuth>(context, listen: false);

    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.mainColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              child: Center(
                child: Text(auth.user.displayName ?? "no Name"),
              ),
            ),
            Container(
              height: 50,
              child: Center(
                child: Text(auth.user.email ?? "no Mail"),
              ),
            ),
            Container(
              height: 50,
              child: Center(
                child: Text(auth.user.phoneNumber ?? "No phone"),
              ),
            ),
            Container(
              height: 50,
              child: Center(
                child: Text(auth.user.uid),
              ),
            ),
            Container(
              height: 200,
            ),
            MaterialButton(
              color: Colors.red,
              child: Text('Déconnexion'),
              onPressed: () async {
                await auth.logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
