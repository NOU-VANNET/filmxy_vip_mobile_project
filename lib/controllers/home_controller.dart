import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vip/controllers/my_list_controller.dart';
import 'package:vip/controllers/played_episode_controller.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/urls.dart';

class HomeController extends GetxController {

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  final List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> get data => _data;

  Future initialize({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
      update();
    }

    for (var i = 0; i < Urls.labelMaps.length; i++) {
      Map temp = Urls.labelMaps[i];
      List<MovieModel> result = await Services().getMoviesTypeList(Urls.apiDomain(route: "${temp["type"]}"));
      _data.add({"label": "${temp["label"]}", "data": result});
      _isLoading = false;
      update();
    }

    update();
  }

  Future checkPermission() async {
    final permission = await Permission.storage.status;
    if (!permission.isGranted) Permission.storage.request();
  }

  @override
  void onInit() async {
    initialize();
    Get.put(MyListController()).initialize();
    Get.put(PlayedEpisodeController()).init();
    checkPermission();
    super.onInit();
  }
}
