import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/controllers/my_list_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/pages/detail_page/components/cast_crew.dart';
import 'package:vip/pages/detail_page/components/episodes.dart';
import 'package:vip/pages/detail_page/components/select_server.dart';
import 'package:vip/pages/download_page/download.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/widgets/countdown_episode.dart';
import 'package:vip/widgets/horizontal_list_widget.dart';
import 'package:pod_player/pod_player.dart';
import 'package:readmore/readmore.dart';

class DetailBody extends StatefulWidget {
  final DetailModel detail;
  final MovieModel movie;
  final PodPlayerController? ytCtrl;
  final DownloadController dlCtrl;
  const DetailBody({
    Key? key,
    required this.detail,
    this.ytCtrl,
    required this.movie,
    required this.dlCtrl,
  }) : super(key: key);

  @override
  State<DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  final _scrollerBody = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Tab> tabs = [
      if (widget.detail.type != "Movie") const Tab(text: 'Episodes'),
      if (widget.detail.castCrew.isNotEmpty) const Tab(text: 'Cast & Crew'),
      const Tab(text: 'You May Like'),
      const Tab(text: 'Trending'),
    ];

    int tabLength() {
      if (widget.detail.type == 'Movie') {
        if (widget.detail.castCrew.isNotEmpty) {
          return 3;
        } else {
          return 2;
        }
      } else {
        if (widget.detail.castCrew.isNotEmpty) {
          return 4;
        } else {
          return 3;
        }
      }
    }

    double textSize = isMobile
        ? 15.sp
        : isTablet
            ? 9.sp
            : 7.sp;

    bool isMatched = matchedFromDownload(widget.dlCtrl.downloadListMaps);
    Map map = offlineMap(widget.dlCtrl.downloadListMaps);

