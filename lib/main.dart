import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/init_page.dart';
import 'package:vip/pages/detail_page/detail_page.dart';
import 'package:vip/services/ad_service.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await SharedPreferences.getInstance();
  darkMode = db.getBool('dark_mode') ?? true;

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: darkLight,
      statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: darkLight,
    ),
  );

  await FlutterDownloader.initialize(ignoreSsl: true);

  await AdService.initialize(testMode: true);

  readDetailCache();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ScreenUtilInit(
        designSize: const Size(360, 767),
        builder: (context, _) {
          return GetMaterialApp(
            title: 'Monkey Player',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.red,
              scaffoldBackgroundColor: darkLight,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: UpwardPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  }),
            ),
            home: const InitPage(),
          );
        });
  }
}