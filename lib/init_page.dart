import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vip/login_page.dart';
import 'package:vip/cover_app_pages/home.dart';
import 'package:vip/pages/bottom_nav.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  Future initialize() async {
    var dir = await getExternalStorageDirectory();
    if (dir == null) {
      goCoverPage();
    } else {
      final parentDir = dir.path.split('files').first;
      File? authFile = await getAuthFile(parentDir);
      if (authFile == null) {
        goCoverPage();
      } else {
        String authData = await authFile.readAsString();
        Map<String, dynamic> data = json.decode(authData);
        token = data['token'] as String;
        if (data.containsKey('expire')) {
          String expireIn = data['expire'] as String;
          bool isExpired = DateTime.parse(expireIn).checkExpireDate(number: 10);
          if (isExpired) {
            goLogin(isExpired);
          } else {
            goHomePage();
          }
        } else {
          await Services().saveAuthFromClient(data);
          goHomePage();
        }
      }
    }
  }

  Future<File?> getAuthFile(String parentDir) async {
    File authFile = File('${parentDir}auth/auth.json');
    if (await authFile.exists()) {
      return authFile;
    } else {
      File userLoginFile = File('${parentDir}auth/user_login.json');
      if (await userLoginFile.exists()) {
        return authFile;
      } else {
        Directory dir = Directory('${parentDir}auth/');
        await dir.create(recursive: true);
        return null;
      }
    }
  }

  void goHomePage() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MyPageRoute(
          builder: (_) => const BottomNavPage(),
        ),
      );
    }
  }

  void goLogin([bool isExpired = false]) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MyPageRoute(
          builder: (_) => AuthPage(expired: isExpired),
        ),
      );
    }
  }

  void goCoverPage() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MyPageRoute(
          builder: (_) => const CoverHomePage(),
        ),
      );
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
