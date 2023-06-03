import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/shimmer_controller.dart';

class SkeletonWidget extends StatelessWidget {
  const SkeletonWidget({
    Key? key,
    this.radius,
    this.height,
    this.width,
    this.margin,
  }) : super(key: key);

  final double? radius;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShimmerController>(
        init: ShimmerController(),
        autoRemove: false,
        builder: (c) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: c.isLoading ? 0.30 : 1.0,
            child: Container(
              height: height,
              width: width,
              margin: margin,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(radius ?? 4.r),
              ),
            ),
          );
        });
  }
}
