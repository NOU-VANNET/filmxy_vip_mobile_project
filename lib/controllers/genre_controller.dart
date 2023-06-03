import 'package:get/get.dart';
import 'package:vip/models/genre_type.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/urls.dart';

class GenreController extends GetxController {

  List<GenreTypeModel> _genreList = [];
  List<GenreTypeModel> get genreList => _genreList;

  final List<String> types = ['Genre', 'Country', 'Year'];

  String currentType = 'Genre';

  Future getGenreList([String? type]) async {
    _genreList.clear();
    update();
    currentType = type ?? types[0];
    _genreList = await Services().getGenreType(Urls.apiDomain(route: "terms/${currentType.toLowerCase()}"));
    if (currentType == types[2]) {
      _genreList = _genreList.reversed.toList();
    }
    update();
  }

  @override
  void onInit() {
    getGenreList();
    super.onInit();
  }

}