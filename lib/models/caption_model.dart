import 'dart:core';

class CaptionModel {
  Duration start = const Duration();
  Duration end = const Duration();
  String data = "";

  CaptionModel({
    required this.start,
    required this.end,
    this.data = "",
  });
}
