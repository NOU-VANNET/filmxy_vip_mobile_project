// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

List<GenreTypeModel> genreTypeModelFromMap(String str) => List<GenreTypeModel>.from(json.decode(str).map((x) => GenreTypeModel.fromMap(x)));

String genreTypeModelToMap(List<GenreTypeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class GenreTypeModel {
  GenreTypeModel({
    this.name = "",
    this.link = "",
  });

  String name = "";
  String link = "";

  factory GenreTypeModel.fromMap(Map<String, dynamic> json) => GenreTypeModel(
    name: json["name"],
    link: json["link"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "link": link,
  };
}
