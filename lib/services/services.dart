import 'dart:convert';
import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart' as get_x;
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/models/cache_key_model.dart';
import 'package:vip/models/caption_model.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/models/genre_type.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/models/subtitle_model.dart';
import 'package:vip/repository/repository.dart';
import 'package:http/http.dart';
import 'package:vip/utils/urls.dart';
import 'package:vip/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

String token = "";

class Services implements Repository {
  Map<String, String>? get header => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-APP-KEY':
            'vTBsD91mUHpnkE4l5Fy5sJxn0nHBYNrz3tvQlDEwUwvgTk2BhBznSOUwT8M7ZYN7',
        'X-APP-SECRET':
            '*07CS23ZtCye16pAacInyA#ONqvYWpmulOUrsm%A\$dQzme3^qAmiX0fjQ0v#SE3g',
      };

  Map<String, String>? get _xHeader => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-APP-KEY':
            'vTBsD91mUHpnkE4l5Fy5sJxn0nHBYNrz3tvQlDEwUwvgTk2BhBznSOUwT8M7ZYN7',
        'X-APP-SECRET':
            '*07CS23ZtCye16pAacInyA#ONqvYWpmulOUrsm%A\$dQzme3^qAmiX0fjQ0v#SE3g',
      };

  @override
  Future<List<MovieModel>> fetchData(String type,
      {int? page, String? filterType}) async {
    try {
      final uri = Uri.parse(Urls.apiDomain(
          route:
              '$type${(page != null) ? "/page/$page" : ""}${(filterType != null) ? "?$filterType=true" : ""}'));
      Response response = await get(
        uri,
        headers: header,
      );
      if (response.statusCode == 200) {
        return await compute(movieModelFromMap, response.body);
      }
      return [];
    } on PlatformException catch (e) {
      throw "Error while getting data...\nMessage: ${e.message}";
    }
  }

  Future<bool> get canShowMovie async {
    var res = await get(Uri.parse(Urls.apiDomain(route: 'homepage')),
        headers: header);
    return res.statusCode == 200;
  }

  @override
  Future<List<GenreTypeModel>> getGenreType(String url) async {
    try {
      Response response = await get(Uri.parse(url), headers: header);
      if (response.statusCode == HttpStatus.ok) {
        return await compute(genreTypeModelFromMap, response.body);
      } else {
        throw Exception(
            "Error while getting genre type: ${response.statusCode}");
      }
    } on PlatformException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  @override
  Future<DetailModel> getDetailModel(String link) async {
    try {
      Response response = await get(Uri.parse(link), headers: header);
      if (response.statusCode == HttpStatus.ok) {
        return await compute(detailModelFromMap, response.body);
      } else {
        throw Exception(
            "Error while getting detail model: ${response.statusCode}\n $link");
      }
    } on PlatformException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  @override
  Future<List<MovieModel>> searchMovie(String query) async {
    try {
      final url = Uri.parse(Urls.apiDomain(route: "search"));
      Response response = await post(
        url,
        headers: header,
        body: jsonEncode({"query": query, "type": "all"}),
      );
      if (response.statusCode == HttpStatus.ok) {
        return await compute(movieModelFromMap, response.body);
      } else {
        throw Exception("Error while searching: ${response.statusCode}");
      }
    } on PlatformException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  @override
  Future<String?> getDirectLink(String linkId) async {
    try {
      final url = Uri.parse(Urls.apiDomain(route: "directlink"));
      Response response = await post(
        url,
        headers: header,
        body: jsonEncode(
          {
            "link_ids": [linkId]
          },
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        Map map = await jsonDecode(response.body);
        return map[linkId];
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  Future<File?> saveAuthFromClient(Map<String, dynamic> responseJson) async {
    String expireDate = DateTime.now().toString();
    var dir = await getExternalStorageDirectory();
    if (dir != null) {
      String parentPath = dir.path.split('files').first;
      File file = File('${parentPath}auth/auth.json');
      final data = {
        'token': responseJson['token'],
        'user_email': responseJson['user_email'],
        'user_name': responseJson['user_name'],
        'expire': expireDate,
      };
      String encodedData = json.encode(data);
      return await file.writeAsString(encodedData);
    } else {
      return null;
    }
  }

  @override
  Future<List<SubtitleModel>> getSubtitles(String url) async {
    try {
      final subUrl = url.split("/?").first;
      final subUID = subUrl.split("/").last;
      String uri = "https://www.mysubs.org/api/v1/subtitles/$subUID";
      final link = subUrl == uri ? Uri.parse(subUrl) : Uri.parse(uri);
      Response response = await get(link);
      if (response.statusCode == HttpStatus.ok) {
        return await compute(subtitleModelFromMap, response.body);
      } else {
        throw Exception(
            "Error while getting subtitles: ${response.statusCode}");
      }
    } on PlatformException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  @override
  Future<String> getSubtitleSource(String k) async {
    try {
      final url = Uri.parse("https://www.mysubs.org/get-subtitle/$k");
      Response response = await get(url);
      if (response.statusCode == HttpStatus.ok) {
        return utf8.decode(response.bodyBytes, allowMalformed: true);
      } else {
        throw Exception(
            "Error while getting subtitle kId $k: ${response.statusCode}");
      }
    } on PlatformException catch (e) {
      throw Exception(e.message.toString());
    }
  }

  @override
  List<CaptionModel> captionDecode(String source) {
    RegExp regExp;
    regExp = RegExp(
      r'((\d{2}):(\d{2}):(\d{2})\,(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\,(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
      caseSensitive: false,
      multiLine: true,
    );
    final matches = regExp.allMatches(source).toList();
    final List<CaptionModel> captions = [];
    for (final RegExpMatch regExpMatch in matches) {
      final startTimeHours = int.parse(regExpMatch.group(2)!);
      final startTimeMinutes = int.parse(regExpMatch.group(3)!);
      final startTimeSeconds = int.parse(regExpMatch.group(4)!);
      final startTimeMilliseconds = int.parse(regExpMatch.group(5)!);

      final endTimeHours = int.parse(regExpMatch.group(7)!);
      final endTimeMinutes = int.parse(regExpMatch.group(8)!);
      final endTimeSeconds = int.parse(regExpMatch.group(9)!);
      final endTimeMilliseconds = int.parse(regExpMatch.group(10)!);
      final text = removeAllHtmlTags(regExpMatch.group(11)!);

      final startTime = Duration(
          hours: startTimeHours,
          minutes: startTimeMinutes,
          seconds: startTimeSeconds,
          milliseconds: startTimeMilliseconds);
      final endTime = Duration(
          hours: endTimeHours,
          minutes: endTimeMinutes,
          seconds: endTimeSeconds,
          milliseconds: endTimeMilliseconds);
      captions.add(
        CaptionModel(start: startTime, end: endTime, data: text.trim()),
      );
    }
    return captions;
  }

  String removeAllHtmlTags(String htmlText) {
    final exp = RegExp(
      '(<[^>]*>)',
      multiLine: true,
    );
    var newHtmlText = htmlText;
    exp.allMatches(htmlText).toList().forEach(
      (RegExpMatch regExpMatch) {
        if (regExpMatch.group(0) == '<br>') {
          newHtmlText = newHtmlText.replaceAll(regExpMatch.group(0)!, '\n');
        } else {
          newHtmlText = newHtmlText.replaceAll(regExpMatch.group(0)!, '');
        }
      },
    );
    return newHtmlText;
  }

  @override
  CaptionModel? findCaptionFromDuration(
      List<CaptionModel> captions, VideoPlayerController controller) {
    CaptionModel? caption;
    final videoPlayerPosition = controller.value.position;
    for (final CaptionModel subtitleItem in captions) {
      final bool validStartTime = videoPlayerPosition.inMilliseconds >
          subtitleItem.start.inMilliseconds;
      final bool validEndTime =
          videoPlayerPosition.inMilliseconds < subtitleItem.end.inMilliseconds;
      if (validStartTime && validEndTime) {
        caption = subtitleItem;
      }
    }
    return caption;
  }

  @override
  Future<String> getDetailCache() async {
    final db = await SharedPreferences.getInstance();
    return db.getString(CacheKeyModel.cachedDetailKey) ?? "[]";
  }

  @override
  Future setDetailCache(List<DetailModel> dataList) async {
    final db = await SharedPreferences.getInstance();
    final maps = dataList.map((e) => e.toMap()).toList();
    final data = json.encode(maps);
    return db.setString(CacheKeyModel.cachedDetailKey, data);
  }

  @override
  Future<String> fetchUrlBody(String url) async {
    Response response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Error while getting privacy policy");
    }
  }

  @override
  Future<List<MovieModel>> getMoviesTypeList(String url) async {
    Response response = await get(Uri.parse(url), headers: header);
    if (response.statusCode == 200) {
      return await compute(movieModelFromMap, response.body);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> serverRegister(
      String username, String email, String password, String inviteCode) async {
    try {
      Map<String, dynamic> body = {
        "username": username,
        "email": email,
        "password": password,
        "confirm_password": password,
        "invite_code": inviteCode,
      };

      var res = await post(
        Uri.parse(
          Urls.apiDomain(route: 'register'),
        ),
        headers: _xHeader,
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        return {
          "code": "success",
          "data": res.body,
        };
      } else {
        final map = json.decode(res.body);
        return {"code": "error", "message": map['message']};
      }
    } on PlatformException catch (e) {
      return {
        "code": "error",
        "message": e.message.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> serverLogin(
      String login, String password) async {
    try {
      Map<String, dynamic> body = {"login": login, "password": password};
      Response response = await post(
        Uri.parse(Urls.apiDomain(route: "login")),
        body: jsonEncode(body),
        headers: _xHeader,
      );
      if (response.statusCode == 200) {
        return {
          "code": "success",
          "data": response.body,
        };
      } else {
        final map = json.decode(response.body);
        return {"code": "error", "message": map['message']};
      }
    } on PlatformException catch (e) {
      return {
        "code": "error",
        "message": e.message.toString(),
      };
    }
  }

  @override
  Future<String?> download({
    required String linkId,
    required String filename,
    required num postId,
  }) async {
    Utils().showToast('Please wait...');
    String? directLink = await getDirectLink(linkId);
    if (directLink != null) {
      final dlc = get_x.Get.put(DownloadController());

      String fileName = "$postId. $filename.MP4".replaceAll(":", "");

      final dlPath = await getLocalDownloadPath;
      final exist =
          await dlc.checkAndRemoveDownloadItems(path: "$dlPath/$fileName");

      if (!exist) {
        final dir = Directory('$dlPath/');
        final savePath = await dir.create(recursive: true);
        String? id = await FlutterDownloader.enqueue(
          url: directLink,
          savedDir: savePath.path,
          showNotification: true,
          openFileFromNotification: false,
          saveInPublicStorage: false,
          fileName: fileName,
        );
        Utils().showToast('Started Download: $filename');
        return id;
      } else {
        Utils().showToast('Video is already exist!');
        return null;
      }
    } else {
      Utils().showToast('Something went wrong! Please choose another type.');
      return null;
    }
  }

  @override
  Future<String> get getLocalDownloadPath async =>
      await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );
}
