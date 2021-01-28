import 'package:flutter/material.dart';

class ReservationsScreen extends StatefulWidget {
  ReservationsScreen({Key key}) : super(key: key);

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: TabBar(
            isScrollable: true,
            tabs: [
              Text(
                "En attente",
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              Text(
                "Non Confirmé",
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              Text(
                "Expirée",
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
        body: Column(
          children: [],
        ),
      ),
    );
  }
}
