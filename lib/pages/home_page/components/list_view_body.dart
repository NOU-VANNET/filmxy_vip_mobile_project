import 'package:flutter/material.dart';
import 'package:vip/widgets/horizontal_list_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/widgets/skeleton_widget.dart';

class ListViewBodyHomeWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;
  final bool isLoading;
  const ListViewBodyHomeWidget({Key? key, required this.dataList, required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return buildShimmer();
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: dataList.length,
        padding: EdgeInsets.only(bottom: 10.h),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return HorizontalListViewWidget(data: dataList[index]);
        },
      );
    }
  }

  Widget buildShimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 18.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 5.sp),
          child: SkeletonWidget(
            height: 20.h,
            width: 100.w,
          ),
        ),
        SizedBox(
          height: 154.sp,
          child: ListView.builder(
            itemCount: 4,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => SkeletonWidget(
              height: 154.sp,
              width: 114.sp,
              margin: EdgeInsets.only(left: 4.w),
            ),
          ),
        ),
      ],
    );
  }

}
