import 'package:murdjaju/authentication/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  bool _passwordIsObscure = true;

  bool _loading = false;
  String errorText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Style.Colors.mainColor.withOpacity(.75),
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  enabled: !_loading,
                  controller: _mailAdressFieldTextController,
                  focusNode: _mailAdressFocusode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (phone) {},
                  validator: (value) {
                    if (value.isEmpty) {
                      print("Error!");
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    errorText: errorText,
                    labelText: 'Adress mail:',
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
                const SizedBox(height: 10.0),
                TextFormField(
                  enabled: !_loading,
                  controller: _passwordFieldTextController,
                  focusNode: _passwordFocusode,
                  obscureText: _passwordIsObscure,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (phone) {},
                  validator: (value) {
                    if (value.isEmpty) {
                      print("Error!");
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_passwordIsObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _passwordIsObscure = !_passwordIsObscure),
                    ),
                    errorText: errorText,
                    labelText: 'Mot de passe:',
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
                const SizedBox(height: 10.0),
                RaisedButton(
                  padding: EdgeInsets.all(2),
                  color: Style.Colors.secondaryColor,
                  textColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: _loading
                        ? CircularProgressIndicator(
                            strokeWidth: .5,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(Style.Colors.secondaryColor),
                          )
                        : Text("S'identifier."),
                  ),
                  onPressed: () async {
                    final auth = Provider.of<UserAuth>(context, listen: false);
                    auth.signinWithMailAndPassword(_mailAdressFieldTextController.text, _passwordFieldTextController.text);
                    Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => MyApp(),
                      ),
                      ModalRoute.withName('/'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
