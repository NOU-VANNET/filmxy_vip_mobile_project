import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/pages/discover_page/tab_bar_view_data.dart';
import 'package:vip/pages/my_list_page/my_list_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class BottomAppBarHome extends StatelessWidget {
  BottomAppBarHome({Key? key}) : super(key: key);

  final List<String> _keys = [
    "Movies",
    "TV Series",
    "Anime",
    "Playlist",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 8.h : 2.h),
      child: SizedBox(
        height: isMobile
            ? 32.sp
            : isTablet
                ? 15.sp
                : 10.sp,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              _keys.length,
              (index) =>
                  buildButton(context, label: _keys[index], index: index),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton(
    BuildContext context, {
    String label = "",
    int index = 0,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (label == 'Playlist') {
          Navigator.of(context).push(
            MyPageRoute(
              builder: (context) => const MyListPage(),
            ),
          );
        } else {
          Navigator.of(context).push(
            MyPageRoute(
              builder: (context) => TabBarViewData(
                showFilterOptions: true,
                tabsData: List.generate(
                  _keys.length - 1,
                  (dex) => {
                    "label": _keys[dex],
                    "link": typeLink(_keys[dex]),
                  },
                ),
                initialIndex: index,
              ),
            ),
          );
        }
      },
      child: Hero(
        tag: label,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 4.sp),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: darkMode ? Colors.grey[800] : Colors.grey[300],
          ),
          child: Text(
            label,
            style: normalLabelStyle,
          ),
        ),
      ),
    );
  }

  String typeLink(String t) {
    if (t == 'Movies') {
      return 'movies';
    } else if (t == 'TV Series') {
      return 'tv';
    } else {
      return 'anime';
    }
  }
}
