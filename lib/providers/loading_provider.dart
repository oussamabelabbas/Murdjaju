import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoadingProvider with ChangeNotifier {
  LoadingProvider();

  bool _appIsLoading = false;

  bool get appIsLoading => _appIsLoading;

  Future<void> changeLoadingState() async {
    _appIsLoading = _appIsLoading;
    notifyListeners();
  }
}
