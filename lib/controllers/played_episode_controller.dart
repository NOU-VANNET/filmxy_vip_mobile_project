import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/models/played_episode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayedEpisodeController extends GetxController {

  List<PlayedEpisodeModel> _playedList = [];
  List<PlayedEpisodeModel> get playedList => _playedList;

  final String _key = 'played_episodes';

  late SharedPreferences db;

  Future init() async {
    db = await SharedPreferences.getInstance();
    String str = db.getString(_key) ?? "[]";
    _playedList = await compute(playedEpisodesFromMap, str);
    update();
  }

  bool played(FileLink file, num postId) {
    final i = _playedList.firstWhereOrNull((e) => e.postId == postId);
    if (i != null) {
      return i.key.toLowerCase() == file.key.toLowerCase();
    } else {
      return false;
    }
  }

  String? key(num postId) {
    final i = _playedList.firstWhereOrNull((e) => e.postId == postId);
    if (i != null) {
      return i.key;
    } else {
      return null;
    }
  }

  Future add(FileLink file, num postId) async {
    bool isEmpty = (_playedList.firstWhereOrNull((e) => e.postId == postId)) == null;
    if (isEmpty) {
      _playedList.add(PlayedEpisodeModel(postId: postId, key: file.key));
    } else {
      _playedList[_playedList.indexWhere((e) => e.postId == postId)] = PlayedEpisodeModel(key: file.key, postId: postId);
    }
    update();
    await Future.delayed(const Duration(milliseconds: 200));
    final maps = _playedList.map((e) => e.toMap()).toList();
    final str = json.encode(maps);
    db.setString(_key, str);
  }

}