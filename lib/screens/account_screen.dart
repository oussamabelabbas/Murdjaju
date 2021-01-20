import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
  UserAuth auth;
  ScrollController scrollController = ScrollController();

  String _nameValide;
  TextEditingController _nameFieldTextController;
  FocusNode _nameFieldFocusNode;

  String _mailValide;
  TextEditingController _mailFieldTextController;
  FocusNode _mailFieldFocusNode;

  String _phoneNumberValide;
  TextEditingController _phoneNumberFieldTextController;
  FocusNode _phoneNumberFieldFocusNode;

  bool _enableEditing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<UserAuth>(context, listen: false);
    resetFields();
  }

  Void resetFields() {
    _nameFieldTextController = TextEditingController(text: auth.user.displayName);
    _mailFieldTextController = TextEditingController(text: auth.user.email);
    _phoneNumberFieldTextController = TextEditingController(text: auth.phoneNumber.substring(auth.phoneNumber.length - 9));
  }

  void validateName(String value) {
    // String pattern = r"^[a-z ,.\'-]+$";
    String pattern = r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)";

    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      _nameValide = "Nom non valide.";
    else
      _nameValide = null;
    setState(() {});
  }

  void validatePhoneNumber(String value) {
    // String pattern = r"^[a-z ,.\'-]+$";
    if (value.isEmpty)
      _phoneNumberValide = "Empty !";
    else if (value.startsWith("0"))
      _phoneNumberValide = "Please remove 0 from the start !";
    else if (value.length < 9)
      _phoneNumberValide = "To short !";
    else
      _phoneNumberValide = null;

    setState(() {});
  }

  void validateMail(String value) {
    // String pattern = r"^[a-z ,.\'-]+$";
    String pattern = r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      _mailValide = "Adresse mail non valide.";
    else
      _mailValide = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
        actions: _enableEditing
            ? [
                IconButton(
                  icon: Icon(MdiIcons.contentSave, color: Colors.green),
                  onPressed: () async {
                    if (_nameValide == null && _mailValide == null && _phoneNumberValide == null) {
                      await auth.updateUser(
                        _nameFieldTextController.text,
                        _mailFieldTextController.text,
                        "+213" + _phoneNumberFieldTextController.text,
                      );
                      setState(() {
                        _enableEditing = !_enableEditing;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() {
                    _enableEditing = !_enableEditing;
                    resetFields();
                  }),
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => setState(() => _enableEditing = !_enableEditing),
                ),
              ],
      ),
      body: ListView(
        shrinkWrap: true,
        controller: scrollController,
        padding: EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Center(
              child: TextFormField(
                enabled: _enableEditing,
                controller: _nameFieldTextController,
                focusNode: _nameFieldFocusNode,
                maxLines: 1,
                keyboardType: TextInputType.name,
                autofocus: false,
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _nameFieldTextController.text != ''
                            ? _nameValide != null
                                ? Colors.red
                                : Style.Colors.secondaryColor
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor), borderRadius: BorderRadius.circular(10)),
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor.withOpacity(.25)), borderRadius: BorderRadius.circular(10)),
                  helperText: '',
                  errorMaxLines: 1,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  errorText: _nameValide ?? null,
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Style.Colors.secondaryColor),
                  prefixIcon: new Icon(
                    Icons.person,
                    color: _nameFieldTextController.text != ''
                        ? _nameValide != null
                            ? Colors.red
                            : Style.Colors.secondaryColor
                        : Style.Colors.secondaryColor,
                  ),
                ),
                autocorrect: false,
                onChanged: (value) => validateName(value),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Center(
              child: TextFormField(
                enabled: false, //_enableEditing,
                controller: _mailFieldTextController,
                focusNode: _mailFieldFocusNode,
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _mailFieldTextController.text != ''
                            ? _mailValide != null
                                ? Colors.red
                                : Style.Colors.secondaryColor
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor), borderRadius: BorderRadius.circular(10)),
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor.withOpacity(.25)), borderRadius: BorderRadius.circular(10)),
                  helperText: '',
                  errorMaxLines: 1,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  errorText: _mailValide ?? null,
                  labelText: 'Adresse mail',
                  labelStyle: TextStyle(color: Style.Colors.secondaryColor),
                  prefixIcon: new Icon(
                    Icons.mail,
                    color: _mailFieldTextController.text != ''
                        ? _mailValide != null
                            ? Colors.red
                            : Style.Colors.secondaryColor
                        : Style.Colors.secondaryColor,
                  ),
                ),
                autocorrect: false,
                onChanged: (text) => validateMail(text),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Center(
              child: TextFormField(
                enabled: _enableEditing,
                controller: _phoneNumberFieldTextController,
                focusNode: _phoneNumberFieldFocusNode,
                maxLines: 1,
                // inputFormatters: [FilteringTextInputFormatter("r^[0-9]", allow: true)],
                keyboardType: TextInputType.phone,
                autofocus: false,
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: _phoneNumberFieldTextController.text != ''
                            ? _phoneNumberValide != null
                                ? Colors.red
                                : Style.Colors.secondaryColor
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor), borderRadius: BorderRadius.circular(10)),
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Style.Colors.titleColor.withOpacity(.25)), borderRadius: BorderRadius.circular(10)),
                  helperText: '',
                  errorMaxLines: 1,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  errorText: _phoneNumberValide ?? null,
                  labelText: 'Numéro de téléphone:',
                  labelStyle: TextStyle(color: Style.Colors.secondaryColor),
                  prefixText: auth.phoneNumber.substring(0, auth.phoneNumber.length - 9),
                  prefixStyle: TextStyle(color: Style.Colors.secondaryColor),
                  prefixIcon: new Icon(
                    Icons.phone,
                    color: _phoneNumberFieldTextController.text != ''
                        ? _phoneNumberValide != null
                            ? Colors.red
                            : Style.Colors.secondaryColor
                        : Style.Colors.secondaryColor,
                  ),
                ),
                autocorrect: false,
                onChanged: (text) => validatePhoneNumber(text),
              ),
            ),
          ),
          Center(
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red,
              label: Text('Déconnexion'),
              icon: Icon(Icons.logout),
              onPressed: () async {
                await auth.logout();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
