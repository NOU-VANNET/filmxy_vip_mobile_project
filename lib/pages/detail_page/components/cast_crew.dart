import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/models/detail_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class CastCrewDetail extends StatelessWidget {
  final List<CastCrew> casts;
  const CastCrewDetail({
    Key? key,
    required this.casts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: casts.length,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 12.sp),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : 4,
        mainAxisExtent: isTablet ? 55.sp : isDesktop ? 45.sp : null,
      ),
      itemBuilder: (context, index) {
        return SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: casts[index].castPicture,
                  height: 50.h,
                  width: 50.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                casts[index].castName,
                style: TextStyle(
                  fontSize: isDesktop ? 6.sp : 12.h,
                  color: whiteBlack,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
