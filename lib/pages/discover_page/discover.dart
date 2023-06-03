import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/controllers/genre_controller.dart';
import 'package:vip/models/genre_type.dart';
import 'package:vip/pages/discover_page/tab_bar_view_data.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GenreController>(
      autoRemove: false,
      init: GenreController(),
      builder: (ctrl) => Scaffold(
        backgroundColor: darkLight,
        body: SafeArea(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                backgroundColor: darkLight,
                iconTheme: IconThemeData(color: whiteBlack),
                title: Text(
                  'Discover',
                  style: boldAppbarTextStyle,
                ),
                actions: [
                  PopupMenuButton(
                    color:
                        darkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: Row(
                      children: [
                        Text(
                          '${ctrl.currentType} ',
                          style: TextStyle(
                              fontSize: normalLabelSize, color: whiteBlack),
                        ),
                        RotatedBox(
                          quarterTurns: 5,
                          child: Icon(
                            Icons.play_arrow,
                            color: darkMode ? Colors.white54 : Colors.black45,
                            size: isMobile
                                ? 20.sp
                                : isTablet
                                    ? 10.sp
                                    : 7.sp,
                          ),
                        ),
                      ],
                    ),
                    onSelected: (value) {
                      if (value != ctrl.currentType) {
                        ctrl.getGenreList(value.toString());
                      }
                    },
                    itemBuilder: (context) => List.generate(
                      ctrl.types.length,
                      (index) => PopupMenuItem(
                        value: ctrl.types[index],
                        child: Text(
                          ctrl.types[index],
                          style: TextStyle(
                              fontSize: normalLabelSize, color: whiteBlack),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.sp),
                ],
              ),
            ],
            body: ctrl.genreList.isNotEmpty
                ? (isMobile || isTablet)
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ctrl.genreList.length,
                        padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8.sp : 2.sp),
                        itemBuilder: (context, index) {
                          return buildItemView(
                            ctrl.genreList[index],
                            () {
                              Navigator.of(context).push(
                                MyPageRoute(
                                  builder: (_) => TabBarViewData(
                                    initialIndex: index,
                                    tabsData: List.generate(
                                      ctrl.genreList.length,
                                      (dex) => {
                                        "label": ctrl.genreList[dex].name,
                                        "link": ctrl.genreList[dex].link
                                            .split('v1/')
                                            .last,
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : GridView.builder(
                        itemCount: ctrl.genreList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 2.sp),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 34.sp,
                        ),
                        itemBuilder: (context, index) {
                          return buildItemView(
                            ctrl.genreList[index],
                            () {
                              Navigator.of(context).push(
                                MyPageRoute(
                                  builder: (_) => TabBarViewData(
                                    initialIndex: index,
                                    tabsData: List.generate(
                                      ctrl.genreList.length,
                                      (dex) => {
                                        "label": ctrl.genreList[dex].name,
                                        "link": ctrl.genreList[dex].link
                                            .split('v1/')
                                            .last,
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                : const Center(child: CircularProgressIndicator(color: Colors.green)),
          ),
        ),
      ),
    );
  }

  Widget buildItemView(GenreTypeModel model, void Function() onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: isMobile
                  ? 62.sp
                  : isTablet
                      ? 40.sp
                      : 28.sp,
              width: isMobile
                  ? 110.sp
                  : isTablet
                      ? 65.sp
                      : 48.sp,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                model.name.length > 4 ? model.name.substring(0, 4) : model.name,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: isMobile
                      ? 24.sp
                      : isMobile
                          ? 14.sp
                          : 10.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12.sp : 8.sp),
            SizedBox(
              width: isDesktop ? width / 3.6 : width / 1.8,
              child: Text(
                model.name,
                maxLines: 1,
                style: GoogleFonts.lato(
                  color: whiteBlack,
                  fontSize: isMobile
                      ? 18.sp
                      : isTablet
                          ? 12.sp
                          : 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
