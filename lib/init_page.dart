import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vip/login_page.dart';
import 'package:vip/cover_app_pages/home.dart';
import 'package:vip/pages/bottom_nav.dart';
import 'package:vip/services/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  int androidSdkVersion = 0;

  Future initialize() async {
    bool isManagedExternalStorageGranted =
        await isManagedStoragePermissionIsGranted;
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
        if (await Services().canShowMovie) {
          if (map.containsKey('expire')) {
            String expireIn = map['expire'] as String;
            bool isExpired =
                DateTime.parse(expireIn).checkExpireDate(number: 10);
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
          goCoverPage();
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
          await Services().saveAuthFromClient(map);
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
        duration: const Duration(seconds: 90),
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
