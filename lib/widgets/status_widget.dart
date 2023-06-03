import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/utils/size.dart';

class StatusWidget extends StatelessWidget {
  final String status;
  final String label;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  const StatusWidget({
    Key? key,
    required this.status,
    required this.label,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: padding ?? EdgeInsets.symmetric(horizontal: isMobile || isTablet ? 6.sp : 4.sp, vertical: 1.sp),
      decoration: BoxDecoration(
        color: status == "Ongoing" ? Colors.purple : Colors.green,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: const [
          BoxShadow(
            color: Colors.white54,
            blurRadius: 0.6,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: fontSize ?? 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
