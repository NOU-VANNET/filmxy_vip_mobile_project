import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';
import 'package:get/get.dart';
import 'package:vip/models/caption_model.dart';
import 'package:vip/models/detail_model.dart';
import 'package:vip/models/subtitle_model.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/utils.dart';
import 'package:pod_player/pod_player.dart' as pod;
import 'package:video_player/video_player.dart';

class PlayerController extends GetxController {
  final FileLink file;
  final String subUrl;
  final String type;
  final bool offline;
  final String directory;
  final pod.PodPlayerController? ytCtrl;
  PlayerController({
    required this.file,
    required this.subUrl,
    required this.type,
    this.directory = '',
    this.offline = false,
    this.ytCtrl,
  });

  List<CaptionModel> _captions = [];

  CaptionModel? _caption;
  CaptionModel? get caption => _caption;

  List<SubtitleModel> _subtitles = [];
  List<SubtitleModel> get subtitles {
    if (type.toLowerCase() == "movie") {
      return _subtitles;
    } else {
      if (file.key.length > 3) {
        final _s = file.key.substring(0, 3);
        final _e = file.key.substring(3, 6);
        final _se = _subtitles
            .where((e) => e.s.toLowerCase() == _s.toLowerCase())
            .toList();
        final _ep =
            _se.where((e) => e.e.toLowerCase() == _e.toLowerCase()).toList();
        return _ep;
      } else {
        return [];
      }
    }
  }

  String _dlLink = "";

  num _ratioValue = 0;
  num get ratioValue => _ratioValue;

  bool _gettingSubtitle = false;
  bool get gettingSubtitle => _gettingSubtitle;

  bool _hideControls = false;
  bool get hideControls => _hideControls;

  Timer? _timerControls;

  VideoPlayerController? videoPlayerController;

  String _currentL = "";
  String get currentL => _currentL;

  void hideController() {
    if (!_hideControls) {
      _hideControls = true;
      update();
      _timerControls?.cancel();
    } else {
      popHideControls();
    }
  }

  void popHideControls({bool hide = true}) {
    _hideControls = false;
    update();
    _timerControls?.cancel();
    if (hide) {
      _timerControls = Timer(const Duration(milliseconds: 2500), () {
        _hideControls = true;
        update();
      });
    }
  }

  void playPause() {
    if (videoPlayerController != null) {
      if (videoPlayerController!.value.isPlaying) {
        videoPlayerController?.pause();
        update();
      } else {
        videoPlayerController?.play();
        update();
      }
    }
  }

  Future loadSubtitle(String k, String l) async {
    if (!offline) {
      _gettingSubtitle = true;
      _currentL = l;
      update();
      final _source = await Services().getSubtitleSource(k);
      _captions = Services().captionDecode(_source);
      _gettingSubtitle = false;
      update();
      videoPlayerController?.addListener(_captionListener);
    }
  }

  void _captionListener() {
    if (_currentL.isNotEmpty) {
      _caption =
          Services().findCaptionFromDuration(_captions, videoPlayerController!);
      update();
    }
  }

  void disableSubtitle() {
    _currentL = "";
    _captions.clear();
    update();
  }

  Future resizeVideoFrame() async {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    _ratioValue += 1;
    if (_ratioValue >= 3) {
      _ratioValue = 0;
    }
    update();
  }

  ///This Method to skip 10 second from the video.
  Future forward15Second() async {
    goPosition(
      (currentPosition) => currentPosition + const Duration(seconds: 15),
    );
  }

  ///This Method to rewind 10 second from the video.
  Future rewind15Second() async {
    goPosition(
      (currentPosition) => currentPosition - const Duration(seconds: 15),
    );
  }

  Future goPosition(Duration Function(Duration currentPosition) builder) async {
    final currentPosition = await videoPlayerController!.position;
    final newPosition = builder(currentPosition!);
    await videoPlayerController!.seekTo(newPosition);
  }

  Future initialize() async {
    if (offline) {
      final _dir = Directory(directory);
      final File _file = File(_dir.path);
      videoPlayerController = VideoPlayerController.file(_file)
        ..initialize().then(
          (_) {
            videoPlayerController?.play();
            videoPlayerController?.addListener(videoListener);
            _hideControls = true;
            update();
          },
        );
    } else {
      String? _dLink = await Services().getDirectLink(file.linkId);
      if (_dLink != null) {
        _dlLink = _dLink;
        ytCtrl?.pause();
        videoPlayerController = VideoPlayerController.network(_dlLink)
          ..initialize().then((_) {
            if (videoPlayerController!.value.isInitialized) {
              ytCtrl?.pause();
              videoPlayerController?.play();
              videoPlayerController?.addListener(videoListener);
              _hideControls = true;
              update();
            }
          });
        update();
      } else {
        Get.back();
        Utils().showToast('Please choose another server!');
      }
    }
  }

  void videoListener() {
    if (videoPlayerController!.value.isBuffering) {
      popHideControls();
    }
    if (videoPlayerController!.value.position ==
        videoPlayerController!.value.duration) {
      Get.back();
    }
  }

  Future _getSubtitle() async {
    if (!offline) {
      _subtitles = await Services().getSubtitles(subUrl);
      update();
    }
  }

  @override
  void onInit() {
    FlutterScreenWake.keepOn(true);
    Utils().landScape();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    initialize();
    _getSubtitle();
    if (ytCtrl != null) {
      if (ytCtrl!.isInitialised || ytCtrl!.isVideoPlaying) {
        ytCtrl?.pause();
      }
    }
    super.onInit();
  }

  @override
  void onClose() {
    Utils().portrait();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );
    FlutterScreenWake.keepOn(false);
    videoPlayerController?.dispose();
    videoPlayerController = null;
    super.onClose();
  }
}
