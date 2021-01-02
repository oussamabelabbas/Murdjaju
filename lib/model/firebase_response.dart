import 'package:murdjaju/model/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseResponse {
  final List<Firebase> movies;
  final String error;

  FirebaseResponse(this.movies, this.error);

  FirebaseResponse.fromSnapshots(List<DocumentSnapshot> snapshots)
      : movies = snapshots.map((e) => new Firebase.fromSnapshots(e)).toList(),
        error = "";

  FirebaseResponse.withError(String errorValue)
      : movies = [],
        error = errorValue;
}
