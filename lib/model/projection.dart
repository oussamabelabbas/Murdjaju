import 'package:murdjaju/model/salle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'movie.dart';

class Projection {
  final Movie movie;
  final DateTime date;
  final Salle salle;
  final int prixTicket;
  final List<Place> places;

  Projection(this.movie, this.date, this.salle, this.prixTicket, this.places);

  Projection.fromSnaps(DocumentSnapshot projection, DocumentSnapshot movie,
      DocumentSnapshot salle)
      : movie = Movie.fromSnap(movie),
        date = DateTime.fromMillisecondsSinceEpoch(
            projection["date"].millisecondsSinceEpoch),
        salle = Salle.fromSnapshot(salle),
        prixTicket = projection["prixTicket"],
        places = (projection["places"] as List)
            .map((e) => new Place.fromJson(e))
            .toList();

  Projection.fromJson(DocumentSnapshot projection,
      List<DocumentSnapshot> movies, List<DocumentSnapshot> salles)
      : movie = Movie.fromSnap(
            movies.where((movie) => movie.id == projection["movieId"]).first),
        date = DateTime.fromMillisecondsSinceEpoch(
            projection["date"].millisecondsSinceEpoch),
        salle = Salle.fromSnapshot(
            salles.where((salle) => salle.id == projection["salleId"]).first),
        prixTicket = projection["prixTicket"],
        places = (projection["places"] as List)
            .map((e) => new Place.fromJson(e))
            .toList();
}

class Place {
  final String id;
  final bool isReserved;

  Place(this.id, this.isReserved);

  Place.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        isReserved = json['isReserved'];
}
