import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuth with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  bool _loggedIn = false;
  bool _haveData = false;
  User _user;

  UserAuth(this._user, this._loggedIn, this._haveData);

  bool get loggedIn => _loggedIn;
  bool get haveData => _haveData;
  User get user => _user;

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
    notifyListeners();
  }

  Future<void> updateUser(String displayName, String emailAdress) async {
    await _user.updateProfile(displayName: displayName);
    await _user.updateEmail(emailAdress);
    _haveData = true;

    notifyListeners();
  }

  Future<void> loginUser(String userEmail, String userPassword) async {
    UserCredential uc = await _auth.signInWithEmailAndPassword(
        email: userEmail, password: userPassword);
    _user = uc.user;
    _loggedIn = true;
    notifyListeners();
  }

  Future<User> getCurrentUser() async {
    return _auth.currentUser;
  }
}
