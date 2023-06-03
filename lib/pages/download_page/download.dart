import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/pages/download_page/components/downloaded_list.dart';
import 'package:vip/pages/download_page/components/downloading_list.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({
    Key? key,
  }) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloadController>(
      autoRemove: false,
      init: DownloadController(),
      builder: (dl) {
        return Scaffold(
          backgroundColor: darkLight,
          body: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: Colors.transparent,
              ),
            ),
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  backgroundColor: darkLight,
                  iconTheme: IconThemeData(color: whiteBlack),
                  title: Text(
                    'Downloads',
                    style: GoogleFonts.lato(
                      fontSize: 18.sp,
                      color: whiteBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  toolbarHeight: 50.sp,
                  actions: [
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: darkLight,
                          content: Text(
                            'Downloaded videos are saved in the Downloads folder.',
                            style: normalLabelStyle,
                          ),
                        ),
                      ),
                      child: Text('?', style: normalLabelStyle),
                    ),
                  ],
                ),
              ],
              body: dl.downloadListMaps.isNotEmpty
                  ? SingleChildScrollView(
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: width),
                            DownloadingList(
                              dlList: dl.downloadingList,
                              isExpand: dl.isExpand,
                            ),
                            DownloadedList(dlList: dl.downloadedList),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 120.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.tray,
                              color: whiteBlack,
                              size: 34.sp,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Downloaded\nvideo will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: whiteBlack,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
