import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vip/utils/utils.dart';
import 'package:file_picker/file_picker.dart';

import 'models/detail_model.dart';
import 'pages/player_page/player_page.dart';
import 'utils/dark_light.dart';

class MyVideosPage extends StatefulWidget {
  const MyVideosPage({Key? key}) : super(key: key);

  @override
  State<MyVideosPage> createState() => _MyVideosPageState();
}

class _MyVideosPageState extends State<MyVideosPage> {
  final pageController = PageController();

  int currentIndex = 0;
  List<Map<String, dynamic>> files = [];

  List<Map<String, dynamic>> downloadedFiles = [];

  bool loading = true;

  Future getMP4Files(String path, {bool toDownload = false}) async {
    try {
      var dir = Directory(path);

      if (toDownload) downloadedFiles.clear();

      if (await dir.exists()) {
        List<FileSystemEntity> filesDir = dir.listSync(recursive: true);

        for (FileSystemEntity file in filesDir) {
          if (file is File && file.path.toLowerCase().endsWith('.mp4')) {
            final uint8list = await VideoThumbnail.thumbnailData(
              video: file.path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128,
              quality: 25,
            );
            if (toDownload) {
              downloadedFiles.add({
                'file': file,
                'thumbnail': uint8list,
              });
            } else {
              files.add({
                'file': file,
                'thumbnail': uint8list,
              });
            }
          }
        }
      }

      loading = false;

      update();

      return;
    } on PlatformException catch (_) {
      return;
    }
  }

  List<String> paths = [
    'Pictures',
    'Photos',
    'Video',
    'Movies',
    'Downloads',
    'Download',
    'Android/data/com.filmxy.vip/files'
  ];

  Future getFiles([List<String>? p]) async {
    var dir = '/storage/emulated/0/';
    for (var i in (p ?? paths)) {
      await getMP4Files('$dir$i/');
    }
  }

  Future init() async {
    loading = true;
    files.clear();
    update();
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      var st = await Permission.storage.request();
      if (st != PermissionStatus.granted) {
        Utils().showToast("Permission is granted!");
      } else {
        getFiles();
      }
    } else {
      getFiles();
    }
  }

  Future selectFile() async {
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.video,
    );

    if (result != null) {
      for (var i in result.files) {
        if (i.path != null) {
          var file = File(i.path!);
          final uint8list = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 128,
            quality: 25,
          );
          files.add({
            'file': file,
            'thumbnail': uint8list,
          });
        }
      }
      update();
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void update() => mounted ? setState(() {}) : () {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0
          ? AppBar(
              toolbarHeight: 40.sp,
              centerTitle: false,
              elevation: 2,
              backgroundColor:
                  darkMode ? Colors.grey.shade800 : Colors.grey[200],
              title: Padding(
                padding: EdgeInsets.only(left: 8.sp),
                child: Image.asset(
                  "assets/icons/v.png",
                  fit: BoxFit.fitHeight,
                  height: 32.sp,
                ),
              ),
              iconTheme: IconThemeData(
                color: darkMode ? Colors.white : Colors.black,
              ),
              actions: [
                IconButton(
                  onPressed: () => selectFile(),
                  icon: const Icon(Icons.add),
                ),
              ],
            )
          : null,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        pageSnapping: true,
        children: [
          buildBody(),
          buildDownload(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 24.sp,
        unselectedFontSize: 12.sp,
        selectedFontSize: 12.sp,
        selectedItemColor: darkMode ? Colors.white : Colors.black,
        unselectedItemColor: darkMode ? Colors.grey[500] : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) async {
          if (index == 1) {
            var p = ["Downloads", "Download"];
            var dir = '/storage/emulated/0/';
            for (var i in p) {
              await getMP4Files('$dir$i/', toDownload: true);
            }
          }
          pageController.jumpToPage(index);
          setState(() => currentIndex = index);
        },
        unselectedIconTheme: IconThemeData(
          color: darkMode ? Colors.grey[500] : Colors.grey[600],
        ),
        selectedIconTheme: IconThemeData(
          color: darkMode ? Colors.white : Colors.black,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: "My Videos",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_download_outlined), label: "Downloads"),
        ],
      ),
    );
  }

  Widget buildBody() => loading
      ? const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        )
      : files.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38.0),
                child: Text(
                  "No video file found! Click on plus icon to select any video.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: whiteBlack,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: files.length,
              padding: EdgeInsets.symmetric(
                vertical: 12.sp,
                horizontal: 8.sp,
              ),
              itemBuilder: (context, index) {
                final item = files[index];
                final uint8list = item['thumbnail'] as Uint8List?;
                final file = item['file'] as File;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white12,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlayerPage(
                          file: FileLink(),
                          subUrl: '',
                          type: "",
                          offline: true,
                          offlineVideoPath: file.path,
                        ),
                      ),
                    ),
                    leading: uint8list != null
                        ? Image.memory(
                            uint8list,
                            width: 100,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                          ),
                    title: Text(
                      file.path.split('/').last.replaceAll(".mp4", ""),
                      style: TextStyle(
                        color: whiteBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      file.path,
                      style: TextStyle(
                        color: whiteBlack.withOpacity(0.80),
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            );

  Widget buildDownload() => Scaffold(
        appBar: AppBar(
          title: Text(
            "Downloads",
            style: TextStyle(color: whiteBlack),
          ),
        ),
        body: downloadedFiles.isEmpty
            ? Center(
                child: Text(
                  "No downloaded video!",
                  style: TextStyle(color: whiteBlack),
                ),
              )
            : ListView.builder(
                itemCount: downloadedFiles.length,
                padding: EdgeInsets.symmetric(
                  vertical: 12.sp,
                  horizontal: 8.sp,
                ),
                itemBuilder: (context, index) {
                  final item = downloadedFiles[index];
                  final uint8list = item['thumbnail'] as Uint8List?;
                  final file = item['file'] as File;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.white12,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlayerPage(
                            file: FileLink(),
                            subUrl: '',
                            type: "",
                            offline: true,
                            offlineVideoPath: file.path,
                          ),
                        ),
                      ),
                      leading: uint8list != null
                          ? Image.memory(
                              uint8list,
                              width: 100,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.videocam_rounded,
                              color: Colors.white,
                            ),
                      title: Text(
                        file.path.split('/').last.replaceAll(".mp4", ""),
                        style: TextStyle(
                          color: whiteBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        file.path,
                        style: TextStyle(
                          color: whiteBlack.withOpacity(0.80),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
}
