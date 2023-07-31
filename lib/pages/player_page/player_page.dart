import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/player_controller.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/pages/player_page/components/progress_indicator.dart';
import 'package:vip/pages/player_page/components/subtitles.dart';
import 'package:vip/utils/size.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlayerPage extends StatefulWidget {
  final FileLink file;
  final String subUrl;
  final String type;
  final bool offline;
  final String? offlineVideoPath;
  final VideoPlayerController? ytCtrl;
  final void Function()? onDispose;
  const PlayerPage({
    Key? key,
    required this.file,
    required this.subUrl,
    this.ytCtrl,
    required this.type,
    this.offline = false,
    this.offlineVideoPath,
    this.onDispose,
  }) : super(key: key);

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  void dispose() {
    if (widget.onDispose != null) widget.onDispose!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayerController>(
      init: PlayerController(
        file: widget.file,
        subUrl: widget.subUrl,
        ytCtrl: widget.ytCtrl,
        type: widget.type,
        offline: widget.offline,
        directory: widget.offlineVideoPath ?? '',
      ),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => ctrl.hideController(),
            child: Center(
              child: ctrl.videoPlayerController == null
                  ? const CircularProgressIndicator(color: Colors.green)
                  : Stack(
                      children: [
                        SizedBox(
                          height: height,
                          width: width,
                        ),
                        Center(
                          child: buildVideoChild(
                            ctrl.videoPlayerController!,
                            ctrl.ratioValue,
                          ),
                        ),
                        ctrl.currentL.isNotEmpty
                            ? Positioned(
                                bottom: isMobile ? 28 : 16.sp,
                                left: 24,
                                right: 24,
                                child: ctrl.caption != null
                                    ? Text(
                                        " ${ctrl.caption!.data} ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isMobile ? 18 : 8.sp,
                                          backgroundColor:
                                              Colors.black.withOpacity(0.80),
                                        ),
                                      )
                                    : const SizedBox(),
                              )
                            : const SizedBox(),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: ctrl.hideControls ? 0 : 0.60,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black87,
                                  Colors.black12,
                                  Colors.black87,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 12,
                          child: SafeArea(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: ctrl.hideControls
                                  ? const SizedBox()
                                  : Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => Get.back(),
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 24,
                          child: SafeArea(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: ctrl.hideControls
                                  ? const SizedBox()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        VideoProIndicator(
                                          ctrl.videoPlayerController!,
                                          allowScrubbing: true,
                                        ),
                                        const SizedBox(height: 22),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              onPressed: () => Get.bottomSheet(
                                                SubtitlesWidget(
                                                  subtitles: ctrl.subtitles,
                                                  controller: ctrl,
                                                ),
                                                isScrollControlled: true,
                                              ),
                                              icon: ctrl.gettingSubtitle
                                                  ? const CircularProgressIndicator(
                                                      color: Colors.white,
                                                    )
                                                  : Icon(
                                                      Icons.closed_caption_off,
                                                      color: Colors.white,
                                                      size: 14.sp,
                                                    ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  ctrl.rewind15Second(),
                                              icon: SvgPicture.asset(
                                                "assets/icons/r_15s.svg",
                                                color: Colors.white,
                                                width: 14.sp,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                ctrl.popHideControls();
                                                ctrl.playPause();
                                              },
                                              icon: ctrl.videoPlayerController!
                                                          .value.isBuffering ||
                                                      !ctrl
                                                          .videoPlayerController!
                                                          .value
                                                          .isInitialized
                                                  ? SizedBox(
                                                      height: 24.sp,
                                                      width: 24.sp,
                                                      child:
                                                          const CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Icon(
                                                      ctrl.videoPlayerController!
                                                              .value.isPlaying
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 18.sp,
                                                    ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                ctrl.popHideControls();
                                                ctrl.forward15Second();
                                              },
                                              icon: SvgPicture.asset(
                                                "assets/icons/f_15s.svg",
                                                color: Colors.white,
                                                width: 14.sp,
                                                fit: BoxFit.fitWidth,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                ctrl.popHideControls();
                                                ctrl.resizeVideoFrame();
                                              },
                                              icon: _iconRatioValue(
                                                  ctrl.ratioValue),
                                            ),
                                          ],
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
        );
      },
    );
  }

  Widget buildVideoChild(VideoPlayerController controller, num ratioValue) {
    if (ratioValue == 0) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    } else if (ratioValue == 1) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            height: controller.value.size.height,
            width: controller.value.size.width,
            child: VideoPlayer(controller),
          ),
        ),
      );
    } else {
      return VideoPlayer(controller);
    }
  }

  Widget _iconRatioValue(num ratioValue) {
    if (ratioValue == 0) {
      return SvgPicture.asset(
        'assets/icons/fts.svg',
        fit: BoxFit.fitHeight,
        color: Colors.white,
        height: 9.w,
      );
    } else if (ratioValue == 1) {
      return SvgPicture.asset(
        'assets/icons/ctf.svg',
        fit: BoxFit.fitHeight,
        color: Colors.white,
        height: 9.w,
      );
    } else {
      return SvgPicture.asset(
        'assets/icons/strch.svg',
        fit: BoxFit.fitHeight,
        color: Colors.white,
        height: 8.5.w,
      );
    }
  }
}
