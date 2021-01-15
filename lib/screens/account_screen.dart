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
  UserAuth auth;
  ScrollController scrollController = ScrollController();

  TextEditingController _nameFieldTextController;
  FocusNode _nameFieldFocusNode;

  String _nameValide;
  bool _enableEditing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = Provider.of<UserAuth>(context, listen: false);
    _nameFieldTextController = TextEditingController(text: auth.user.displayName);
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
        actions: [
          IconButton(
            icon: Icon(_enableEditing ? Icons.edit_off : Icons.edit),
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
                onChanged: (text) => validateName(text),
              ),
            ),
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
      /* SingleChildScrollView(
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
      ), */
    );
  }
}
