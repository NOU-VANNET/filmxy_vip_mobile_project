import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/discover_page/tab_bar_view_data.dart';
import 'package:vip/pages/my_list_page/my_list_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
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
            ? 20.sp
            : isTablet
                ? 15.sp
                : 10.sp,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.sp : 8.sp),
          shrinkWrap: true,
          children: List.generate(
            _keys.length,
            (index) => buildButton(context, label: _keys[index], index: index),
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
      child: Padding(
        padding: EdgeInsets.only(right: isMobile ? 24.sp : 14.sp),
        child: Hero(
          tag: label,
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
