import 'package:get/get.dart';

class ShimmerController extends GetxController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void init() {
    _isLoading = !_isLoading;
    update();
    Future.delayed(const Duration(milliseconds: 500), ()=> init());
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

}