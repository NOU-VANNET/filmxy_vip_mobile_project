import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vip/models/movie_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/detail_page/detail_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/widgets/skeleton_widget.dart';

class SearchItemView extends StatelessWidget {
  final MovieModel movie;
  const SearchItemView({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MyPageRoute(
            builder: (builder) => DetailPage(movie: movie),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: CachedNetworkImage(
                imageUrl: movie.thumbnail,
                cacheKey: "${movie.postId}poster",
                fit: BoxFit.cover,
                height: isMobile
                    ? 126.h
                    : isTablet
                        ? 110.sp
                        : 80.sp,
                width: isMobile
                    ? 86.w
                    : isTablet
                        ? 72.sp
                        : 56.sp,
                maxHeightDiskCache: 360,
                maxWidthDiskCache: 240,
                placeholder: (context, holder) => SkeletonWidget(
                  height: 126.h,
                  width: 86.w,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12.w : 6.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: width - 140.w,
                  child: Text(
                    movie.postTitle,
                    maxLines: 2,
                    style: TextStyle(
                      color: whiteBlack,
                      fontSize: isMobile
                          ? 16.sp
                          : isTablet
                              ? 12.sp
                              : 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: width - 140.w,
                  child: Text(
                    movie.released,
                    maxLines: 2,
                    style: TextStyle(
                      color: whiteBlack,
                      fontSize: isMobile ? 14.sp : isTablet ? 11.sp : 8.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
