import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:provider/provider.dart';

import '../../main.dart';

class SigninFormMail extends StatefulWidget {
  SigninFormMail({Key key}) : super(key: key);

  @override
  _SigninFormMailState createState() => _SigninFormMailState();
}

class _SigninFormMailState extends State<SigninFormMail> {
  TextEditingController _mailAdressFieldTextController = TextEditingController();
  FocusNode _mailAdressFocusode = FocusNode();
  TextEditingController _passwordFieldTextController = TextEditingController();
  FocusNode _passwordFocusode = FocusNode();

  String _passwordValide;
  String _emailValide;

  bool _passwordIsObscure = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mailAdressFieldTextController.addListener(() {
      _verifyEmail();
    });
    _passwordFieldTextController.addListener(() {
      _verifyPassword();
    });
  }

  void _verifyPassword() {
    if (_passwordFieldTextController.text == null || _passwordFieldTextController.text == '')
      setState(() {
        _passwordValide = 'Le mot de passe est vide !';
      });
    else if (!validatePassword(_passwordFieldTextController.text))
      setState(() {
        _passwordValide = 'Le mot de passe doit avoir minimum 8 lettres';
      });
    else
      setState(() {
        _passwordValide = null;
      });
  }

  bool validatePassword(String value) {
    if (value.length >= 8)
      return true;
    else
      return false;
  }

  void _verifyEmail() {
    if (_mailAdressFieldTextController.text == null || _mailAdressFieldTextController.text == '')
      setState(() {
        _emailValide = 'L\adresse mail est vide.';
      });
    else if (!validateEmail(_mailAdressFieldTextController.text))
      setState(() {
        _emailValide = 'L\'adresse mail doit être valide.';
      });
    else
      setState(() {
        _emailValide = null;
      });
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
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Style.Colors.mainColor.withOpacity(.75),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              textAlign: TextAlign.center,
              focusNode: _mailAdressFocusode,
              keyboardType: TextInputType.emailAddress,
              controller: _mailAdressFieldTextController,
              decoration: InputDecoration(
                helperText: "",
                errorText: _emailValide,
                labelText: 'Adresse mail:',
                labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Style.Colors.secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Style.Colors.secondaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.red),
                ),
                prefixIcon: new Icon(
                  Icons.mail,
                  color: _mailAdressFieldTextController.text != ''
                      ? _emailValide != null
                          ? Colors.red
                          : Style.Colors.secondaryColor
                      : Style.Colors.secondaryColor,
                ),
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              textAlign: TextAlign.center,
              focusNode: _passwordFocusode,
              obscureText: _passwordIsObscure,
              controller: _passwordFieldTextController,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                helperText: "",
                errorText: _passwordValide,
                labelText: 'Mot de passe:',
                labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Style.Colors.secondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Style.Colors.secondaryColor),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.red),
                ),
                prefixIcon: IconButton(
                  icon: Icon(
                    _passwordIsObscure ? Icons.visibility_off : Icons.visibility,
                    color: _passwordFieldTextController.text != ''
                        ? _passwordValide != null
                            ? Colors.red
                            : Style.Colors.secondaryColor
                        : Style.Colors.secondaryColor,
                  ),
                  onPressed: () => setState(() => _passwordIsObscure = !_passwordIsObscure),
                ),
              ),
            ),
            SizedBox(height: 5),
            FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Style.Colors.secondaryColor,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              label: Text("S'identifier."),
              icon: Icon(MdiIcons.login),
              onPressed: (_emailValide != null && _passwordValide != null)
                  ? null
                  : () async {
                      if (_mailAdressFieldTextController.text.isEmpty && _passwordFieldTextController.text.isEmpty) {
                        _verifyEmail();
                        _verifyPassword();
                      } else {
                        final auth = Provider.of<UserAuth>(context, listen: false);
                        final loader = Loader();
                        final GlobalKey<State> key = new GlobalKey<State>();

                        loader.showLoadingDialog(context, key);
                        String value = await auth.signinWithMailAndPassword(_mailAdressFieldTextController.text, _passwordFieldTextController.text);
                        loader.removeLoadingDialog(context, key);
                        // if (value != null)
                        if (value == null)
                          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => MyApp()));
                        else
                          await showError(value);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showError(String e) async {
    String error;
    error = e.substring(e.indexOf("]") + 2);

    await Fluttertoast.showToast(msg: error);
  }
}
