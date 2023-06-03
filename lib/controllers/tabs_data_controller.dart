import 'package:get/get.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/services/services.dart';

class TabsDataController extends GetxController {

  String? _currentLabel;

  int _currentPage = 1;

  String _link = "";
  String? _filterType;

  bool _isEmptyList = false;
  bool get isEmptyList => _isEmptyList;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  final List<MovieModel> _data = [];
  List<MovieModel> get data => _data;

  Future initTab(String label, String link, [String? filterType]) async {
    _isEmptyList = false;
    update();
    if (_filterType != null) {
      if (_filterType != filterType) {
        _filterType = filterType;
      }
    } else {
      _filterType = filterType;
    }
    if (_currentLabel == null) {
      _currentLabel = label;
      _currentPage = 1;
      _link = link;
      _getData();
    } else {
      if (_currentLabel != label) {
        _data.clear();
        update();
        _currentLabel = label;
        _currentPage = 1;
        _link = link;
        _getData();
      }
    }
  }

  Future nextPage() async {
    _isLoadingMore = true;
    update();
    _currentPage += 1;
    await _getData();
    _isLoadingMore = false;
    update();
  }

  Future _getData() async {
    final ls = await Services().fetchData(_link, page: _currentPage, filterType: _filterType);
    if (ls.isNotEmpty) {
      _data.addAll(ls);
    } else {
      _isEmptyList = true;
    }
    update();
    return;
  }

}