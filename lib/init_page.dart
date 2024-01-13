import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/login_page.dart';
import 'package:vip/models/app_status_model.dart';
import 'package:vip/pages/bottom_nav.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:vip/utils/global_val.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  int androidSdkVersion = 0;

  Future initialize() async {
    File? authFile = await getAuthFile();
    if (authFile == null) {
      debugPrint("Auth file is not found");
      goLogin();
    } else {
      String source = await authFile.readAsString();
      Map<String, dynamic> map = json.decode(source);
      token = map['token'].toString();

      AppStatusModel? appStatus = await Services().getAppStatus;

      if (appStatus != null) {
        adFrequencyInMinute = appStatus.adFrequencyInMinute;
        Future go() async {
          if (appStatus.appDisabled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                barrierDismissible: false,
                builder: (_) => appDisableDialog,
              );
            });
          } else if (await Services().canShowMovie) {
            if (map.containsKey('expire')) {
              String expireIn = map['expire'] as String;
              bool isExpired = DateTime.parse(expireIn).checkExpireDate(number: 10);
              if (isExpired) {
                debugPrint("Auth is expired");
                goLogin(isExpired);
              } else {
                goHomePage();
              }
            } else {
              if (map['token'] != null) {
                await Services().saveAuthFromClient(map);
              }
              goHomePage();
            }
          } else {
            var parentDir = await getApplicationDocumentsDirectory();
            File f = File('${parentDir.path}/auth/auth.json');
            if (await f.exists()) {
              await f.delete();
            }
            debugPrint("Auth is delete while cannot show movie");
            goLogin(true);
          }
        }

        if (await appStatus.isUpdateNow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierColor: Colors.black87,
              barrierDismissible: false,
              builder: (_) => updateNewAppDialog(
                appStatus,
                callback: () => go(),
              ),
            );
          });
        } else {
          go();
        }
      }
    }
  }

  Future<File?> getAuthFile() async {
    var parentDir = await getApplicationDocumentsDirectory();
    File authFile = File('${parentDir.path}/auth/auth.json');

    if (await authFile.exists()) {
      debugPrint('Auth file is already exist!');
      return authFile;
    } else {
      return null;
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey.shade900,
        duration: const Duration(seconds: 5),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
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

  Widget updateNewAppDialog(
    AppStatusModel status, {
    void Function()? callback,
  }) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        title: const Text(
          "Update",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        content: const Text(
          "A new app version is available to update!",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          if (!status.appForceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                callback?.call();
              },
              child: Text(
                "May be later",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          TextButton(
            onPressed: () async {
              var uri = Uri.parse(
                  "https://filmxy.vip");
              if (await canLaunchUrl(uri)) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              "Update now",
              style: TextStyle(
                fontSize: 17,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get appDisableDialog {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        title: const Text(
          "Sorry!",
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
          ),
        ),
        content: RichText(
          text: TextSpan(
            text:
                "The app has been disabled, Please visit our official website ",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: "Filmxy.vip ",
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 17,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    var uri = Uri.parse("https://filmxy.vip");
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
              ),
              const TextSpan(
                text: "for new app.",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              "Please wait...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
