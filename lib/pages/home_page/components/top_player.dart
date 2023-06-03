import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:pod_player/pod_player.dart';

class TopPlayer extends StatelessWidget {
  final String banner;
  final num postId;
  final PodPlayerController controller;
  const TopPlayer({
    Key? key,
    required this.banner,
    required this.controller,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PodVideoPlayer(
      controller: controller,
      onVideoError: () => CachedNetworkImage(
        imageUrl: banner,
        cacheKey: "${postId}cover",
      ),
      overlayBuilder: controller.isFullScreen
          ? (_) => SafeArea(
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(12.sp),
          child: ElevatedButton(
            onPressed: () => controller.disableFullScreen(context),
            child: Icon(Icons.clear, color: whiteBlack, size: 24.sp),
          ),
        ),
      )
          : (_) => const SizedBox(),
      alwaysShowProgressBar: false,
      onLoading: (context) => CachedNetworkImage(
        imageUrl: banner,
        cacheKey: "${postId}cover",
      ),
      videoThumbnail: DecorationImage(
        image: CachedNetworkImageProvider(
          banner,
          cacheKey: "${postId}cover",
        ),
      ),
    );
  }
}
