import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/widgets/skeleton_widget.dart';
import 'package:vip/widgets/status_widget.dart';

class PosterWidget extends StatelessWidget {
  final String posterImage;
  final String title;
  final num id;
  final double? height;
  final double? width;
  final bool noLeftPadding;
  final String status;
  final String runningEpisode;
  final String adult;
  const PosterWidget({
    Key? key,
    required this.posterImage,
    required this.id,
    required this.title,
    this.height,
    this.width,
    required this.status,
    required this.runningEpisode,
    required this.adult,
    this.noLeftPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = isMobile ? 124.w : isTablet ? 78.w : 56.w;
    final h = isMobile || isTablet ? 176.h : 80.sp;
    return SizedBox(
      width: width ?? w,
      height: height ?? h,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: posterImage,
              fit: BoxFit.cover,
              width: width ?? w,
              height: height ?? h,
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: const Duration(milliseconds: 100),
              placeholder: (context, holder) => SkeletonWidget(
                width: width ?? w,
                height: height ?? h,
              ),
              cacheKey: "${id}poster",
              maxHeightDiskCache: 360,
              maxWidthDiskCache: 240,
            ),
          ),
          if (adult == "1")
            Positioned(
              top: 4.sp,
              left: 4.sp,
              child: Container(
                padding: EdgeInsets.all(isMobile ? 2.sp : 1.sp),
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
          status.isNotEmpty
              ? Positioned(
                  top: isMobile || isTablet ? 4.sp : 2.sp,
                  right: isMobile || isTablet ? 4.sp : 2.sp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusWidget(
                        label: status,
                        status: status,
                        fontSize: statusLabelSize,
                      ),
                      SizedBox(height: 1.5.sp),
                      if (runningEpisode.isNotEmpty)
                        StatusWidget(
                          label: runningEpisode,
                          status: status,
                          fontSize: statusLabelSize,
                        ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