    return GetBuilder<MyListController>(
        init: MyListController(),
        autoRemove: false,
        builder: (c) {
          return SafeArea(
            child: SingleChildScrollView(
              controller: _scrollerBody,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: isMobile ? 10.h : 4.h),
                  if (isTablet || isDesktop)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: isDesktop ? 120.sp : 140.sp,
                            child: buildPodPlayer(),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: isDesktop ? 120.sp : 140.sp,
                              child: Padding(
                                padding: EdgeInsets.only(left: 2.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.sp),
                                      child: SizedBox(
                                        height: 30.sp,
                                        child: ElevatedButton(
                                          onPressed: () => play(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[800],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.play_arrow_rounded,
                                                  size: 20.sp),
                                              Text(
                                                "Play",
                                                style:
                                                    TextStyle(fontSize: 10.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.sp),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (!isMatched) {
                                            download();
                                          } else {
                                            Get.put(DownloadController())
                                                .loadTask();
                                            Navigator.of(context).push(
                                              MyPageRoute(
                                                builder: (context) =>
                                                    const DownloadPage(),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[800],
                                        ),
                                        child: buttonStatus(context, map),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.sp),
                                      child: SizedBox(
                                        height: 30.sp,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              c.addOrRemoveMyList(widget.movie),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[800],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                  c.getAddItem(
                                                          widget.movie.postId)
                                                      ? Icons.done
                                                      : Icons.add,
                                                  size: 20.sp),
                                              Text(
                                                c.getAddItem(
                                                        widget.movie.postId)
                                                    ? "Added"
                                                    : "Add to list",
                                                style:
                                                    TextStyle(fontSize: 10.sp),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isMobile)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: buildButton(
                            context,
                            label: "Play",
                            onTap: () => play(),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(right: 2.sp, left: 4.sp),
                                child: buildButton(
                                  context,
                                  widthSize: width / 2,
                                  label: c.getAddItem(widget.movie.postId)
                                      ? "Added"
                                      : "Add to list",
                                  icon: c.getAddItem(widget.movie.postId)
                                      ? Icons.done
                                      : Icons.add,
                                  onTap: () =>
                                      c.addOrRemoveMyList(widget.movie),
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(right: 4.sp, left: 2.sp),
                                child: buildButton(
                                  context,
                                  widthSize: width / 2,
                                  label: 'Download',
                                  icon: Icons.file_download_outlined,
                                  child: isMatched
                                      ? buttonStatus(context, map)
                                      : null,
                                  onTap: () {
                                    if (!isMatched) {
                                      download();
                                    } else {
                                      Get.put(DownloadController()).loadTask();
                                      Navigator.of(context).push(
                                        MyPageRoute(
                                          builder: (context) =>
                                              const DownloadPage(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  (widget.detail.story.isNotEmpty)
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: 8.w,
                            right: 8.w,
                            top: isMobile ? 12.h : 4.sp,
                            bottom: isMobile ? 12.h : 4.sp,
                          ),
                          child: ReadMoreText(
                            " ${widget.detail.story}",
                            trimLines: 4,
                            trimMode: TrimMode.Line,
                            trimExpandedText: "  Show less",
                            trimCollapsedText: "  Read more",
                            lessStyle: TextStyle(
                                fontSize: textSize, color: Colors.blue),
                            moreStyle: TextStyle(
                                fontSize: textSize, color: Colors.blue),
                            style: TextStyle(
                                fontSize: textSize, color: whiteBlack),
                          ),
                        )
                      : SizedBox(height: isMobile ? 14.sp : 6.sp),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.detail.released.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.sp),
                                child: Text(
                                  widget.detail.released,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    color: whiteBlack,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        widget.detail.rating.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.sp),
                                child: Text(
                                  "Rate: ${widget.detail.rating}/10",
                                  style: TextStyle(
                                    fontSize: textSize,
                                    color: whiteBlack,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        widget.detail.runtime.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.sp),
                                child: Text(
                                  widget.detail.runtime,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    color: whiteBlack,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        widget.detail.language.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.sp),
                                child: Text(
                                  widget.detail.language,
                                  style: TextStyle(
                                    fontSize: textSize,
                                    color: whiteBlack,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(height: 4.sp),
                        if (widget.movie.isAdult == "1")
                          Container(
                            width: isMobile
                                ? 24.sp
                                : isTablet
                                    ? 18.sp
                                    : 15.sp,
                            padding: EdgeInsets.all(2.sp),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              "18+",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile
                                    ? 10.sp
                                    : isTablet
                                        ? 7.sp
                                        : 5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        SizedBox(height: 2.sp),
                        if (widget.movie.schedulePost?['time'] != null &&
                            widget.movie.status.toLowerCase() == "ongoing")
                          CountDownEpisodeWidget(
                            dateTime: DateTime.parse(
                                widget.movie.schedulePost!['time']),
                            comingEpisode: widget.movie.schedulePost?['text'],
                            movie: widget.movie,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.sp),
                  DefaultTabController(
                    length: tabLength(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          onTap: (_) => _scrollerBody.animateTo(
                            _scrollerBody.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear,
                          ),
                          indicatorColor: Colors.green,
                          tabs: tabs,
                          isScrollable: true,
                          unselectedLabelColor:
                              darkMode ? Colors.white54 : Colors.black54,
                          labelColor: whiteBlack,
                          unselectedLabelStyle: TextStyle(
                            fontSize: isMobile
                                ? 13.sp
                                : isTablet
                                    ? 9.sp
                                    : 7.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          labelStyle: TextStyle(
                            fontSize: isMobile
                                ? 14.sp
                                : isTablet
                                    ? 10.sp
                                    : 8.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: isMobile
                              ? (height - 335.sp).clamp(200, 1000)
                              : height / 1.5,
                          child: TabBarView(
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              if (widget.detail.type != "Movie")
                                EpisodesWidget(
                                  postTitle: widget.movie.postTitle,
                                  files: widget.detail.fileLink,
                                  banner: widget.detail.banner,
                                  subUrl: widget.detail.subtitles,
                                  type: widget.detail.type,
                                  ytCtrl: widget.ytCtrl,
                                  postId: widget.detail.postId,
                                  status: widget.movie.status,
                                  detailLink: widget.movie.link,
                                  dlCtrl: widget.dlCtrl,
                                ),
                              if (widget.detail.castCrew.isNotEmpty)
                                CastCrewDetail(casts: widget.detail.castCrew),
                              GridViewPostWidget(
                                data: widget.detail.relatedPosts,
                                label: 'You may like',
                                podCtrl: widget.ytCtrl,
                              ),
                              GridViewPostWidget(
                                data: widget.detail.trendingPosts,
                                label: 'Trending',
                                postId: widget.detail.postId,
                                podCtrl: widget.ytCtrl,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buttonStatus(BuildContext context, Map map) {
    TextStyle style =
        TextStyle(fontSize: isMobile ? 18.sp : 10.sp, color: Colors.white);
    double iconSize = isMobile ? 32.sp : 20.sp;
    if (map['status'] == DownloadTaskStatus.complete) {
      return Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            Icons.done,
            color: Colors.white,
            size: iconSize,
          ),
          Text('Downloaded', style: style),
        ],
      );
    } else if (map['status'] == DownloadTaskStatus.paused) {
      return Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            Icons.pause_outlined,
            color: Colors.white,
            size: iconSize,
          ),
          Text('Paused', style: style),
        ],
      );
    } else if (map['status'] == DownloadTaskStatus.running) {
      return Text(
        'Downloading...',
        style: TextStyle(fontSize: isMobile ? 18.sp : 10.sp),
      );
    } else {
      return Row(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_downward_sharp,
            color: Colors.white,
            size: iconSize,
          ),
          Text('Download', style: style),
        ],
      );
    }
  }

  Widget buildPodPlayer() => PodVideoPlayer(
        controller: widget.ytCtrl!,
        onVideoError: () => buildBannerImage,
        onLoading: (context) => Center(
          child: SizedBox(
            height: 50.sp,
            width: 50.sp,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ),
        videoThumbnail: DecorationImage(
          image: CachedNetworkImageProvider(
            widget.detail.banner,
            cacheKey: "${widget.movie.postId}cover",
          ),
        ),
      );

  Widget get buildBannerImage => AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: widget.detail.banner,
          fit: BoxFit.cover,
          cacheKey: "${widget.movie.postId}cover",
          width: width,
          fadeOutDuration: const Duration(milliseconds: 200),
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (context, holder) => SizedBox(
            height: 210.sp,
            width: width,
          ),
        ),
      );

  Widget buildButton(
    BuildContext context, {
    IconData? icon,
    Widget? child,
    String label = "Button",
    Color? color,
    void Function()? onTap,
    double? widthSize,
  }) {
    return Center(
      child: SizedBox(
        height: 46.sp,
        width: widthSize ?? width - 6.w,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            backgroundColor: color ?? Colors.grey[800],
            elevation: 0,
          ),
          child: child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon ?? Icons.play_arrow, size: 32.sp),
                  Text(
                    label,
                    style: TextStyle(fontSize: 18.sp, color: Colors.white),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  final List<String> _servers = [
    "premium",
    "alpha",
    "beta",
    "cosmos",
  ];

  void play() {
    if (widget.detail.type.toLowerCase() == 'movie') {
      if (widget.ytCtrl != null) {
        widget.ytCtrl?.pause();
      }
      final serv = findServer();
      Get.bottomSheet(
        SelectServerWidget(
          files: widget.detail.fileLink,
          servers: serv,
          subUrl: widget.detail.subtitles,
          type: widget.detail.type,
          postTitle: widget.movie.postTitle,
          postId: widget.movie.postId,
          ctx: context,
          download: false,
        ),
      );
    } else {
      _scrollerBody.animateTo(
        _scrollerBody.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }
  }

  Future download() async {
    if (widget.detail.type.toLowerCase() != 'movie') {
      _scrollerBody.animateTo(
        _scrollerBody.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    } else {
      if (widget.ytCtrl != null) {
        widget.ytCtrl?.pause();
      }
      final serv = findServer();
      Get.bottomSheet(
        SelectServerWidget(
          files: widget.detail.fileLink,
          servers: serv,
          subUrl: widget.detail.subtitles,
          type: widget.detail.type,
          postTitle: widget.movie.postTitle,
          postId: widget.movie.postId,
          ctx: context,
          download: true,
          onDownloadStart: () => setState(() {}),
        ),
      );
    }
  }

  bool matchedFromDownload(List<Map> ls) {
    final name =
        "${widget.movie.postId}. ${widget.movie.postTitle.replaceAll(":", "")}.MP4";
    if (ls.isNotEmpty) {
      final i = ls.firstWhereOrNull((e) => e['filename'] == name);
      return i != null;
    } else {
      return false;
    }
  }

  Map offlineMap(List<Map> ls) {
    final name =
        "${widget.movie.postId}. ${widget.movie.postTitle.replaceAll(":", "")}.MP4";
    final i = ls.where((e) => e['filename'] == name);
    if (i.isNotEmpty) {
      return i.first;
    } else {
      return {};
    }
  }

  List<String> findServer() {
    List<String> s = [];
    if (widget.detail.type.toLowerCase() == "movie") {
      for (int i = 0; i < _servers.length; i++) {
        final res = widget.detail.fileLink
            .where((e) => e.server.toLowerCase() == _servers[i].toLowerCase())
            .toList();
        if (res.isNotEmpty) {
          s.add(_servers[i]);
        }
      }
    } else {
      final se = widget.detail.fileLink
          .where((e) => e.key.toLowerCase() == "s01e01")
          .toList();
      if (se.isNotEmpty) {
        for (int i = 0; i < _servers.length; i++) {
          final x = se
              .where((e) => e.server.toLowerCase() == _servers[i].toLowerCase())
              .toList();
          if (x.isNotEmpty) {
            s.add(_servers[i]);
          }
        }
      }
    }
    return s;
  }
}
