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

class SignupFormMail extends StatefulWidget {
  SignupFormMail({Key key}) : super(key: key);

  @override
  _SignupFormMailState createState() => _SignupFormMailState();
}

class _SignupFormMailState extends State<SignupFormMail> {
  TextEditingController _mailAdressFieldTextController = TextEditingController();
  FocusNode _mailAdressFocusode = FocusNode();
  TextEditingController _passwordFieldTextController = TextEditingController();
  FocusNode _passwordFocusode = FocusNode();
  TextEditingController _nameFieldTextController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  TextEditingController _phoneNumberFieldTextController = TextEditingController();
  FocusNode _phoneNumberFocusNode = FocusNode();

  String _nameValide;
  String _passwordValide;
  String _emailValide;
  String _phoneNumberValide;

  bool _passwordIsObscure = true;

  @override
  void initState() {
    super.initState();
    _nameFieldTextController.addListener(() {
      _verifyName();
    });
    _mailAdressFieldTextController.addListener(() {
      _verifyEmail();
    });
    _passwordFieldTextController.addListener(() {
      _verifyPassword();
    });
    _phoneNumberFieldTextController.addListener(() {
      _verifyPhoneNumber();
    });
  }

  void _verifyPhoneNumber() {
    if (_phoneNumberFieldTextController.text == null || _phoneNumberFieldTextController.text == '')
      setState(() {
        _phoneNumberValide = 'Numéro téléphone vide !';
      });
    else if (!validatePhoneNumber(_phoneNumberFieldTextController.text))
      setState(() {
        _phoneNumberValide = 'Le numéro téléphone doit être valide.';
      });
    else
      setState(() {
        _phoneNumberValide = null;
      });
  }

  bool validatePhoneNumber(String value) {
    String pattern = r"^(\+\d{1,2}\s?)?1?\-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{3}$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  void _verifyName() {
    if (_nameFieldTextController.text == null || _nameFieldTextController.text == '')
      setState(() {
        _nameValide = 'Le nom est vide !';
      });
    else if (!validateName(_nameFieldTextController.text))
      setState(() {
        _nameValide = 'Veillez entrer votre nom complet, svp.';
      });
    else
      setState(() {
        _nameValide = null;
      });
  }

  bool validateName(String value) {
    String pattern = r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
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
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.all(20.0),
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
            TextFormField(
              maxLines: 1,
              focusNode: _nameFocusNode,
              controller: _nameFieldTextController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.name,
              decoration: new InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                helperText: "",
                errorText: _nameValide,
                labelText: 'Nom complet:',
                labelStyle: Theme.of(context).textTheme.caption.copyWith(color: Colors.white60),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Style.Colors.titleColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Style.Colors.titleColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: new Icon(
                  Icons.person,
                  color: _nameFieldTextController.text != ''
                      ? _nameValide != null
                          ? Colors.red
                          : Style.Colors.secondaryColor
                      : Style.Colors.secondaryColor,
                ),
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              focusNode: _phoneNumberFocusNode,
              controller: _phoneNumberFieldTextController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                helperText: "",
                prefixText: "+213",
                labelText: 'Phone Number',
                errorText: _phoneNumberValide,
                prefixStyle: TextStyle(color: Style.Colors.secondaryColor),
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
                  Icons.phone,
                  color: _phoneNumberFieldTextController.text != ''
                      ? _phoneNumberValide != null
                          ? Colors.red
                          : Style.Colors.secondaryColor
                      : Style.Colors.secondaryColor,
                ),
              ),
            ),
            SizedBox(height: 5),
            FloatingActionButton.extended(
              elevation: 0,
              heroTag: null,
              label: Text("S'inscrire."),
              icon: Icon(Icons.person_add),
              foregroundColor: Colors.black,
              backgroundColor: Style.Colors.secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              onPressed: (_nameValide != null && _emailValide != null && _passwordValide != null && _phoneNumberValide != null)
                  ? null
                  : () async {
                      if (_mailAdressFieldTextController.text.isEmpty && _passwordFieldTextController.text.isEmpty && _nameFieldTextController.text.isEmpty && _phoneNumberFieldTextController.text.isEmpty) {
                        _verifyEmail();
                        _verifyPassword();
                        _verifyName();
                        _verifyPhoneNumber();
                      } else {
                        final auth = Provider.of<UserAuth>(context, listen: false);
                        Loader loader = Loader();
                        final GlobalKey<State> key = new GlobalKey<State>();
                        loader.showLoadingDialog(context, key);
                        String error = await auth.createNewUser(
                          _mailAdressFieldTextController.text,
                          _passwordFieldTextController.text,
                          _nameFieldTextController.text,
                          _phoneNumberFieldTextController.text,
                        );
                        loader.removeLoadingDialog(context, key);
                        if (error == null)
                          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => MyApp()));
                        else
                          await showError(error);
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
