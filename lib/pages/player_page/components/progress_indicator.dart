import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

/// Used to configure the [VideoProIndicator] widget's colors for how it
/// describes the video's status.
///
/// The widget uses default colors that are customize able through this class.
class VideoProgressColors {
  /// Any property can be set to any color. They each have defaults.
  ///
  /// [playedColor] defaults to red at 70% opacity. This fills up a portion of
  /// the [VideoProIndicator] to represent how much of the video has played
  /// so far.
  ///
  /// [bufferedColor] defaults to blue at 20% opacity. This fills up a portion
  /// of [VideoProIndicator] to represent how much of the video has
  /// buffered so far.
  ///
  /// [backgroundColor] defaults to gray at 50% opacity. This is the background
  /// color behind both [playedColor] and [bufferedColor] to denote the total
  /// size of the video compared to either of those values.
  const VideoProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(200, 200, 200, 0.61),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.31),
  });

  /// [playedColor] defaults to red at 70% opacity. This fills up a portion of
  /// the [VideoProIndicator] to represent how much of the video has played
  /// so far.
  final Color playedColor;

  /// [bufferedColor] defaults to blue at 20% opacity. This fills up a portion
  /// of [VideoProIndicator] to represent how much of the video has
  /// buffered so far.
  final Color bufferedColor;

  /// [backgroundColor] defaults to gray at 50% opacity. This is the background
  /// color behind both [playedColor] and [bufferedColor] to denote the total
  /// size of the video compared to either of those values.
  final Color backgroundColor;
}

class _VideoScrubber extends StatefulWidget {
  const _VideoScrubber({
    required this.child,
    required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying &&
            controller.value.position != controller.value.duration) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class VideoProIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  const VideoProIndicator(
      this.controller, {
        Key? key,
        this.colors = const VideoProgressColors(),
        required this.allowScrubbing,
        this.padding = const EdgeInsets.only(top: 5.0),
      }) : super(key: key);

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  _VideoProIndicatorState createState() => _VideoProIndicatorState();
}

class _VideoProIndicatorState extends State<VideoProIndicator> {
  _VideoProIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitsHours = twoDigits(duration.inHours.remainder(60));
    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitsHours:$twoDigitsMinutes:$twoDigitsSeconds";
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
                child: Text(
                  '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: maxBuffering / duration,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
                  backgroundColor: colors.backgroundColor,
                  minHeight: 6.0,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: position / duration,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
                  backgroundColor: Colors.transparent,
                  minHeight: 6.0,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      progressIndicator = Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
                child: Text(
                  '${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: null,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: colors.backgroundColor,
            minHeight: 6.0,
          ),
        ],
      );
      LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
        minHeight: 6.0,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _VideoScrubber(
        controller: controller,
        child: paddedProgressIndicator,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}