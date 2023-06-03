import 'package:flutter/material.dart';
import 'package:vip/models/detail_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/models/movie_model.dart';
import 'package:vip/pages/detail_page/detail_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/widgets/poster_widget.dart';
import 'package:pod_player/pod_player.dart';

class HorizontalListViewWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  const HorizontalListViewWidget({Key? key, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MovieModel> movies = data["data"] as List<MovieModel>;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
          child: Text(data['label'], style: normalLabelStyle),
        ),
        SizedBox(
          height: isMobile
              ? 190.sp
              : isTablet
                  ? 115.sp
                  : 85.sp,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: movies.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.sp),
            itemBuilder: (context, index) => InkWell(
              onTap: () => Navigator.of(context).push(
                MyPageRoute(
                  builder: (context) => DetailPage(movie: movies[index]),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: isMobile ? 8.sp : 5.sp),
                child: PosterWidget(
                  posterImage: data['data'][index].thumbnail,
                  id: movies[index].postId,
                  title: movies[index].postTitle,
                  status: movies[index].status,
                  runningEpisode: movies[index].runningEpisode,
                  adult: movies[index].isAdult,
                  height: isMobile
                      ? 190.sp
                      : isTablet
                      ? 115.sp
                      : 85.sp,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.sp),
      ],
    );
  }
}

class GridViewPostWidget extends StatelessWidget {
  final List<Post> data;
  final String label;
  final num postId;
  final PodPlayerController? podCtrl;
  const GridViewPostWidget({
    Key? key,
    required this.data,
    required this.label,
    this.postId = 0,
    this.podCtrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int axisCount = isMobile
        ? 3
        : isTablet
            ? 4
            : 5;
    final w = width / axisCount;
    return GridView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      physics: data.length < 6 ? const NeverScrollableScrollPhysics() : null,
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 0 : 4.sp, vertical: 8.sp),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: axisCount,
        mainAxisExtent: w +
            (isMobile
                ? 56.sp
                : isTablet
                    ? 36.sp
                    : 20.sp),
      ),
      itemBuilder: (context, index) => InkWell(
        onTap: () {
          if (postId != data[index].postId) {
            if (podCtrl != null) podCtrl?.pause();
            Navigator.of(context).push(
              MyPageRoute(
                builder: (context) => DetailPage(
                  movie: movieModel(data[index]),
                  disableBannerAds: true,
                  podCtrl: podCtrl,
                ),
              ),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 4.sp,
              left: isMobile ? 2.sp : 0,
              right: isMobile ? 2.sp : 0,
            ),
            child: PosterWidget(
              posterImage: data[index].thumbnail,
              id: data[index].postId,
              title: data[index].postTitle,
              status: data[index].status,
              runningEpisode: data[index].runningEpisode,
              adult: data[index].isAdult,
              height: w + 56.sp,
            ),
          ),
        ),
      ),
    );
  }

  MovieModel movieModel(Post post) => MovieModel(
        postTitle: post.postTitle,
        postId: post.postId,
        thumbnail: post.thumbnail,
        isAdult: post.isAdult,
        status: post.status,
        released: post.released,
        link: post.link,
        year: post.year,
        rating: post.rating,
        runtime: post.runtime,
      );
}
