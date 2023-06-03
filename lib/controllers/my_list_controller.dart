import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:vip/models/cache_key_model.dart';
import 'package:vip/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyListController extends GetxController {

  List<MovieModel> _movieList = [];
  List<MovieModel> get movieList => _movieList.reversed.toList();

  bool _loading = true;
  bool get loading => _loading;

  Timer? _controlSaver;

  late SharedPreferences _db;

  Future initialize() async {
    _db = await SharedPreferences.getInstance();
    getMovieList();
  }

  Future getMovieList() async {
    String data = _db.getString(CacheKeyModel.myListCachedKey) ?? "[]";
    _movieList = await compute(movieModelFromMap, data);
    _loading = false;
    update();
  }

  Future addOrRemoveMyList(MovieModel movie) async {
    _controlSaver?.cancel();
    final m = _movieList.firstWhereOrNull((e) => e.postId == movie.postId);
    if (m != null) {
      _movieList.removeWhere((e) => e.postId == movie.postId);
    } else {
      _movieList.add(movie);
    }
    update();
    _controlSaver = Timer(const Duration(seconds: 1), () {
      List<Map<String, dynamic>> maps = [];
      for (int i = 0; i < _movieList.length; i++) {
        maps.add(_movieList[i].toMap());
      }
      String data = json.encode(maps);
      _db.setString(CacheKeyModel.myListCachedKey, data);
    });
  }

  bool getAddItem(num postId) {
    final i = _movieList.firstWhereOrNull((e) => e.postId == postId);
    if (i != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

}