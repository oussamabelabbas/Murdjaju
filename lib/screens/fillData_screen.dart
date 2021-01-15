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

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  FocusNode _phoneFocusNode = FocusNode();
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

  String _phoneNumber;

  String errorText;

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
      floatingActionButton: (_phoneController.text.isNotEmpty && _nameValide == null && errorText == null)
          ? FloatingActionButton(
              child: Icon(Icons.keyboard_arrow_right),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () async {
                final auth = Provider.of<UserAuth>(context, listen: false);
                await auth.updateUser(
                  _nameController.text,
                  "+213" + _phoneNumber,
                );
                await FirebaseFirestore.instance.collection("Users").doc(auth.user.uid).set(
                  {
                    "name": _nameController.text,
                    "mailAdress": auth.user.email,
                    "phoneNumber": "+213" + _phoneNumber,
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
                  focusNode: _phoneFocusNode,
                  controller: _phoneController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  onChanged: (phone) {
                    _phoneNumber = phone;
                    if (phone.isEmpty)
                      errorText = "Empty !";
                    else if (phone.startsWith("0"))
                      errorText = "Please remove 0 from the start !";
                    else if (phone.length < 9)
                      errorText = "To short !";
                    else
                      errorText = null;

                    print(phone);
                    setState(() {});
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      print("Error!");
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    errorText: errorText,
                    labelText: 'Phone Number',
                    labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Style.Colors.secondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Style.Colors.secondaryColor),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
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
