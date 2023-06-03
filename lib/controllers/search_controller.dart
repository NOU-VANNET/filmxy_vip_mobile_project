import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/services/services.dart';

class SearchController extends GetxController {


  final txtEditorController = TextEditingController();

  List<MovieModel> _movieList = [];
  List<MovieModel> get movieList => _movieList;

  bool _loading = false;
  bool get loading => _loading;

  String _status = "Type to search\nwhat you want to watch.";
  String get status => _status;

  Future search(String query) async{
    _loading = true;
    update();
    _movieList = await Services().searchMovie(query);
    _loading = false;
    if (_movieList.isEmpty) {
      _status = "No result for \"$query\"";
      update();
    } else {
      for (var i = 0; i < _movieList.length; i++) {
        _movieList.removeWhere((e) => e.isAdult == "1");
      }
      update();
    }
  }

  void clear() {
    txtEditorController.clear();
    _movieList.clear();
    _status = "Type to search\nwhat you want to watch.";
    update();
  }

}