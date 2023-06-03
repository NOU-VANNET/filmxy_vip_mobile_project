import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/pages/detail_page/detail_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/size.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/widgets/skeleton_widget.dart';
import 'package:vip/widgets/status_widget.dart';

class TopSliderWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isLoading;
  const TopSliderWidget({
    Key? key,
    required this.data,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<TopSliderWidget> createState() => _TopSliderWidgetState();
}

class _TopSliderWidgetState extends State<TopSliderWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return buildLoadingView(context);
    } else {
      List<MovieModel> movies = widget.data['data'] as List<MovieModel>;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.sp : 6.sp,
              vertical: isMobile ? 5.sp : 0,
            ),
            child: Text(
              widget.data["label"] as String,
              style: normalLabelStyle,
            ),
          ),
          CarouselSlider.builder(
            itemCount: movies.length,
            options: options(context),
            itemBuilder: (context, index, _) =>
                buildItemSliderView(context, movies[index]),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 8.sp : 0.sp,
                horizontal: isMobile ? 12.sp : 2.sp,
              ),
              child: SizedBox(
                height: isMobile ? 10.sp : 5.sp,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(movies.length,
                      (i) => buildItemDotView(context, i)),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget bannerPreview(String banner, num postId) {
    return CachedNetworkImage(
      imageUrl: banner,
      cacheKey: "${postId + 1}cover",
      maxHeightDiskCache: 480,
      maxWidthDiskCache: 720,
    );
  }

  Widget buildItemSliderView(BuildContext context, MovieModel movie) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MyPageRoute(
            builder: (context) => DetailPage(movie: movie),
          ),
        );
      },
      child: Container(
        height: isMobile ? height / 2.4 : height / 3.4,
        width: isMobile ? width / 2 : width / 3,
        margin: EdgeInsets.only(
          bottom: 12.sp,
          top: 6.sp,
          left: isMobile ? 12.sp : 8.sp,
          right: isMobile ? 12.sp : 8.sp,
        ),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              spreadRadius: 3,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: movie.thumbnail,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                fadeInDuration: const Duration(milliseconds: 100),
                fadeOutDuration: const Duration(milliseconds: 100),
                placeholder: (context, holder) => SkeletonWidget(
                  height: height / 2.4,
                  width: width / 2,
                ),
                cacheKey: "${movie.postId}poster",
                maxHeightDiskCache: 540,
                maxWidthDiskCache: 420,
              ),
            ),
            if (movie.isAdult == "1")
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
            if (movie.isAdult == "1")
              Positioned(
                top: isMobile || isTablet ? 4.sp : 2.sp,
                left: isMobile || isTablet ? 4.sp : 2.sp,
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 1.sp : 2.sp),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    "18+",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: statusLabelSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            movie.status.isNotEmpty
                ? Positioned(
                    top: isMobile || isTablet ? 4.sp : 2.sp,
                    right: isMobile || isTablet ? 4.sp : 2.sp,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusWidget(
                          label: movie.status,
                          status: movie.status,
                          fontSize: statusLabelSize,
                        ),
                        SizedBox(height: 1.5.sp),
                        if (movie.runningEpisode.isNotEmpty)
                          StatusWidget(
                            label: movie.runningEpisode,
                            status: movie.status,
                            fontSize: statusLabelSize,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildItemDotView(BuildContext context, int i) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 1.sp,
        vertical: _currentIndex == i ? 0 : 2.h,
      ),
      child: AnimatedContainer(
        height: _currentIndex == i
            ? (isMobile
                ? 6.sp
                : isTablet
                    ? 4.sp
                    : 3.sp)
            : isDesktop
                ? 2.sp
                : 5.sp,
        width: _currentIndex == i
            ? (isMobile
                ? 16.sp
                : isTablet
                    ? 8.sp
                    : 5.sp)
            : (isMobile
                ? 5.sp
                : isTablet
                    ? 3.sp
                    : 2.sp),
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _currentIndex == i ? Colors.green : Colors.grey[500],
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }

  Widget buildLoadingView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonWidget(
          height: 20.h,
          width: 120.w,
          margin: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 5.sp),
        ),
        Center(
          child: SkeletonWidget(
            height: height / 2.4,
            width: width - 12.sp,
            margin: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 5.sp),
          ),
        ),
      ],
    );
  }

  CarouselOptions options(BuildContext context) => CarouselOptions(
        height: isMobile
            ? height / 2.2
            : isTablet
                ? height / 2.4
                : height / 2,
        disableCenter: false,
        enlargeCenterPage: true,
        viewportFraction: isMobile
            ? 0.60
            : isTablet
                ? 0.30
                : 0.20,
        autoPlay: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 400),
        autoPlayInterval: const Duration(seconds: 12),
        onPageChanged: (index, _) => setState(() => _currentIndex = index),
      );
}
