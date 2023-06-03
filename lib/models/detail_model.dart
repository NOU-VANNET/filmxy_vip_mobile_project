// To parse this JSON data, do
//
//     final detailModel = detailModelFromMap(jsonString);

import 'dart:convert';

List<DetailModel> detailModelListFromJson(String str) =>
    List<DetailModel>.from(json.decode(str).map((x) => DetailModel.fromMap(x)));

DetailModel detailModelFromMap(String str) =>
    DetailModel.fromMap(json.decode(str));

String detailModelToMap(DetailModel data) => json.encode(data.toMap());

class DetailModel {
  DetailModel({
    this.postId = 0,
    this.postTitle = '',
    this.thumbnail = '',
    this.banner = '',
    this.year = '',
    this.altTitle = '',
    this.rating = '',
    this.language = '',
    this.released = '',
    this.runtime = '',
    this.trailer = '',
    this.story = '',
    this.type = '',
    required this.castCrew,
    required this.relatedPosts,
    required this.trendingPosts,
    required this.fileLink,
    this.subtitles = '',
  });

  num postId;
  String postTitle;
  String thumbnail;
  String banner;
  String year;
  String altTitle;
  String rating;
  String language;
  String released;
  String runtime;
  String trailer;
  String story;
  String type;
  List<CastCrew> castCrew;
  List<Post> relatedPosts;
  List<Post> trendingPosts;
  List<FileLink> fileLink;
  String subtitles;

  factory DetailModel.fromMap(Map<String, dynamic> json) => DetailModel(
        postId: json["post_id"] ?? 0,
        postTitle: json["post_title"] ?? '',
        thumbnail: json["thumbnail"] ?? '',
        banner: json["banner"] ?? '',
        year: json["year"] ?? '',
        altTitle: json["alt_title"] ?? '',
        rating: json["rating"] ?? '',
        language: json["language"] ?? '',
        released: json["released"] ?? '',
        runtime: json["runtime"] ?? '',
        trailer: json["trailer"] ?? '',
        story: json["story"] ?? '',
        type: json["type"] ?? '',
        castCrew: List<CastCrew>.from(
            json["cast_crew"].map((x) => CastCrew.fromMap(x))),
        relatedPosts:
            List<Post>.from(json["related_posts"].map((x) => Post.fromMap(x))),
        trendingPosts:
            List<Post>.from(json["tranding_posts"].map((x) => Post.fromMap(x))),
        fileLink: List<FileLink>.from(
            json["file_link"].map((x) => FileLink.fromMap(x))),
        subtitles: json["subtitles"],
      );

  Map<String, dynamic> toMap() => {
        "post_id": postId,
        "post_title": postTitle,
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
        "cast_crew": List<dynamic>.from(castCrew.map((x) => x.toMap())),
        "related_posts": List<dynamic>.from(relatedPosts.map((x) => x.toMap())),
        "tranding_posts":
            List<dynamic>.from(trendingPosts.map((x) => x.toMap())),
        "file_link": List<dynamic>.from(fileLink.map((x) => x.toMap())),
        "subtitles": subtitles,
      };
}

class CastCrew {
  CastCrew({
    this.castId = 0,
    this.castName = '',
    this.castPicture = '',
  });

  num castId;
  String castName;
  String castPicture;

  factory CastCrew.fromMap(Map<String, dynamic> json) => CastCrew(
        castId: json["cast_id"] ?? 0,
        castName: json["cast_name"] ?? '',
        castPicture: json["cast_picture"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "cast_id": castId,
        "cast_name": castName,
        "cast_picture": castPicture,
      };
}

class FileLink {
  FileLink({
    this.key = '',
    this.server = '',
    this.lang = '',
    this.resolution = '',
    this.quality = '',
    this.size = '',
    this.linkId = '',
  });

  String key;
  String server;
  String lang;
  String resolution;
  String quality;
  String size;
  String linkId;

  factory FileLink.fromMap(Map<String, dynamic> json) => FileLink(
        key: json["key"] ?? '',
        server: json["server"] ?? '',
        lang: json["lang"] ?? '',
        resolution: json["resolution"] ?? '',
        quality: json["quality"] ?? '',
        size: json["size"] ?? '',
        linkId: json["link_id"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "key": key,
        "server": server,
        "lang": lang,
        "resolution": resolution,
        "quality": quality,
        "size": size,
        "link_id": linkId,
      };
}

class Post {
  Post({
    this.postId = 0,
    this.postTitle = '',
    this.thumbnail = '',
    this.year = '',
    this.rating = '',
    this.released = '',
    this.runtime = '',
    this.link = '',
    this.isAdult = '',
    this.status = '',
    this.runningEpisode = '',
  });

  num postId;
  String postTitle;
  String thumbnail;
  String year;
  String rating;
  String released;
  String runtime;
  String link;
  String isAdult;
  String status;
  String runningEpisode;

  factory Post.fromMap(Map<String, dynamic> json) => Post(
        postId: json["post_id"] ?? 0,
        postTitle: json["post_title"] ?? '',
        thumbnail: json["thumbnail"] ?? '',
        year: json["year"] ?? '',
        rating: json["rating"] ?? '',
        released: json["released"] ?? '',
        runtime: json["runtime"] ?? '',
        link: json["link"] ?? '',
        isAdult: json["is_adult"] ?? '',
        status: json["status"] ?? '',
        runningEpisode: json["running_episode"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "post_id": postId,
        "post_title": postTitle,
        "thumbnail": thumbnail,
        "year": year,
        "rating": rating,
        "released": released,
        "runtime": runtime,
        "link": link,
        "is_adult": isAdult,
        "status": status,
        "running_episode": runningEpisode,
      };
}
