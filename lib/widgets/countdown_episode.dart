import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/extensions.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/utils/utils.dart';

class CountDownEpisodeWidget extends StatefulWidget {
  final String? comingEpisode;
  final MovieModel movie;
  final DateTime dateTime;
  const CountDownEpisodeWidget({
    Key? key,
    this.comingEpisode,
    required this.dateTime,
    required this.movie,
  }) : super(key: key);

  @override
  State<CountDownEpisodeWidget> createState() => _CountDownEpisodeWidgetState();
}

class _CountDownEpisodeWidgetState extends State<CountDownEpisodeWidget> {
  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cd = widget.dateTime.getUTC();
    final n = DateTime.now();

    Map<String, dynamic> time = Utils().timeLeft(cd, n);

    bool isFinished = time['finished'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.sp : 6.sp,
        vertical: isMobile ? 6.sp : 3.sp,
      ),
      margin: EdgeInsets.symmetric(vertical: 2.sp),
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey[800] : Colors.grey[900],
        borderRadius: BorderRadius.circular(6.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: widget.comingEpisode,
                  style: TextStyle(
                    fontSize: isMobile ? 16.sp : isTablet ? 9.sp : 7.5.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: isFinished ? '  Coming soon!' : '  Coming in:',
                      style: TextStyle(
                        fontSize: isMobile ? 15.sp : isTablet ? 9.sp : 7.sp,
                        color: Colors.white.withOpacity(0.80),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 4.sp : 2.sp),
              if (!isFinished)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    textSpans(time['day'],
                        (time['day'] > 0) ? ' days   ' : ' day   '),
                    textSpans(time['hour'],
                        (time['hour'] > 0) ? ' hrs   ' : ' hr   '),
                    textSpans(time['minute'], ' min   '),
                    textSpans(time['second'], ' sec'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget textSpans(int value, String type) {
    return RichText(
      text: TextSpan(
        text: "$value",
        style: TextStyle(
          fontSize: isMobile ? 16.sp : isTablet ? 9.sp : 7.5.sp,
          color: Colors.white.withOpacity(0.80),
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: type,
            style: TextStyle(
              fontSize: isMobile ? 15.sp : isTablet ? 9.sp : 7.sp,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
