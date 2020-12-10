import 'package:cloud_firestore/cloud_firestore.dart';

class Firebase {
  final String id;
  final String movieId;

  Firebase(
    this.id,
    this.movieId,
  );

  Firebase.fromSnapshots(DocumentSnapshot snap)
      : id = snap.id,
        movieId = snap["id"].toString();
}
