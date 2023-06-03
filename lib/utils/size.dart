import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/utils/dark_light.dart';

bool get isMobile => Get.width < 850;
bool get isTablet => Get.width >= 850 && Get.width < 1100;
bool get isDesktop => Get.width >= 1100;

Size get size => Get.size;

double get width => Get.width;
double get height => Get.height;

double get statusLabelSize => isMobile ? 10.sp : isTablet ? 6.sp : 5.sp;
double get normalIconSize => isMobile ? 24.sp : isTablet ? 13.sp : 9.sp;
double get normalLabelSize => isMobile ? 16.sp : isTablet ? 9.5.sp : 7.sp;
double get smallLabelSize => isMobile ? 15.sp : isTablet ? 8.5.sp : 5.sp;

double get bannerAdSize => isMobile ? 60.sp : isTablet ? 30.sp : 25.sp;

TextStyle get normalLabelStyle => GoogleFonts.lato(fontSize: normalLabelSize, color: whiteBlack, fontWeight: FontWeight.w900);
TextStyle get greyedTextStyle => TextStyle(fontSize: smallLabelSize, color: darkMode ? Colors.white54 : Colors.black54);
TextStyle get boldAppbarTextStyle => GoogleFonts.lato(
  fontSize: isMobile ? 18.sp : isTablet ? 11.sp : 7.sp,
  color: whiteBlack,
  fontWeight: FontWeight.bold,
);