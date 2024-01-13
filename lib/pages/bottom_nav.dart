import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/pages/discover_page/discover.dart';
import 'package:vip/pages/download_page/download.dart';
import 'package:vip/pages/home_page/home_page.dart';
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
