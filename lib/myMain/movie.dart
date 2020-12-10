import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';

class Movie {
  final String title;
  final String overview;
  final ProgressiveImage poster;

  Movie(this.title, this.overview, this.poster);
}
