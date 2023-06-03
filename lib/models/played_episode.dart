import 'dart:convert';

List<PlayedEpisodeModel> playedEpisodesFromMap(String str) => List<PlayedEpisodeModel>.from(json.decode(str).map((e) => PlayedEpisodeModel.fromMap(e)));

class PlayedEpisodeModel {

  String key = "";
  num postId = 0;

  PlayedEpisodeModel({this.key = "", this.postId = 0});

  factory PlayedEpisodeModel.fromMap(Map<String, dynamic> json) => PlayedEpisodeModel(
    key: json['value'] ?? '',
    postId: json['postId'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'value': key,
    'postId': postId,
  };

}