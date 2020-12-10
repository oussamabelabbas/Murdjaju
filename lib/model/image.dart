class Backdrop {
  final double aspectRatio;
  final String path;

  Backdrop(
    this.aspectRatio,
    this.path,
  );

  Backdrop.fromJson(Map<String, dynamic> json)
      : aspectRatio = json["aspect_ratio"],
        path = json["file_path"];
}

class Poster {
  final double aspectRatio;
  final String path;

  Poster(
    this.aspectRatio,
    this.path,
  );

  Poster.fromJson(Map<String, dynamic> json)
      : aspectRatio = json["aspect_ratio"],
        path = json["file_path"];
}
