import 'package:murdjaju/authentication/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:provider/provider.dart';

class SigninForm extends StatefulWidget {
  SigninForm({Key key}) : super(key: key);

  @override
  _SigninFormState createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();

  bool _loading = false;
  PhoneNumber _phoneNumber;

  String errorText;
  Future<bool> loginUser(String phone, BuildContext context) async {
    final auth = Provider.of<UserAuth>(context, listen: false);
    setState(() {
      _loading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumber.completeNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await auth.signInWithCredential(credential);
        setState(() {
          _loading = false;
        });
        /*  await Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => MyApp())); */
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception);
        setState(() {
          _loading = false;
        });
      },
      codeSent: (String verificationId, [int forceResendingToken]) {
        setState(() {
          _loading = true;
        });
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.orange.withOpacity(.1),
          builder: (context) {
            return AlertDialog(
              title: Text("Entre votre code! "),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: errorText,
                      labelText: 'Code',
                      labelStyle: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                RaisedButton(
                  color: Colors.orange,
                  textColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Text("Confirmer"),
                  onPressed: () async {
                    final code = _codeController.text.trim();
                    AuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationId, smsCode: code);
                    //await FirebaseAuth.instance.signInWithCredential(credential);

                    await auth.signInWithCredential(credential);
                    /* await Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => MyApp(),
                      ),
                    ); */
                  },
                )
              ],
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (str) {},
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  IntlPhoneField(
                    enabled: !_loading,
                    controller: _phoneController,
                    textAlign: TextAlign.center,
                    dropDownArrowColor: Colors.black,
                    initialCountryCode: 'DZ',
                    keyboardType: TextInputType.phone,
                    autoValidate: true,
                    onChanged: (phone) {
                      _phoneNumber = phone;
                      if (phone.number.isEmpty)
                        errorText = "Empty !";
                      else if (phone.number.startsWith("0"))
                        errorText = "Please remove 0 from the start !";
                      else if (phone.number.length < 9)
                        errorText = "To short !";
                      else
                        errorText = null;

                      print(phone.completeNumber);
                      setState(() {});
                    },
                    showDropdownIcon: false,
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
                      labelStyle: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.orange),
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
                    color: Colors.orange,
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
                              valueColor: AlwaysStoppedAnimation(Colors.orange),
                            )
                          : Text("Send Code"),
                    ),
                    onPressed: !_loading
                        ? () async {
                            //FirebaseAuth.instance.signOut();
                            if (_phoneNumber != null &&
                                _phoneNumber.number.length == 9)
                              loginUser(_phoneController.text, context);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
