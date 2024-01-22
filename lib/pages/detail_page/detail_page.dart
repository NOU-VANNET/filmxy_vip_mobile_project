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
import 'package:vip/utils/extensions.dart';
import 'package:vip/utils/size.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../widgets/trailer_widget.dart';

List<DetailModel> detailList = [];

Future readDetailCache() async {
  final json = await Services().getDetailCache();
  detailList = await compute(detailModelListFromJson, json);
}

class DetailPage extends StatefulWidget {
  final MovieModel movie;
  final bool disableBannerAds;
  final VideoPlayerController? podCtrl;
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

  VideoPlayerController? ytController;
  bool isTrailerError = false;
  bool isTrailerInitializing = true;

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
    await _initTrailer();
    if (mounted) setState(() {});
  }

  Future _initTrailer() async {
    String linkToPlay = '';

    var yt = YoutubeExplode();
    final manifest =
        await yt.videos.streamsClient.getManifest(detailModel!.trailer);

    for (var i in manifest.muxedStreams) {
      int quality = int.parse(i.qualityLabel.split('p')[0]);
      if (quality == 720) {
        linkToPlay = i.url.toString();
        break;
      } else if (quality == 480) {
        linkToPlay = i.url.toString();
        break;
      } else if (quality == 360) {
        linkToPlay = i.url.toString();
        break;
      } else if (quality == 240) {
        linkToPlay = i.url.toString();
        break;
      }
    }

    if (linkToPlay.isNotEmpty) {
      ytController = VideoPlayerController.networkUrl(Uri.parse(linkToPlay))
        ..initialize().then((_) async {
          ytController?.addListener(_ytPlayerListener);
          if (ytController!.value.isInitialized) {
            await ytController?.play();
            if (mounted) setState(() {});
          }
        });
    } else {
      isTrailerError = true;
    }

    isTrailerInitializing = false;

    if (mounted) setState(() {});
  }

  void _ytPlayerListener() {
    if (ytController!.value.hasError) {
      isTrailerError = true;
      setState(() {});
    }
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
    ytController?.dispose();
    widget.podCtrl?.play();
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
          ),
          body: detailModel != null
              ? DetailBody(
                  detail: detailModel!,
                  ytCtrl: ytController,
                  movie: widget.movie,
                  dlCtrl: dl,
                  trailerPlayer: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: trailerPlayer(),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
        );
      },
    );
  }

  Widget get thumbnailChild => CachedNetworkImage(
        imageUrl: detailModel!.banner,
        cacheKey: "${widget.movie.postId}cover",
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, _) => const AspectRatio(
          aspectRatio: 16 / 9,
          child: SizedBox(),
        ),
      );

  Widget trailerPlayer() {
    if (isTrailerError || isTrailerInitializing) {
      return thumbnailChild;
    } else {
      if (ytController != null || ytController!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: TrailerPlayerWidget(
            controller: ytController!,
            thumbnail: thumbnailChild,
          ),
        );
      } else {
        return thumbnailChild;
      }
    }
  }
}
