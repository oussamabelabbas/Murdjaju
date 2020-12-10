import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class SignupForm extends StatefulWidget {
  SignupForm({Key key}) : super(key: key);

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _mailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool passwordObscure = true;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.name,
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _mailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _passwordController,
              keyboardType: TextInputType.visiblePassword,
              obscureText: passwordObscure,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(passwordObscure
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      passwordObscure = !passwordObscure;
                    });
                  },
                ),
                hintText: "Enter password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            RaisedButton(
              color: Style.Colors.secondaryColor,
              textColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text("Signup"),
              onPressed: () async {
                UserCredential uc =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _mailController.text,
                  password: _passwordController.text,
                );
                await FirebaseAuth.instance.signOut();
                FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: _phoneController.text.toString(),
                  timeout: Duration(seconds: 60),
                  verificationCompleted: (pac) async {
                    await uc.user.updatePhoneNumber(pac);
                  },
                  verificationFailed: (FirebaseAuthException exception) {
                    print(exception);
                  },
                  codeAutoRetrievalTimeout: (str) {},
                  codeSent: (String verificationId, [int forceResendingToken]) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        TextEditingController _codeController =
                            TextEditingController();
                        return AlertDialog(
                          title: Text("Give the code?"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                controller: _codeController,
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Confirm"),
                              textColor: Colors.white,
                              color: Colors.blue,
                              onPressed: () async {
                                final code = _codeController.text.trim();
                                AuthCredential credential =
                                    PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: code,
                                );
                                return credential;

                                // userAuth.signInWithCredential(credential);
                              },
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
