import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:murdjaju/authentication/auth.dart';
import 'package:murdjaju/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:provider/provider.dart';

class FillDataScreen extends StatefulWidget {
  @override
  _FillDataScreenState createState() => _FillDataScreenState();
}

class _FillDataScreenState extends State<FillDataScreen> {
  User user;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _nameFocusNode = FocusNode();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  bool _passwordIsObscure = true;
  String _emailValide;
  String _nameValide;
  bool _passwordValide = true;
  String signInError;

  int currentBox = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _emailController.addListener(() {
      _verifyEmail();
      setState(() {
        signInError = null;
      });
    });
    _passwordController.addListener(() {
      _verifyPassword();
      setState(() {
        signInError = null;
      });
    });
    _nameController.addListener(() {
      _verifyName();
      setState(() {
        signInError = null;
      });
    });
  }

  void _verifyPassword() {
    if (_passwordController.text == null || _passwordController.text.length < 8)
      setState(() {
        _passwordValide = false;
      });
    else
      setState(() {
        _passwordValide = true;
      });
  }

  void _verifyName() {
    if (_nameController.text == null || _nameController.text == '')
      setState(() {
        _nameValide = 'Name can\'t be Empty';
      });
    else if (!validateName(_nameController.text))
      setState(() {
        _nameValide = 'Enter a valid Name, Please';
      });
    else
      setState(() {
        _nameValide = null;
      });
  }

  void _verifyEmail() {
    if (_emailController.text == null || _emailController.text == '')
      setState(() {
        _emailValide = 'Email can\'t be Empty';
      });
    else if (!validateEmail(_emailController.text))
      setState(() {
        _emailValide = 'Enter a valid Email, Please';
      });
    else
      setState(() {
        _emailValide = null;
      });
  }

  bool validateName(String value) {
    // String pattern = r"^[a-z ,.\'-]+$";
    String pattern = r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)";

    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  bool validateEmail(String value) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      appBar: AppBar(
        backgroundColor: Style.Colors.mainColor,
        centerTitle: true,
        title: Text(
          'Just one more step !',
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
      floatingActionButton: (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _emailValide == null && _nameValide == null)
          ? FloatingActionButton(
              child: Icon(Icons.keyboard_arrow_right),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () async {
                final auth = Provider.of<UserAuth>(context, listen: false);
                await auth.updateUser(
                  _nameController.text,
                  _emailController.text,
                );
                await FirebaseFirestore.instance.collection("Users").doc(auth.user.uid).set(
                  {
                    "name": _nameController.text,
                    "mailAdress": _emailController.text,
                    "phoneNumber": auth.user.phoneNumber,
                  },
                );
                await Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => MyApp()));
              },
            )
          : null,
      body: GestureDetector(
        onTap: () {
          _emailFocusNode.unfocus();
          _nameFocusNode.unfocus();
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          // color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  autofocus: false,
                  decoration: new InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _nameController.text != ''
                              ? _nameValide != null
                                  ? Colors.red
                                  : Style.Colors.secondaryColor
                              : Colors.white, /* Palette.secondaryColor */
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor), borderRadius: BorderRadius.circular(10)),
                    helperText: '',
                    errorMaxLines: 1,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    errorText: _nameValide ?? null,
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: Style.Colors.secondaryColor),
                    prefixIcon: new Icon(
                      Icons.person,
                      color: _nameController.text != ''
                          ? _nameValide != null
                              ? Colors.red
                              : Style.Colors.secondaryColor
                          : Style.Colors.secondaryColor,
                    ),
                  ),
                  autocorrect: false,
                  onChanged: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  autofillHints: ['@gmail.com', '@yahoo.com', '@yahoo.fr', '@outlook.com', '@hotmail.com'],
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: false,
                  decoration: new InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _emailController.text != ''
                              ? _emailValide != null
                                  ? Colors.red
                                  : Style.Colors.secondaryColor
                              : Colors.white, /* Palette.secondaryColor */
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor), borderRadius: BorderRadius.circular(10)),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                    helperText: '',
                    errorText: _emailValide ?? null,
                    errorMaxLines: 1,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Style.Colors.secondaryColor),
                    prefixIcon: new Icon(
                      Icons.mail,
                      color: _emailController.text != ''
                          ? _emailValide != null
                              ? Colors.red
                              : Style.Colors.secondaryColor
                          : Style.Colors.secondaryColor,
                    ),
                  ),
                  autocorrect: false,
                  onChanged: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
