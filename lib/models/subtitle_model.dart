// To parse this JSON data, do
//
//     final subtitleModel = subtitleModelFromMap(jsonString);

import 'dart:convert';

List<SubtitleModel> subtitleModelFromMap(String str) => List<SubtitleModel>.from(json.decode(str).map((x) => SubtitleModel.fromMap(x)));

String subtitleModelToMap(List<SubtitleModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class SubtitleModel {
  SubtitleModel({
    this.l = "",
    this.s = "",
    this.e = "",
    this.k = "",
  });

  String l = "";
  String s = "";
  String e = "";
  String k = "";

  factory SubtitleModel.fromMap(Map<String, dynamic> json) => SubtitleModel(
    l: json["l"],
    s: json["s"],
    e: json["e"],
    k: json["k"],
  );

  Map<String, dynamic> toMap() => {
    "l": l,
    "s": s,
    "e": e,
    "k": k,
  };
}
