import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class TrailerPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final Widget? thumbnail;
  const TrailerPlayerWidget({
    Key? key,
    required this.controller,
    this.thumbnail,
  }) : super(key: key);

  @override
  State<TrailerPlayerWidget> createState() => _TrailerPlayerWidgetState();
}

class _TrailerPlayerWidgetState extends State<TrailerPlayerWidget> {
  ValueNotifier<bool> hideControls = ValueNotifier(false);

  ValueNotifier<bool> isBuffering = ValueNotifier(false);
  ValueNotifier<bool> isPlaying = ValueNotifier(false);

  ValueNotifier<bool> isVideoEnded = ValueNotifier<bool>(false);

  ValueNotifier<Duration> duration = ValueNotifier<Duration>(const Duration());
  ValueNotifier<Duration> position = ValueNotifier<Duration>(const Duration());

  Timer? _timerControls;

  void popControls() {
    _timerControls?.cancel();
    hideControls.value = false;
    _timerControls = Timer(const Duration(milliseconds: 2500), () {
      hideControls.value = true;
    });
  }

  void _playerListener() {
    duration.value = widget.controller.value.duration;
    position.value = widget.controller.value.position;
    isPlaying.value = widget.controller.value.isPlaying;
    if (widget.controller.value.isBuffering) {
      isBuffering.value = true;
      hideControls.value = false;
    } else {
      isBuffering.value = false;
    }
    if (widget.controller.value.isInitialized &&
        !widget.controller.value.isPlaying &&
        widget.controller.value.duration == widget.controller.value.position) {
      widget.controller.pause();
      isVideoEnded.value = true;
      hideControls.value = false;
    } else {
      isVideoEnded.value = false;
    }
  }

  @override
  void initState() {
    widget.controller.addListener(_playerListener);
    Future.delayed(const Duration(milliseconds: 1500), () {
      hideControls.value = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_playerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: hideControls,
        builder: (context, isHideControls, _) {
          return GestureDetector(
            onTap: () {
              hideControls.value = !isHideControls;
              if (isHideControls) {
                popControls();
              }
            },
            child: ValueListenableBuilder<bool>(
                valueListenable: isVideoEnded,
                builder: (context, isEnded, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            height: widget.controller.value.size.height,
                            width: widget.controller.value.size.width,
                            child: VideoPlayer(widget.controller),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isHideControls ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          height: context.height,
                          width: context.width,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                                Colors.black87,
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        bottom: isHideControls ? -3 : 12 * 2,
                        width: context.width - (isHideControls ? 0 : 12 * 1.5),
                        duration: const Duration(milliseconds: 200),
                        child: ValueListenableBuilder<Duration>(
                          valueListenable: duration,
                          builder: (context, d, _) {
                            return ValueListenableBuilder<Duration>(
                              valueListenable: position,
                              builder: (context, p, _) {
                                return ProgressBar(
                                  progress: p,
                                  total: d,
                                  onSeek: (value) {
                                    popControls();
                                    widget.controller.seekTo(value);
                                  },
                                  timeLabelType: TimeLabelType.remainingTime,
                                  timeLabelLocation: TimeLabelLocation.above,
                                  baseBarColor: Colors.grey.shade700,
                                  bufferedBarColor: Colors.grey.shade400,
                                  thumbColor: Colors.green,
                                  progressBarColor: Colors.green,
                                  barHeight: 6,
                                  timeLabelPadding: 8,
                                  thumbRadius: isHideControls ? 0 : 8,
                                  timeLabelTextStyle: TextStyle(
                                    color: Colors.white
                                        .withOpacity(isHideControls ? 0 : 1),
                                    fontSize: 14,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isPlaying,
                        builder: (context, playing, _) {
                          return ValueListenableBuilder<bool>(
                              valueListenable: isBuffering,
                              builder: (context, buffering, _) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isHideControls
                                      ? SizedBox(
                                          key: UniqueKey(),
                                        )
                                      : ClipOval(
                                          key: UniqueKey(),
                                          child: SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                popControls();
                                                if (playing) {
                                                  widget.controller.pause();
                                                } else if (isEnded) {
                                                  widget.controller
                                                      .seekTo(Duration.zero);
                                                  widget.controller.play();
                                                } else {
                                                  widget.controller.play();
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor: Colors.black54,
                                                padding: const EdgeInsets.all(12),
                                              ),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: isEnded
                                                    ? Icon(
                                                        Icons.refresh,
                                                        size: 24 * 1.5,
                                                        color: Colors.white,
                                                        key: UniqueKey(),
                                                      )
                                                    : playing
                                                        ? Icon(
                                                            Icons.pause,
                                                            size: 24 * 1.5,
                                                            color: Colors.white,
                                                            key: UniqueKey(),
                                                          )
                                                        : buffering
                                                            ? SizedBox(
                                                                height: 40,
                                                                width: 40,
                                                                key:
                                                                    UniqueKey(),
                                                                child: const CircularProgressIndicator(
                                                                    color: Colors
                                                                        .green),
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                size: 24 * 1.5,
                                                                color: Colors
                                                                    .white,
                                                                key:
                                                                    UniqueKey(),
                                                              ),
                                              ),
                                            ),
                                          ),
                                        ),
                                );
                              });
                        },
                      ),
                    ],
                  );
                }),
          );
        });
  }
}
