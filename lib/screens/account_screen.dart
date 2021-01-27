import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:murdjaju/bloc/current_week_bloc.dart';
import 'package:murdjaju/providers/auth.dart';
import 'package:murdjaju/providers/loading_provider.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../style/theme.dart' as Style;

class AccountScreen extends StatefulWidget {
  AccountScreen({Key key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserAuth auth;
  bool _enableEditing = false;

  TextEditingController _mailAdressFieldTextController = TextEditingController();
  FocusNode _mailAdressFocusNode = FocusNode();
  TextEditingController _nameFieldTextController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  TextEditingController _phoneNumberFieldTextController = TextEditingController();
  FocusNode _phoneNumberFocusNode = FocusNode();

  String _nameValide;
  String _emailValide;
  String _phoneNumberValide;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<UserAuth>(context, listen: false);
    _nameFieldTextController.addListener(() {
      _verifyName();
    });
    _mailAdressFieldTextController.addListener(() {
      _verifyEmail();
    });
    _phoneNumberFieldTextController.addListener(() {
      _verifyPhoneNumber();
    });
    resetFields();
  }

  void resetFields() {
    _nameFieldTextController.text = auth.user.displayName;
    _mailAdressFieldTextController.text = auth.user.email;
    _phoneNumberFieldTextController.text = auth.phoneNumber.substring(auth.phoneNumber.length - 9);
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
    return Scaffold(
      backgroundColor: Style.Colors.mainColor,
      body: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://image.tmdb.org/t/p/w780/' + currentWeekBloc.subject.value.projections.first.movie.poster),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Style.Colors.mainColor.withOpacity(.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    actions: _enableEditing
                        ? [
                            IconButton(
                              icon: Icon(Icons.save, color: Colors.green),
                              onPressed: () async {
                                _verifyPhoneNumber();
                                _verifyName();
                                if (_nameValide == null && _phoneNumberValide == null) {
                                  final auth = Provider.of<UserAuth>(context, listen: false);
                                  final loader = Loader();
                                  final GlobalKey<State> key = new GlobalKey<State>();
                                  loader.showLoadingDialog(context, key);
                                  await auth.updateUser(_nameFieldTextController.text, _phoneNumberFieldTextController.text);
                                  loader.removeLoadingDialog(context, key);
                                  setState(() => _enableEditing = false);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                resetFields();
                                setState(() => _enableEditing = false);
                              },
                            ),
                          ]
                        : [
                            IconButton(
                              icon: Icon(Icons.edit, color: Style.Colors.secondaryColor),
                              onPressed: () {
                                setState(() => _enableEditing = true);
                              },
                            ),
                          ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Spacer(),
                          TextFormField(
                            readOnly: !_enableEditing,
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
                            readOnly: !_enableEditing,
                            textAlign: TextAlign.center,
                            focusNode: _mailAdressFocusNode,
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
                            readOnly: !_enableEditing,
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
                          Spacer(),
                          FloatingActionButton.extended(
                            icon: Icon(Icons.logout),
                            label: Text("Déconnexion"),
                            onPressed: () async {
                              setState(() => _enableEditing = false);
                              final auth = Provider.of<UserAuth>(context, listen: false);
                              final loader = Loader();
                              final GlobalKey<State> key = new GlobalKey<State>();
                              loader.showLoadingDialog(context, key);
                              await auth.logout();
                              // Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => MyApp()));
                              Navigator.pop(context);
                              loader.removeLoadingDialog(context, key);
                            },
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
