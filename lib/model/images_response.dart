import 'package:murdjaju/model/image.dart';

class ImageResponse {
  final List<Backdrop> backdrops;
  final List<Poster> posters;
  final String error;

  ImageResponse(
    this.backdrops,
    this.posters,
    this.error,
  );

  ImageResponse.fromJson(Map<String, dynamic> json)
      : backdrops = (json["backdrops"] as List)
            .map((e) => new Backdrop.fromJson(e))
            .toList(),
        posters = (json["posters"] as List)
            .map((e) => new Poster.fromJson(e))
            .toList(),
        error = "";

  ImageResponse.withError(String errorValue)
      : backdrops = List(),
        posters = List(),
        error = errorValue;
}
