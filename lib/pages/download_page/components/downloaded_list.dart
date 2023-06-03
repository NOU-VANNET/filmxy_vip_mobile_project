import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/pages/player_page/player_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class DownloadedList extends StatelessWidget {
  final List<Map> dlList;
  const DownloadedList({
    Key? key,
    required this.dlList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return dlList.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Downloaded: ${dlList.length}',
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        color: whiteBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: dlList.length,
                shrinkWrap: true,
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 5.sp),
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
                  child: _DownloadedItemView(
                    map: dlList[index],
                    index: index,
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}

class _DownloadedItemView extends StatelessWidget {
  final Map map;
  final int index;
  const _DownloadedItemView({
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
            child: CachedNetworkImage(
              imageUrl: '',
              cacheKey: "${_imageCachedId}poster",
              height: 100.h,
              width: 72.w,
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
                value: 'play',
                child: Row(
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Play',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Delete',
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
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => _DeleteDownloadedDialog(
                    index: index,
                    map: map,
                    filename: _filename,
                  ),
                );
              } else if (value == 'play') {
                Navigator.of(context).push(
                  MyPageRoute(
                    builder: (builder) => PlayerPage(
                      file: FileLink(),
                      subUrl: "",
                      type: "",
                      offlineVideoPath: map['savedDirectory'] + map['filename'],
                      offline: true,
                      ytCtrl: null,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
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

class _DeleteDownloadedDialog extends StatefulWidget {
  final int index;
  final Map map;
  final String filename;
  const _DeleteDownloadedDialog({
    Key? key,
    required this.index,
    required this.map,
    required this.filename,
  }) : super(key: key);

  @override
  State<_DeleteDownloadedDialog> createState() =>
      _DeleteDownloadedDialogState();
}

class _DeleteDownloadedDialogState extends State<_DeleteDownloadedDialog> {

  bool _val = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
      title: Text(
        "Delete ${widget.filename}",
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Row(
        children: [
          Checkbox(
            value: _val,
            onChanged: (val) => setState(() => _val = !_val),
          ),
          Text(
            "Also delete in phone storage.",
            style: TextStyle(fontSize: 14.sp, color: Colors.black),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "CANCEL",
            style: TextStyle(fontSize: 14.sp, color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.put(DownloadController()).removeItem(widget.index, widget.map['id'], _val);
            Navigator.of(context).pop();
          },
          child: Text(
            "DELETE",
            style: TextStyle(fontSize: 14.sp, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
