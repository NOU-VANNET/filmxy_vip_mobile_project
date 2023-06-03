import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/controllers/player_controller.dart';
import 'package:vip/models/subtitle_model.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/utils/utils.dart';

class SubtitlesWidget extends StatelessWidget {
  final List<SubtitleModel> subtitles;
  final PlayerController controller;
  const SubtitlesWidget({Key? key, required this.subtitles, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: darkLight,
        constraints: BoxConstraints(
          maxHeight: height - (isMobile ? 60 : 40.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Subtitles",
                    style: GoogleFonts.lato(
                        color: whiteBlack,
                        fontSize: isMobile ? 18 : 7.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 32,
                    child: controller.currentL.isNotEmpty ? TextButton(
                      onPressed: () {
                        controller.disableSubtitle();
                        Get.back();
                      },
                      child: const Text(
                        "Disable",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ) : const SizedBox(),
                  ),
                ],
              ),
            ),
            Divider(height: 0, color: darkMode ? Colors.white54 : Colors.black54),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: subtitles.length,
                padding: EdgeInsets.only(bottom: isMobile ? 24 : 4.sp, top: isMobile ? 12 : 4.sp, left: 18, right: 18),
                itemBuilder: (context, index) => ElevatedButton(
                  onPressed: () {
                    controller.loadSubtitle(subtitles[index].k, subtitles[index].l);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0, backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Row(
                    children: [
                      controller.currentL == subtitles[index].l ? Icon(Icons.done, color: whiteBlack) : const SizedBox(),
                      const SizedBox(width: 6),
                      Text(
                        Utils().getCountry(subtitles[index].l)['language']['name'].toString(),
                        style: TextStyle(fontSize: isMobile ? 17 : 7.sp, color: whiteBlack),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
