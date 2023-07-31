import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/detail_page/components/episodes.dart';
import 'package:vip/pages/player_page/player_page.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/size.dart';
import 'package:video_player/video_player.dart';

class SelectServerWidget extends StatelessWidget {
  final List<FileLink> files;
  final List<String> servers;
  final String subUrl;
  final String type;
  final String postTitle;
  final bool download;
  final void Function()? onDownloadStart;
  final num postId;
  final VideoPlayerController? ytCtrl;
  final BuildContext ctx;
  SelectServerWidget(
      {Key? key,
      required this.files,
      required this.servers,
      required this.subUrl,
      required this.type,
      required this.postTitle,
      required this.postId,
      required this.ctx,
      this.onDownloadStart,
      this.download = false,
      this.ytCtrl})
      : super(key: key);

  final List<String> _resolution = [
    "4k",
    "1080p",
    "720p",
    "480p",
  ];

  @override
  Widget build(BuildContext context) {
    return buildBottomView(
      "Select Servers:",
      servers,
      (index) {
        final _files = files.where((e) => e.server.toLowerCase() == servers[index].toLowerCase()).toList();
        final _res = findResolution(_files);
        Get.back();
        Get.bottomSheet(buildBottomView(
          "Select Resolutions:",
          _res,
          (index) async {
            final _file = _files.where((e) => e.resolution.toLowerCase() == _res[index].toLowerCase()).toList();
            if (download) {
              Get.back();
              await Future.delayed(const Duration(milliseconds: 200));
              Get.dialog(
                barrierColor: Colors.black87,
                transitionDuration: const Duration(milliseconds: 200),
                loadingDialog(),
              );
              await Services().download(
                linkId: _file.first.linkId,
                filename: postTitle,
                postId: postId,
              );
              Get.back();
              await Future.delayed(const Duration(milliseconds: 200));
              await Get.put(DownloadController()).loadTask();
              if (onDownloadStart != null) onDownloadStart!();
            } else {
              Navigator.of(ctx).push(
                MyPageRoute(
                  builder: (_) => PlayerPage(
                    file: _file.first,
                    subUrl: subUrl,
                    type: type,
                    ytCtrl: ytCtrl,
                  ),
                ),
              );
            }
          },
        ));
      },
    );
  }

  Widget buildBottomView(
      String label, List<String> type, void Function(int) onItemTap) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(4), topLeft: Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: isMobile
                    ? 16.sp
                    : isTablet
                        ? 10.sp
                        : 8.sp,
                fontWeight: FontWeight.w600),
          ),
          ListView.builder(
            itemCount: type.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 6.h, bottom: 12.h),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => onItemTap(index),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  type[index].toUpperCase(),
                  style: TextStyle(
                      fontSize: isMobile
                          ? 16.sp
                          : isTablet
                              ? 10.sp
                              : 8.sp,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> findResolution(List<FileLink> files) {
    List<String> _r = [];
    for (int i = 0; i < _resolution.length; i++) {
      final _re = files
          .where(
              (e) => e.resolution.toLowerCase() == _resolution[i].toLowerCase())
          .toList();
      if (_re.isNotEmpty) {
        _r.add(_resolution[i]);
      }
    }
    return _r;
  }
}
