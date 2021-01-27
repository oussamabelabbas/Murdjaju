import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuth with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool _loggedIn = false;
  User _user;
  String _phoneNumber;

  UserAuth() {
    this._user = FirebaseAuth.instance.currentUser;
    this._loggedIn = FirebaseAuth.instance.currentUser != null;
    setPhoneNumber();
  }

  Future<void> setPhoneNumber() async {
    print("I am here ");
    if (FirebaseAuth.instance.currentUser == null)
      this._phoneNumber = null;
    else {
      if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.phoneNumber != null && FirebaseAuth.instance.currentUser.phoneNumber.isNotEmpty)
        this._phoneNumber = FirebaseAuth.instance.currentUser.phoneNumber;
      else {
        DocumentSnapshot snap = await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser.uid).get();
        if (snap.exists) this._phoneNumber = "+213" + snap['phoneNumber'];
      }
    }

    notifyListeners();
  }

  bool get loggedIn => _loggedIn;
  User get user => _user;
  String get phoneNumber => _phoneNumber;

  Future<String> createNewUser(String mailAdress, String password, String name, String phoneNumber) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(email: mailAdress, password: password);
      await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).set(
        {"phoneNumber": "+213" + phoneNumber, "mailAdress": mailAdress, "name": ""},
      );
      uc.user.updateProfile(
        displayName: name,
      );
      _user = uc.user;
      _loggedIn = true;
      _phoneNumber = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signupWithMailAndPassword(String userEmail, String userPassword) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(email: userEmail, password: userPassword);
      await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).set(
        {
          "phoneNumber": "",
          "mailAdress": userEmail,
          "name": "",
        },
      );
      _user = uc.user;
      _loggedIn = true;
      _phoneNumber = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> verifyPhoneNumber(PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.currentUser.updatePhoneNumber(credential);
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
    print(_loggedIn.toString() + "===>");
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    UserCredential uc = await _auth.signInWithCredential(credential);
    _user = uc.user;
    _loggedIn = true;
    notifyListeners();
    print(_loggedIn.toString() + "===>");
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _loggedIn = false;
    _phoneNumber = null;
    notifyListeners();
  }

  Future<void> updateUser(String displayName, String phoneNumber) async {
    //if (displayName != this._user.displayName && phoneNumber != this._phoneNumber) {
    await FirebaseFirestore.instance.collection("Users").doc(_user.uid).update(
      {"phoneNumber": "+213" + phoneNumber, "name": displayName},
    );
    if (displayName != null && displayName != _user.displayName) await _user.updateProfile(displayName: displayName);
    _user = FirebaseAuth.instance.currentUser;
    _phoneNumber = "+213" + phoneNumber;
    // }
    notifyListeners();
  }

  Future<void> loginUser(String userEmail, String userPassword) async {
    UserCredential uc = await _auth.signInWithEmailAndPassword(email: userEmail, password: userPassword);
    _user = uc.user;
    _loggedIn = true;
    notifyListeners();
    await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).get().then((value) => _phoneNumber = value['phoneNumber']);
  }

  Future<User> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String> signinWithMailAndPassword(String userEmail, String userPassword) async {
    try {
      UserCredential uc = await _auth.signInWithEmailAndPassword(email: userEmail, password: userPassword);
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).get();
      if (snap.exists)
        _phoneNumber = snap['phoneNumber'];
      else
        await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).set(
          {
            "phoneNumber": "",
            "mailAdress": userEmail,
            "name": "",
          },
        );
      _user = uc.user;
      _loggedIn = true;
      notifyListeners();
      return null;
    } catch (e) {
      print('error');
      return e.toString();
    }
  }
}
