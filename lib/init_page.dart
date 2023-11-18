import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/controllers/ad_controller.dart';
import 'package:vip/login_page.dart';
import 'package:vip/cover_app_pages/home.dart';
import 'package:vip/models/app_status_model.dart';
import 'package:vip/pages/bottom_nav.dart';
import 'package:vip/services/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
    bool isManagedExternalStorageGranted = await isManagedStoragePermissionIsGranted;
    bool isStorageGranted = await isStoragePermissionIsGranted;
    if (isManagedExternalStorageGranted && isStorageGranted) {
      File? authFile = await getAuthFile();
      if (authFile == null) {
        goCoverPage();
      } else {
        String source = await authFile.readAsString().catchError((e) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (androidSdkVersion >= 30) {
              showSnackBar(
                  "Please allow storage management permission in settings! and restart the app again.");
            } else {
              showSnackBar("");
            }
          });
          return "{}";
        });
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
    } else {
      goCoverPage();
    }
  }

  Future<bool> get isManagedStoragePermissionIsGranted async {
    DeviceInfoPlugin device = DeviceInfoPlugin();
    final androidInfo = await device.androidInfo;
    int sdkVersion = androidInfo.version.sdkInt;
    androidSdkVersion = sdkVersion;
    if (sdkVersion < 30) {
      return true;
    } else {
      final status = await Permission.manageExternalStorage.status;
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        var requestStatus = await Permission.storage.request();
        return requestStatus == PermissionStatus.granted;
      }
    }
  }

  Future<bool> get isStoragePermissionIsGranted async {
    final status = await Permission.storage.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      var requestStatus = await Permission.storage.request();
      return requestStatus == PermissionStatus.granted;
    }
  }

  Future<File?> getAuthFile() async {
    var parentDir = await getApplicationDocumentsDirectory();

    File authFile = File('${parentDir.path}/auth/auth.json');

    if (await authFile.exists()) {
      debugPrint('Auth file is already exist!');
      return authFile;
    } else {
      Directory dir = Directory('${parentDir.path}/auth/');
      await dir.create(recursive: true);
      var foundedAuthFile = await findAuthJsonFileOutsideAppDirectory();
      if (foundedAuthFile != null) {
        final source = await foundedAuthFile.readAsString().catchError((e) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (androidSdkVersion >= 30) {
              showSnackBar(
                  "Please allow storage management permission in settings! and restart the app again.");
            } else {
              showSnackBar("");
            }
          });
          return "{}";
        });
        Map<String, dynamic> map = json.decode(source) as Map<String, dynamic>;
        if (map['token'] != null) {
          return await Services().saveAuthFromClient(map);
        }
        return foundedAuthFile;
      } else {
        return null;
      }
    }
  }

  List<Directory> listFirstLevelSubDirectories(Directory directory) {
    List<Directory> firstLevelSubDirectories = [];

    void listDirectoriesRecursively(Directory dir, int depth) {
      if (depth > 1) {
        return;
      }

      List<FileSystemEntity> entities = dir.listSync();

      for (var entity in entities) {
        if (entity is Directory) {
          firstLevelSubDirectories.add(entity);
          listDirectoriesRecursively(entity, depth + 1);
        }
      }
    }

    listDirectoriesRecursively(directory, 0);

    return firstLevelSubDirectories;
  }

  Future<File?> findAuthJsonFileOutsideAppDirectory() async {
    File? tempFile;
    Directory? extDir = await getExternalStorageDirectory();
    String extPath = extDir != null
        ? "${extDir.path.split('/0/').first}/0/"
        : "/storage/emulated/0/";
    Directory externalDir = Directory(extPath);
    List<Directory> firstLevelSubDirectories =
        listFirstLevelSubDirectories(externalDir);
    firstLevelSubDirectories.add(externalDir);

    for (int i = 0; i < firstLevelSubDirectories.length; i++) {
      firstLevelSubDirectories
          .removeWhere((e) => e.path.contains("/emulated/0/Android"));
    }

    List<File> foundedFiles = [];

    for (Directory dir in firstLevelSubDirectories) {
      var authJson = File('${dir.path}/auth.json');
      var userLoginJson = File('${dir.path}/user_login.json');
      var authTxt = File('${dir.path}/auth.txt');
      var userLoginTxt = File('${dir.path}/user_login.txt');
      if (await authJson.exists()) {
        foundedFiles.add(authJson);
      }
      if (await userLoginJson.exists()) {
        foundedFiles.add(userLoginJson);
      }
      if (await authTxt.exists()) {
        foundedFiles.add(authTxt);
      }
      if (await userLoginTxt.exists()) {
        foundedFiles.add(userLoginTxt);
      }
    }

    if (foundedFiles.length > 1) {
      for (File file in foundedFiles) {
        try {
          var source = await file.readAsString();
          Map<String, dynamic> map =
              json.decode(source) as Map<String, dynamic>;
          if (map.containsKey('token')) {
            tempFile = file;
            break;
          }
        } on PlatformException catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            if (androidSdkVersion >= 30) {
              showSnackBar(
                  "Please allow storage management permission in settings! and restart the app again.");
            } else {
              showSnackBar(e.message.toString());
            }
          });
        }
      }
    } else if (foundedFiles.length == 1) {
      tempFile = foundedFiles.first;
    }

    return tempFile;
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

  void goCoverPage() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MyPageRoute(
          builder: (_) => const CoverHomePage(),
        ),
      );
    }
  }

  Widget updateNewAppDialog(AppStatusModel status,
      {void Function()? callback}) {
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
                  "https://play.google.com/store/apps/details?id=cc.playerapi.monkey_player");
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

  Future initStateOnStart() async {
    await initialize();
    Get.put(AdsController()).initializeFirstAd();
  }

  @override
  void initState() {
    initStateOnStart();
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
