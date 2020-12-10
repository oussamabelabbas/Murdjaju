import 'package:murdjaju/authentication/auth.dart';
import 'package:murdjaju/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:provider/provider.dart';

class FillDataScreen extends StatefulWidget {
  static final String path = "lib/src/pages/onboarding/intro6.dart";
  @override
  _FillDataScreenState createState() => _FillDataScreenState();
}

class _FillDataScreenState extends State<FillDataScreen> {
  User user;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Just one more step !',
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _emailFocusNode.unfocus();
          _firstNameFocusNode.unfocus();
          _lastNameFocusNode.unfocus();
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("First Name:"),
                TextField(
                  focusNode: _firstNameFocusNode,
                  textAlign: TextAlign.center,
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: "FirstName",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Text("Last Name:"),
                TextField(
                  focusNode: _lastNameFocusNode,
                  textAlign: TextAlign.center,
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: "LastName",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Text("Mail adress:"),
                TextField(
                  focusNode: _emailFocusNode,
                  textAlign: TextAlign.center,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: "Example@Adress.mail",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                MaterialButton(
                  child: Text("Confirm"),
                  onPressed: () async {
                    final auth = Provider.of<UserAuth>(context, listen: false);

                    await auth.updateUser(
                      _firstNameController.text +
                          " " +
                          _lastNameController.text,
                      _emailController.text,
                    );
                    await Navigator.pushReplacement(
                        context, CupertinoPageRoute(builder: (_) => MyApp()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
