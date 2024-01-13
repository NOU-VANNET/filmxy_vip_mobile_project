import 'dart:convert';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/controllers/my_list_controller.dart';
import 'package:vip/controllers/played_episode_controller.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/extensions.dart';
import 'package:vip/utils/urls.dart';

class HomeController extends GetxController {
  static const String _cachedKey = "movies_list_xxx";

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> get data => _data;

  Future _getCache() async {
    final db = await SharedPreferences.getInstance();
    final source = db.getStringList(_cachedKey);
    if (source != null) {
      _data = List<Map<String, dynamic>>.from(source.map((e) {
        var map = json.decode(e);
        var movies = List<MovieModel>.from(
            map['data'].map((x) => MovieModel.fromMap(x)));
        return {
          'label': map['label'],
          'data': movies,
        };
      }));
      _isLoading = false;
      update();
    }
  }

  Future initialize({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
      update();
    }

    for (var i = 0; i < Urls.labelMaps.length; i++) {
      Map temp = Urls.labelMaps[i];
      List<MovieModel> result = await Services().getMoviesTypeList(Urls.apiDomain(route: "${temp["type"]}"));
      if (!_data.isExist((e) => e['label'] == temp['label'])) {
        _data.add({"label": "${temp["label"]}", "data": result});
      } else {
        _data[_data.indexWhere((e) => e['label'] == temp['label'])]['data'] = result;
      }
      _isLoading = false;
      update();
    }

    update();
    final db = await SharedPreferences.getInstance();
    db.setStringList(_cachedKey, List<String>.from(_data.map((e) {
      var movies = List<dynamic>.from(e['data'].map((x) {
        var el = x as MovieModel;
        return el.toMap();
      }));
      return json.encode({
        'label': e['label'],
        'data': movies,
      });
    })));
  }

  Future checkPermission() async {
    final permission = await Permission.storage.status;
    if (!permission.isGranted) Permission.storage.request();
  }

  @override
  void onInit() async {
    _getCache().then((_) => initialize());
    Get.put(MyListController()).initialize();
    Get.put(PlayedEpisodeController()).init();
    checkPermission();
    super.onInit();
  }
}
