import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/controllers/download_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/models/movie_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/detail_page/components/body.dart';
import 'package:vip/pages/search_page/search_page.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:pod_player/pod_player.dart';

List<DetailModel> detailList = [];

Future readDetailCache() async {
  final json = await Services().getDetailCache();
  detailList = await compute(detailModelListFromJson, json);
}

class DetailPage extends StatefulWidget {
  final MovieModel movie;
  final bool disableBannerAds;
  final PodPlayerController? podCtrl;
  const DetailPage({
    Key? key,
    required this.movie,
    this.disableBannerAds = false,
    this.podCtrl,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  DetailModel? detailModel;

  PodPlayerController? ytController;

  Future getDetail() async {
    detailModel = await getDetailModel(
      widget.movie.postId,
      widget.movie.link,
      widget.movie.status,
      widget.movie.type,
    );

    for (var i = 0; i < detailModel!.relatedPosts.length; i++) {
      detailModel!.relatedPosts.removeWhere((e) => e.isAdult == "1");
    }
    for (var i = 0; i < detailModel!.trendingPosts.length; i++) {
      detailModel!.trendingPosts.removeWhere((e) => e.isAdult == "1");
    }

    if (mounted) setState(() {});
    ytController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube(detailModel!.trailer),
    )..initialise();
    if (mounted) setState(() {});
  }

  Future<DetailModel> getDetailModel(
      num postId, String link, String status, String type) async {
    final details = detailList.where((e) => e.postId == postId).toList();
    if (details.isNotEmpty) {
      if (mounted) setState(() {});
      if (type.toLowerCase() != "movie") {
        if (status.toLowerCase() != "complete") reloadEpisode(postId, link);
      }
      return details.first;
    } else {
      final detail = await Services().getDetailModel(link);
      if (mounted) setState(() {});
      detailList.add(detail);
      Services().setDetailCache(detailList);
      return detail;
    }
  }

  Future reloadEpisode(num postId, String link) async {
    final detail = await Services().getDetailModel(link);
    detailList[detailList.indexWhere((e) => e.postId == postId)].fileLink =
        detail.fileLink;
    if (mounted) setState(() {});
    Services().setDetailCache(detailList);
  }

  @override
  void initState() {
    getDetail();
    Get.put(DownloadController()).loadTask();
    super.initState();
  }

  @override
  void dispose() {
    if (ytController != null) ytController?.dispose();
    if (widget.podCtrl != null) widget.podCtrl?.play();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DownloadController>(
      autoRemove: false,
      builder: (dl) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: darkLight,
          appBar: AppBar(
            toolbarHeight: isMobile
                ? 42.sp
                : isTablet
                    ? 24.sp
                    : 20.sp,
            backgroundColor: darkLight,
            iconTheme: IconThemeData(
              color: whiteBlack,
            ),
            title: Text(
              widget.movie.postTitle,
              style: GoogleFonts.lato(
                color: whiteBlack,
                fontWeight: FontWeight.w700,
                fontSize: normalLabelSize,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (ytController != null) {
                    ytController?.pause();
                  }
                  Navigator.of(context).push(
                    MyPageRoute(
                      builder: (builder) => const SearchPage(),
                    ),
                  );
                },
                icon: Icon(CupertinoIcons.search, size: normalIconSize),
                splashRadius: 24.sp,
              ),
              SizedBox(width: 5.w),
            ],
            bottom: isMobile
                ? PreferredSize(
                    preferredSize: Size.fromHeight(210.sp),
                    child: ytController != null
                        ? buildPodPlayer()
                        : Container(color: darkLight),
                  )
                : null,
          ),
          body: detailModel != null
              ? DetailBody(
                  detail: detailModel!,
                  ytCtrl: ytController,
                  movie: widget.movie,
                  dlCtrl: dl,
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.green)),
        );
      },
    );
  }

  Widget buildPodPlayer() => PodVideoPlayer(
        controller: ytController!,
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
            detailModel!.banner,
            cacheKey: "${widget.movie.postId}cover",
          ),
        ),
      );

  Widget get buildBannerImage => CachedNetworkImage(
        imageUrl: detailModel!.banner,
        fit: BoxFit.cover,
        cacheKey: "${widget.movie.postId}cover",
        width: width,
        fadeOutDuration: const Duration(milliseconds: 200),
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, holder) => SizedBox(
          height: 210.sp,
          width: width,
        ),
      );
}
