import 'package:cloud_firestore/cloud_firestore.dart';

class Salle {
  final String id;
  final String name;
  final int capacity;
  final int rowLength;
  final String screenQuality;

  Salle(
    this.name,
    this.capacity,
    this.rowLength,
    this.screenQuality,
    this.id,
  );

  Salle.fromSnapshot(DocumentSnapshot snap)
      : id = snap["id"],
        name = snap["name"],
        capacity = snap["capacity"],
        rowLength = snap["rowLength"],
        screenQuality = snap["screenQuality"];
}
