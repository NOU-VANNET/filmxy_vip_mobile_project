import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/pages/player_page/player_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadingList extends StatelessWidget {
  final List<Map> dlList;
  final bool isExpand;
  const DownloadingList({
    Key? key,
    required this.dlList,
    required this.isExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return dlList.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading Task:  ${dlList.length}',
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        color: whiteBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.put(DownloadController()).expandCollapse(),
                      child: Text(
                        isExpand ? 'Hide' : 'Show',
                        style: TextStyle(
                          color: whiteBlack,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: isExpand
                    ? ListView.builder(
                        itemCount: dlList.length,
                        shrinkWrap: true,
                        reverse: true,
                        padding: EdgeInsets.only(left: 5.sp, right: 5.sp, bottom: 22.sp),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context, rootNavigator: true).push(
                              MyPageRoute(
                                builder: (builder) => PlayerPage(
                                  file: FileLink(),
                                  subUrl: "",
                                  type: "",
                                  offlineVideoPath: dlList[index]['savedDirectory'] + dlList[index]['filename'],
                                  offline: true,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                          ),
                          child: _DownloadingItemView(
                            map: dlList[index],
                            index: index,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          )
        : const SizedBox();
  }
}

class _DownloadingItemView extends StatelessWidget {
  final Map map;
  final int index;
  const _DownloadingItemView({
    Key? key,
    required this.map,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: SizedBox(
              height: 100.h,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: '',
                    cacheKey: "${_imageCachedId}poster",
                    width: 72.w,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    top: 0,
                    child: Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: CircularPercentIndicator(
                        radius: 26.r,
                        lineWidth: 4.sp,
                        percent: _progressValue,
                        backgroundColor: Colors.grey.shade100,
                        center: map['status'] == DownloadTaskStatus.paused
                            ? Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 24.sp,
                              )
                            : Text(
                                '$_progressPercent%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                        progressColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: width - 170.w,
                  child: Text(
                    _filename,
                    maxLines: 3,
                    style: GoogleFonts.lato(
                      fontSize: 15.sp,
                      color: whiteBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _status,
                  maxLines: 1,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    color: whiteBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          const Spacer(),
          PopupMenuButton(
            tooltip: "Options",
            icon: Icon(
              Icons.more_vert,
              color: whiteBlack,
              size: 22.sp,
            ),
            color: Colors.grey.shade800,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pr',
                child: Row(
                  children: [
                    Icon(
                      _iconStatus,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _textStatus,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              final _getDLController = Get.put(DownloadController());
              if (value == 'cancel') {
                await _getDLController.removeItem(index, map['id'], true);
              } else if (value == 'pr') {
                await _getDLController.pauseResumeRetryItem(
                  map['id'],
                  map['status'],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String get _textStatus {
    if (map['status'] == DownloadTaskStatus.running) {
      return 'Pause';
    } else if (map['status'] == DownloadTaskStatus.paused) {
      return 'Resume';
    } else {
      return 'Retry';
    }
  }

  IconData get _iconStatus {
    if (map['status'] == DownloadTaskStatus.running) {
      return Icons.pause;
    } else if (map['status'] == DownloadTaskStatus.paused) {
      return Icons.play_arrow_rounded;
    } else if (map['status'] == DownloadTaskStatus.failed) {
      return Icons.replay;
    } else {
      return Icons.more_horiz;
    }
  }

  double get _progressValue {
    String _a = map['progress'].toString();
    final _b = _a.replaceAll('-', '');
    final _c = int.parse(_b);
    String _s = _c == 100
        ? '1.0'
        : _c <= 9
            ? '0.0$_c'
            : _c > 9
                ? '0.$_c'
                : _c <= 0
                    ? '0.00'
                    : '0.$_c';
    double _progress = double.parse(_s);
    return _progress;
  }

  String get _progressPercent {
    final _a = map['progress'].toString();
    final _b = _a.replaceAll('-', '');
    return _b;
  }

  String get _status {
    if (map['status'] == DownloadTaskStatus.running) {
      return 'Downloading...';
    } else if (map['status'] == DownloadTaskStatus.paused) {
      return 'Paused';
    } else if (map['status'] == DownloadTaskStatus.failed) {
      return 'Download failed';
    } else if (map['status'] == DownloadTaskStatus.canceled) {
      return 'Download canceled';
    } else if (map['status'] == DownloadTaskStatus.complete) {
      return 'Download complete';
    } else {
      return 'Download pending';
    }
  }

  String get _filename {
    final _a = map['filename'].toString();
    final _b = _a.split('.MP4').first;
    final _c = _b.split('. ').last;
    return _c;
  }

  String get _imageCachedId {
    final _a = map['filename'].toString();
    final _b = _a.split('.').first;
    return _b;
  }
}
