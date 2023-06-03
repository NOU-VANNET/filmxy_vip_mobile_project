import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/my_list_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/search_page/components/item_view.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class MyListPage extends StatefulWidget {
  const MyListPage({Key? key}) : super(key: key);

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyListController>(
      autoRemove: false,
      builder: (c) {
        return Scaffold(
          backgroundColor: darkLight,
          body: SafeArea(
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  backgroundColor: darkLight,
                  iconTheme: IconThemeData(
                    color: whiteBlack,
                  ),
                  title: Text(
                    "Playlist",
                    style: boldAppbarTextStyle,
                  ),
                ),
              ],
              body: c.movieList.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                itemCount: c.movieList.length,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 6.h,
                ),
                itemBuilder: (context, index) =>
                    SearchItemView(movie: c.movieList[index]),
              )
                  : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_add,
                      color: darkMode
                          ? Colors.white54
                          : Colors.black54,
                      size: isMobile ? 56.sp : 24.sp,
                    ),
                    Text(
                      "No added list!",
                      textAlign: TextAlign.center,
                      style: greyedTextStyle,
                    ),
                    SizedBox(height: 200.sp),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
