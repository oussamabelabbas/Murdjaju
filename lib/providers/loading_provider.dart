import 'package:bd_progress_bar/bdprogreebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:murdjaju/style/theme.dart' as Style;

class LoadingProvider with ChangeNotifier {
  LoadingProvider();

  bool _appIsLoading = false;

  bool get appIsLoading => _appIsLoading;

  Future<void> changeLoadingState() async {
    _appIsLoading = _appIsLoading;
    notifyListeners();
  }
}

class Loader {
  Loader() {
    _loader = Loader2(
      color1: Style.Colors.secondaryColor,
      color2: Style.Colors.titleColor,
      color3: Style.Colors.secondaryColor,
    );
  }

  Widget _loader;

  Widget get loader => _loader;

  Future<bool> showLoadingDialog(BuildContext context, GlobalKey key) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => true,
          child: SimpleDialog(
            elevation: 0,
            key: key,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    _loader,
                    SizedBox(height: 10),
                    Text(
                      "Une minute, SVP....",
                      style: TextStyle(color: Style.Colors.titleColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    print("I returned");
    return true;
  }

  Future<void> removeLoadingDialog(BuildContext context, GlobalKey key) async {
    Navigator.of(context, rootNavigator: true).pop();
    print("I pooped :3");
  }
  //close the dialoge

}
