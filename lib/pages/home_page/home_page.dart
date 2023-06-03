import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/controllers/home_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/controllers/my_list_controller.dart';
import 'package:vip/pages/download_page/download.dart';
import 'package:vip/pages/home_page/components/bottom_appbar.dart';
import 'package:vip/pages/home_page/components/list_view_body.dart';
import 'package:vip/pages/home_page/components/top_slider.dart';
import 'package:vip/pages/my_list_page/my_list_page.dart';
import 'package:vip/pages/search_page/search_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final void Function(bool)? onThemeChanged;
  const HomePage({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  late SharedPreferences _db;

  _init() async {
    _db = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (c) {
        Map<String, dynamic> popular = {};
        List<Map<String, dynamic>> listData = [];

        if (c.data.isNotEmpty) {
          popular =  c.data.sublist(0, 1).first;
          listData = c.data.sublist(1, c.data.length).toList();
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: darkLight,
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: darkLight,
          ),
          body: SafeArea(
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                buildAppBar(context),
              ],
              body: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12.sp : 7.sp),
                child: Column(
                  children: [
                    TopSliderWidget(
                      data: popular,
                      isLoading: c.isLoading,
                    ),
                    ListViewBodyHomeWidget(
                      dataList: listData,
                      isLoading: c.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  SliverAppBar buildAppBar(BuildContext context) {
    return SliverAppBar(
      titleSpacing: isMobile ? 8.w : 4.w,
      toolbarHeight: isMobile
          ? 42.sp
          : isTablet
              ? 24.sp
              : 12.sp,
      floating: true,
      backgroundColor: darkLight,
      title: Padding(
        padding: EdgeInsets.only(left: 8.sp),
        child: Image.asset(
          "assets/icons/v.png",
          fit: BoxFit.fitHeight,
          height: 50.sp,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(isMobile
            ? 42.sp
            : isTablet
                ? 16.sp
                : 10.sp),
        child: BottomAppBarHome(),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MyPageRoute(
              builder: (context) => const SearchPage(),
            ),
          ),
          icon: Icon(CupertinoIcons.search, size: normalIconSize),
          tooltip: "Search",
          splashRadius: normalIconSize,
          color: whiteBlack,
        ),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: () {
            setState(() => darkMode = !darkMode);
            changeStatusBar();
          },
          icon: Icon(
              darkMode
                  ? CupertinoIcons.moon_stars_fill
                  : CupertinoIcons.sun_max_fill,
              size: normalIconSize),
          tooltip: "Theme Mode",
          splashRadius: normalIconSize,
          color: whiteBlack,
        ),
        SizedBox(width: 5.w),
      ],
    );
  }

  Future changeStatusBar() async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: darkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness:
            darkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            darkMode ? Colors.grey.shade900 : Colors.grey.shade200,
      ),
    );
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(darkMode);
    }
    _db.setBool('dark_mode', darkMode);
  }

  @override
  bool get wantKeepAlive => true;
}
