import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuth with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool _loggedIn = false;
  bool _haveData = false;
  User _user;
  String _phoneNumber;

  UserAuth(this._user, this._loggedIn, this._haveData, this._phoneNumber);

  bool get loggedIn => _loggedIn;
  bool get haveData => _haveData;
  User get user => _user;
  String get phoneNumber => _user.phoneNumber != null ? _user.phoneNumber : _phoneNumber;

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
    _haveData = uc.user.displayName != null;
    notifyListeners();
    print(_loggedIn.toString() + "===>");
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _haveData = false;
    _loggedIn = false;
    _phoneNumber = null;
    notifyListeners();
  }

  Future<void> updateUser(String displayName, String mailAdress, String phoneNumber) async {
    if (mailAdress != null && mailAdress != _user.email) await _user.updateEmail(mailAdress);
    if (displayName != null && displayName != _user.displayName) await _user.updateProfile(displayName: displayName);
    await FirebaseFirestore.instance.collection("Users").doc(_user.uid).update(
      {
        "phoneNumber": phoneNumber,
        "name": displayName,
        if (mailAdress != null && mailAdress != _user.email) "mailAdress": mailAdress,
      },
    );

    _user = FirebaseAuth.instance.currentUser;
    _phoneNumber = phoneNumber;

    _haveData = true;

    notifyListeners();
  }

  Future<void> loginUser(String userEmail, String userPassword) async {
    UserCredential uc = await _auth.signInWithEmailAndPassword(email: userEmail, password: userPassword);
    _user = uc.user;
    _loggedIn = true;
    notifyListeners();
    await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).get().then((value) => _phoneNumber = value['phoneNumber']);
  }

  Future<void> signupWithMailAndPassword(String userEmail, String userPassword) async {
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
    _haveData = uc.user.displayName != null;
    _phoneNumber = null;
    notifyListeners();
  }

  Future<User> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<String> signinWithMailAndPassword(String userEmail, String userPassword) async {
    try {
      UserCredential uc = await _auth.signInWithEmailAndPassword(email: userEmail, password: userPassword);
      _user = uc.user;
      _loggedIn = true;
      _haveData = uc.user.displayName != null;
      notifyListeners();
      await FirebaseFirestore.instance.collection("Users").doc(uc.user.uid).get().then((value) => _phoneNumber = value['phoneNumber']);
      return "";
    } catch (e) {
      return e.toString();
    }
  }
}
