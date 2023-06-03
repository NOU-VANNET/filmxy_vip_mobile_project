import 'dart:convert';

List<MovieModel> movieModelFromMap(String str) =>
    List<MovieModel>.from(json.decode(str).map((x) => MovieModel.fromMap(x)));

String movieModelToMap(List<MovieModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap)));

class MovieModel {
  MovieModel({
    this.postId = 0,
    this.postTitle = '',
    this.isAdult = '',
    this.thumbnail = '',
    this.year = '',
    this.rating = '',
    this.released = '',
    this.runtime = '',
    this.link = '',
    this.trailer = '',
    this.story = '',
    this.altTitle = '',
    this.banner = '',
    this.language = '',
    this.type = '',
    this.runningEpisode = '',
    this.status = '',
    this.titlePNG = '',
    this.genres = '',
    this.backgroundImage = '',
    this.subtitleUrl,
    this.indexList = 1000,
    this.preview = "",
    this.webBanner = "",
    this.schedulePost,
  });

  num postId = 0;
  String postTitle = '';
  String isAdult = '';
  String thumbnail = '';
  String year = '';
  String rating = '';
  String released = '';
  String runtime = '';
  String link = '';
  String trailer = '';
  String story = '';
  String altTitle = '';
  String banner = '';
  String language = '';
  String type = '';
  String runningEpisode = '';
  String status = '';
  String titlePNG = '';
  String genres = '';
  String backgroundImage = '';
  String preview = '';
  String webBanner = '';
  String? subtitleUrl;
  num indexList = 1000;
  Map<String, dynamic>? schedulePost;

  factory MovieModel.fromMap(Map<String, dynamic> json) => MovieModel(
    postId: json["post_id"] ?? 0,
    postTitle: json["post_title"] ?? '',
    isAdult: json["is_adult"] ?? '',
    thumbnail: json["thumbnail"] ?? '',
    year: json["year"] ?? '',
    rating: json["rating"] ?? '',
    released: json["released"] ?? '',
    runtime: json["runtime"] ?? '',
    link: json["link"] ?? '',
    trailer: json["trailer"] ?? '',
    story: json["story"] ?? '',
    altTitle: json["alt_title"] ?? '',
    banner: json["banner"] ?? '',
    language: json["language"] ?? '',
    type: json["type"] ?? '',
    runningEpisode: json["running_episode"] ?? '',
    status: json["status"] ?? '',
    titlePNG: json["titlePNG"] ?? '',
    genres: json["genres"] ?? '',
    backgroundImage: json["backgroundImage"] ?? '',
    subtitleUrl: json["subtitleUrl"] ?? "",
    schedulePost: json["schedule"] ?? {},
    indexList: json["index_list"] ?? 1000,
    preview: json["preview_link"] ?? "",
    webBanner: json["webBannerImage"] ?? "",
  );

  Map<String, dynamic> toMap({num? indexed}) => {
    "post_id": postId,
    "post_title": postTitle,
    "is_adult": isAdult,
    "thumbnail": thumbnail,
    "banner": banner,
    "year": year,
    "alt_title": altTitle,
    "rating": rating,
    "language": language,
    "released": released,
    "runtime": runtime,
    "trailer": trailer,
    "story": story,
    "type": type,
    "link": link,
    "status": status,
    "running_episode": runningEpisode,
    "titlePNG": titlePNG,
    "genres": genres,
    "backgroundImage": backgroundImage,
    "subtitleUrl": subtitleUrl,
    "index_list": indexed ?? indexList,
    "schedule": schedulePost,
    "preview_link": preview,
    "webBannerImage": webBanner,
  };
}
