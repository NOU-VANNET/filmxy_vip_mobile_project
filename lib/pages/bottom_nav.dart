import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vip/pages/discover_page/discover.dart';
import 'package:vip/pages/download_page/download.dart';
import 'package:vip/pages/home_page/home_page.dart';
import 'package:vip/services/ad_service.dart';
import 'package:vip/utils/dark_light.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({Key? key}) : super(key: key);

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  final pageController = PageController();

  int currentIndex = 0;

  bool isDark = darkMode;

  Timer? _delayAppOpenAd;

  bool reopenAppAd = false;

  void _onAppStateChanged(AppState appState) {
    debugPrint("App State $appState");
    if (appState == AppState.foreground) {
      if (reopenAppAd) {
        AdService.showAppOpenAd(
          fullScreenContentCallback: FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              reopenAppAd = false;
              setState(() {});
            },
          ),
        );
      }
      _delayAppOpenAd ??= Timer(const Duration(minutes: 3), () {
        reopenAppAd = true;
        _delayAppOpenAd = null;
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen(_onAppStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    AppStateEventNotifier.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        pageSnapping: true,
        children: [
          HomePage(onThemeChanged: (dark) => setState(() => isDark = dark)),
          const DiscoverPage(),
          const DownloadPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey[200],
        currentIndex: currentIndex,
        onTap: (index) {
          pageController.jumpToPage(index);
          setState(() => currentIndex = index);
        },
        iconSize: 24.sp,
        unselectedIconTheme: IconThemeData(
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        selectedIconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        unselectedFontSize: 12.sp,
        selectedFontSize: 12.sp,
        selectedItemColor: isDark ? Colors.white : Colors.black,
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_rounded),
            label: "Discover",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download_outlined),
            label: "Downloads"
          ),
        ],
      ),
    );
  }
}
