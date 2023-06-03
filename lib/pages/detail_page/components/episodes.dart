import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/controllers/played_episode_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/detail_page/detail_page.dart';
import 'package:vip/pages/download_page/download.dart';
import 'package:vip/pages/player_page/player_page.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/utils/utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class EpisodesWidget extends StatefulWidget {
  final List<FileLink> files;
  final String banner;
  final String subUrl;
  final String type;
  final num postId;
  final String status;
  final String detailLink;
  final String postTitle;
  final PodPlayerController? ytCtrl;
  final DownloadController dlCtrl;
  const EpisodesWidget({
    Key? key,
    required this.files,
    required this.banner,
    required this.subUrl,
    required this.type,
    required this.postId,
    required this.status,
    required this.postTitle,
    required this.detailLink,
    required this.dlCtrl,
    this.ytCtrl,
  }) : super(key: key);

  @override
  State<EpisodesWidget> createState() => _EpisodesWidgetState();
}

class _EpisodesWidgetState extends State<EpisodesWidget>
    with AutomaticKeepAliveClientMixin {
  List<FileLink> _episodes = [];

  final List<int> _seasons = [];

  int _currentSeason = 1;

  String _currentQuality = "";

  String _currentServer = "";

  String _currentResolution = "";

  bool reloadingEpisode = false;

  AutoScrollController? controller;

  List<String> get _quality => [
        "HD/BluRay",
        "HD/Web-DL",
      ];

  List<String> get _language => [
        "en",
        "ja",
      ];

  List<String> get _resolutions => [
        "720p",
        "360p",
        "480p",
        "1080p",
      ];

  List<String> get _servers => [
        "alpha",
        "beta",
        "premium",
      ];

  void getSeason({List<FileLink>? files}) {
    _seasons.clear();
    if (files != null) {
      for (int i = 1; i < 20; i++) {
        String ss = (i <= 9) ? "s0$i" : "s$i";
        final seasonFiles = files.getTypeContainValue("key", ss);
        if (seasonFiles.isNotEmpty) {
          _seasons.add(i);
          if (mounted) setState(() {});
        }
      }
    } else {
      for (int i = 1; i < 20; i++) {
        String ss = (i <= 9) ? "s0$i" : "s$i";
        final seasonFiles = widget.files.getTypeContainValue("key", ss);
        if (seasonFiles.isNotEmpty) {
          _seasons.add(i);
          if (mounted) setState(() {});
        }
      }
    }
  }

  void getEpisodes(int s, {bool filter = false, List<FileLink>? files}) {
    _episodes.clear();
    List<FileLink> seasonFiles() {
      String ss = s <= 9 ? "s0$s" : "s$s";

      if (files != null) {
        final ls1 = files.getTypeContainValue('key', ss);
        return ls1;
      } else {
        final ls2 = widget.files.getTypeContainValue("key", ss);
        return ls2;
      }
    }

    if (filter) {
      final serverFiles = seasonFiles().getType("server", _currentServer);
      if (serverFiles.isNotEmpty) {
        final qualityFiles = serverFiles.getType("quality", _currentQuality);
        if (qualityFiles.isNotEmpty) {
          final resolutionFiles = qualityFiles.getType("resolution", _currentResolution);
          setState(() {
            _episodes = resolutionFiles;
          });
        }
      }
    } else {
      if (seasonFiles().isNotEmpty) {
        for (int i = 0; i < _servers.length; i++) {
          final serverFiles = seasonFiles().getType("server", _servers[i]);
          if (serverFiles.isNotEmpty) {
            _currentServer = _servers[i];
            for (int x = 0; x < _quality.length; x++) {
              final qualityFiles = serverFiles.getType("quality", _quality[x]);
              if (qualityFiles.isNotEmpty) {
                _currentQuality = _quality[x];
                for (int z = 0; z < _resolutions.length; z++) {
                  final resolutionFiles = serverFiles.getType("resolution", _resolutions[z]);
                  if (resolutionFiles.isNotEmpty) {
                    _currentResolution = _resolutions[z];
                    for (int zz = 0; zz < _language.length; zz++) {
                      final languageFiles = resolutionFiles.getType("lang", _language[zz]);
                      if (languageFiles.isNotEmpty) {
                        if (mounted) {
                          setState(() {
                            _currentSeason = s;
                            _episodes = languageFiles;
                          });
                        }
                        break;
                      }
                    }
                    break;
                  }
                }
                break;
              }
            }
            break;
          }
        }
      }
    }

    if (mounted) {
      controller = AutoScrollController(axis: Axis.vertical);
      scrollToIndex();
    }
  }

  Future reloadNewEpisodesFromServerToCache() async {
    reloadingEpisode = true;
    final detail = await Services().getDetailModel(widget.detailLink);
    getSeason(files: detail.fileLink);
    final key = Get.put(PlayedEpisodeController()).key(widget.postId);
    final ss = key != null ? key.split('e').first.split('s').last : '1';
    getEpisodes(int.parse(ss), files: detail.fileLink);
    reloadingEpisode = false;
    if (mounted) setState(() {});
    detailList[detailList.indexWhere((e) => e.postId == widget.postId)]
        .fileLink = detail.fileLink;
    await Future.delayed(const Duration(milliseconds: 200));
    Services().setDetailCache(detailList);
  }

  @override
  void initState() {
    getSeason();

    final key = Get.put(PlayedEpisodeController()).key(widget.postId);
    final ss = key != null ? key.split('e').first.split('s').last : '1';

    getEpisodes(int.parse(ss));
    if (widget.status.toLowerCase() == "ongoing") {
      reloadNewEpisodesFromServerToCache();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final s = size;

    return SizedBox(
      width: s.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12.w : 7.w,
                vertical: isMobile ? 8.sp : 5.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: isDesktop ? 42.h : 32.h,
                  width: isMobile
                      ? 118.w
                      : isTablet
                          ? 70.w
                          : 55.w,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_seasons.length > 1) {
                        Get.bottomSheet(bottomSheetSeason,
                            isScrollControlled: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _seasons.length == 1
                          ? Colors.transparent
                          : Colors.grey.shade800,
                      elevation: _seasons.length == 1 ? 0 : 6,
                      alignment: Alignment.center,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Season $_currentSeason",
                          style: TextStyle(
                            color: _seasons.length == 1
                                ? whiteBlack
                                : Colors.white,
                            fontSize: isMobile
                                ? 14.sp
                                : isTablet
                                    ? 9.sp
                                    : 7.sp,
                          ),
                        ),
                        _seasons.length > 1
                            ? RotatedBox(
                                quarterTurns: 5,
                                child: Icon(
                                  Icons.play_arrow,
                                  size: isMobile
                                      ? 18.sp
                                      : isTablet
                                          ? 12.sp
                                          : 8.sp,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.sp),
                reloadingEpisode
                    ? SizedBox(
                        height: isMobile ? 20.sp : 12.sp,
                        width: isMobile ? 20.sp : 12.sp,
                        child: const CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const SizedBox(),
                const Spacer(),
                SizedBox(
                  height: isDesktop ? 42.h : 32.h,
                  width: isMobile
                      ? 90.w
                      : isTablet
                          ? 50.w
                          : 40.w,
                  child: ElevatedButton(
                    onPressed: () => Get.bottomSheet(bottomSheetFilter),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      alignment: Alignment.center,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter",
                          style: TextStyle(
                              fontSize: isMobile
                                  ? 14.sp
                                  : isTablet
                                      ? 9.sp
                                      : 7.sp,
                              color: whiteBlack),
                        ),
                        RotatedBox(
                          quarterTurns: 5,
                          child: Icon(
                            Icons.play_arrow,
                            size: isMobile
                                ? 18.sp
                                : isTablet
                                    ? 12.sp
                                    : 8.sp,
                            color: whiteBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          GetBuilder<PlayedEpisodeController>(
            autoRemove: false,
            builder: (c) {
              return Expanded(
                child: isMobile
                    ? ListView.builder(
                        itemCount: _episodes.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        controller: controller,
                        itemBuilder: (context, index) {
                          bool isMatched =
                              c.played(_episodes[index], widget.postId);
                          return buildEpisodeItemView(
                            _episodes[index],
                            index,
                            widget.postId,
                            isMatched,
                            widget.dlCtrl.downloadListMaps,
                          );
                        },
                      )
                    : GridView.builder(
                        itemCount: _episodes.length,
                        shrinkWrap: true,
                        controller: controller,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 2 : 3,
                          mainAxisExtent: isTablet ? 45.sp : 32.sp,
                        ),
                        itemBuilder: (context, index) {
                          bool isMatched =
                              c.played(_episodes[index], widget.postId);
                          return buildEpisodeItemView(
                            _episodes[index],
                            index,
                            widget.postId,
                            isMatched,
                            widget.dlCtrl.downloadListMaps,
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget get bottomSheetFilter => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.r),
            topRight: Radius.circular(4.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildFilterButton(
              "Server",
              _currentServer.toUpperCase(),
            ),
            buildFilterButton(
              "Quality",
              _currentQuality.toUpperCase(),
            ),
            buildFilterButton(
              "Resolution",
              _currentResolution.toUpperCase(),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      );

  Widget buildFilterListView(String type, List<dynamic> items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.r),
          topRight: Radius.circular(4.r),
        ),
      ),
      child: ListView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        itemBuilder: (context, index) => SizedBox(
          width: width,
          height: 46.h,
          child: ElevatedButton(
            onPressed: () {
              if (type == "server") {
                _currentServer = items[index].toString().toLowerCase();
              } else if (type == "resolution") {
                _currentResolution = items[index].toString().toLowerCase();
              }
              Get.back();
              getEpisodes(_currentSeason, filter: true);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              items[index].toString().toUpperCase(),
              style: TextStyle(
                fontSize: isMobile
                    ? 16.sp
                    : isTablet
                        ? 10.sp
                        : 8.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get bottomSheetSeason => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.r),
            topRight: Radius.circular(4.r),
          ),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _seasons.length,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 12.h),
          itemBuilder: (context, index) => SizedBox(
            height: isMobile
                ? 44.h
                : isTablet
                    ? 22.sp
                    : 16.sp,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                getEpisodes(index + 1);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                "Season ${_seasons[index]}",
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
      );

  Widget buildFilterButton(String label, String currentType) {
    return SizedBox(
      width: width,
      height: isMobile
          ? 50.h
          : isTablet
              ? 30.sp
              : 25.sp,
      child: ElevatedButton(
        onPressed: () {
          Get.back();
          if (label.toLowerCase() == "server") {
            Get.bottomSheet(buildFilterListView("server", _servers));
          } else if (label.toLowerCase() == "quality") {
            Get.bottomSheet(buildFilterListView("quality", _quality));
          } else if (label.toLowerCase() == "resolution") {
            Get.bottomSheet(buildFilterListView("resolution", _resolutions));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: isMobile
                      ? 12.sp
                      : isTablet
                          ? 9.sp
                          : 7.sp,
                  color: Colors.white70),
            ),
            Text(
              currentType,
              style: TextStyle(
                  fontSize: isMobile
                      ? 16.sp
                      : isTablet
                          ? 12.sp
                          : 9.sp,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEpisodeItemView(
    FileLink file,
    int index,
    num postId,
    bool matched,
    List<Map> dlList,
  ) {
    bool isMatched = matchedFromDownload(dlList, file);
    Map map = offlineMap(dlList, file);

    Widget child = SizedBox(
      height: isMobile
          ? 69.sp
          : isTablet
              ? 45.sp
              : 32.sp,
      child: ElevatedButton(
        onPressed: () {
          widget.ytCtrl?.pause();
          Get.put(PlayedEpisodeController()).add(file, postId);
          if (map['status'] == DownloadTaskStatus.running ||
              map['status'] == DownloadTaskStatus.paused ||
              map['status'] == DownloadTaskStatus.complete) {
            if (mounted) offlinePlay(context, map);
          } else {
            if (mounted) play(context, file);
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: matched
              ? Colors.grey.shade800
              : (darkMode ? Colors.transparent : Colors.grey.shade800),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: isMobile ? 12.w : 5.sp),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: CachedNetworkImage(
                imageUrl: index == 0 ? widget.banner : "",
                width: isMobile
                    ? 90.w
                    : isTablet
                        ? 60.sp
                        : 45.sp,
                height: isMobile
                    ? 60.h
                    : isTablet
                        ? 36.sp
                        : 28.sp,
                fit: BoxFit.cover,
                cacheKey: "${postId}banner",
              ),
            ),
            SizedBox(width: isMobile ? 12.w : 5.sp),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.key.toUpperCase(),
                  style: TextStyle(
                      fontSize: isMobile
                          ? 16.sp
                          : isTablet
                              ? 9.sp
                              : 7.sp),
                ),
                Text(
                  "${file.server.toUpperCase()} | ${file.quality}",
                  style: TextStyle(
                      fontSize: isMobile
                          ? 10.sp
                          : isTablet
                              ? 7.sp
                              : 5.sp,
                      color: Colors.white70),
                ),
                Text(
                  "${file.resolution.toUpperCase()} | ${Utils().getCountry(file.lang)['language']['name']}",
                  style: TextStyle(
                      fontSize: isMobile
                          ? 10.sp
                          : isTablet
                              ? 7.sp
                              : 5.sp,
                      color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 65.sp,
              child: TextButton(
                onPressed: () async {
                  if (!isMatched) {
                    download(file, index);
                  } else {
                    if (map['status'] == DownloadTaskStatus.complete) {
                      offlinePlay(context, map);
                    } else {
                      Get.put(DownloadController()).loadTask();
                      Navigator.of(context).push(MyPageRoute(builder: (context)=> const DownloadPage(),),);
                    }
                  }
                },
                child: isMatched
                    ? buttonStatus(context, map)
                    : Icon(
                        Icons.arrow_downward_sharp,
                        color: Colors.grey.withOpacity(0.90),
                      ),
              ),
            ),
            SizedBox(width: 6.sp),
          ],
        ),
      ),
    );

    if (controller != null) {
      return AutoScrollTag(
        index: index,
        controller: controller!,
        key: ValueKey(index),
        child: child,
      );
    } else {
      return child;
    }
  }

  bool matchedFromDownload(List<Map> ls, FileLink file) {
    final name = "${widget.postId}. ${file.key.toUpperCase()} - ${widget.postTitle.replaceAll(":", "")}.MP4";
    if (ls.isNotEmpty) {
      final i = ls.firstWhereOrNull((e) => e['filename'] == name);
      return i != null;
    } else {
      return false;
    }
  }

  Map offlineMap(List<Map> ls, FileLink file) {
    final name = "${widget.postId}. ${file.key.toUpperCase()} - ${widget.postTitle.replaceAll(":", "")}.MP4";
    final i = ls.where((e) => e['filename'] == name);
    if (i.isNotEmpty) {
      return i.first;
    } else {
      return {};
    }
  }

  void offlinePlay(BuildContext context, Map map) {
    String key = map['filename'].toString().split(' - ').first.split('. ').last;
    Navigator.of(context).push(
      MyPageRoute(
        builder: (builder) => PlayerPage(
          file: FileLink(key: key),
          subUrl: widget.subUrl,
          type: widget.type,
          offlineVideoPath: map['savedDirectory'] + map['filename'],
          offline: true,
          onDispose: () => Future.delayed(
              const Duration(milliseconds: 1500), () => scrollToIndex()),
        ),
      ),
    );
  }

  Widget buttonStatus(BuildContext context, Map map) {
    if (map['status'] == DownloadTaskStatus.complete) {
      return Icon(
        Icons.done,
        color: Colors.grey.withOpacity(0.90),
      );
    } else if (map['status'] == DownloadTaskStatus.paused) {
      return Icon(
        Icons.pause,
        color: Colors.grey.withOpacity(0.90),
      );
    } else if (map['status'] == DownloadTaskStatus.running) {
      return Text(
        'View',
        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
      );
    } else {
      return Icon(
        Icons.arrow_downward_sharp,
        color: Colors.grey.withOpacity(0.90),
      );
    }
  }

  void play(BuildContext context, FileLink file) => Navigator.of(context).push(
        MyPageRoute(
          builder: (builder) => PlayerPage(
            file: file,
            subUrl: widget.subUrl,
            type: widget.type,
            offlineVideoPath: "",
            ytCtrl: widget.ytCtrl,
            onDispose: () => Future.delayed(
                const Duration(milliseconds: 1500), () => scrollToIndex()),
          ),
        ),
      );

  Future download(FileLink file, int index) async {
    Get.dialog(
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 200),
      loadingDialog(),
    );
    await Services().download(
      linkId: file.linkId,
      filename: "${file.key.toUpperCase()} - ${widget.postTitle}",
      postId: widget.postId,
    );
    Get.back();
    await Future.delayed(const Duration(milliseconds: 200));
    await widget.dlCtrl.loadTask();
    setState(() {});
  }

  void scrollToIndex() {
    final key = Get.put(PlayedEpisodeController()).key(widget.postId);
    if (key != null) {
      int index = _episodes.indexWhere((e) => e.key.toLowerCase() == key.toLowerCase());
      controller?.scrollToIndex(
        index,
        duration: const Duration(milliseconds: 100),
        preferPosition: AutoScrollPosition.begin,
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}

Widget loadingDialog([String? label]) {
  return AlertDialog(
    backgroundColor: darkLight,
    insetPadding: EdgeInsets.symmetric(horizontal: 12.sp),
    contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 14.sp : 8.sp),
    content: SizedBox(
      height: isMobile ? 60.sp : 44.sp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Center(child: CircularProgressIndicator()),
          SizedBox(width: isMobile ? 12.sp : 7.sp),
          Text(
            label ?? 'Please wait...',
            style: TextStyle(
              color: whiteBlack,
              fontSize: isMobile
                  ? 16.sp
                  : isTablet
                      ? 9.sp
                      : 7.sp,
            ),
          ),
        ],
      ),
    ),
  );

}

extension NAME on String {
  String get typeSeasonName {
    final t = this;
    if (t.contains("ova")) {
      return "Original Video Animation";
    } else if (t.contains("ona")) {
      return "Original Net Animation";
    } else if (t.contains("sp")) {
      return "Spacial";
    } else if (t.contains("m")) {
      return "Movie";
    } else {
      return "Season";
    }
  }

  String get typeSeasonShortName {
    final t = this;
    if (t.contains("ova")) {
      return "Ova";
    } else if (t.contains("ona")) {
      return "Ona";
    } else if (t.contains("sp")) {
      return "Sp";
    } else if (t.contains("m")) {
      return "Movie";
    } else {
      return "Season";
    }
  }
}

extension DATA on List<FileLink> {
  List<FileLink> getType(String type, String value) {
    final ls = this;
    if (type == 'key') {
      return ls
          .where((e) => e.key.toLowerCase() == value.toLowerCase())
          .toList();
    } else if (type == 'server') {
      return ls
          .where((e) => e.server.toLowerCase() == value.toLowerCase())
          .toList();
    } else if (type == 'resolution') {
      return ls
          .where((e) => e.resolution.toLowerCase() == value.toLowerCase())
          .toList();
    } else if (type == 'lang') {
      return ls
          .where((e) => e.lang.toLowerCase() == value.toLowerCase())
          .toList();
    } else if (type == 'quality') {
      return ls
          .where((e) => e.quality.toLowerCase() == value.toLowerCase())
          .toList();
    } else {
      throw Exception('Type is empty!!!!');
    }
  }

  List<FileLink> getTypeContainValue(String type, String value) {
    final ls = this;
    if (type == 'key') {
      return ls
          .where((e) => e.key.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else if (type == 'server') {
      return ls
          .where((e) => e.server.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else if (type == 'resolution') {
      return ls
          .where(
              (e) => e.resolution.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else if (type == 'lang') {
      return ls
          .where((e) => e.lang.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else if (type == 'quality') {
      return ls
          .where((e) => e.quality.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else {
      throw Exception('Type is empty!!!!');
    }
  }
}