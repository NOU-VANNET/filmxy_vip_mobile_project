import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:vip/login_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vip/utils/utils.dart';
import 'package:file_picker/file_picker.dart';

import 'models/detail_model.dart';
import 'pages/download_page/download.dart';
import 'pages/player_page/player_page.dart';

class MyVideosPage extends StatefulWidget {
  const MyVideosPage({Key? key}) : super(key: key);

  @override
  State<MyVideosPage> createState() => _MyVideosPageState();
}

class _MyVideosPageState extends State<MyVideosPage> {
  final pageController = PageController();

  int currentIndex = 0;
  List<Map<String, dynamic>> files = [];

  bool loading = true;

  Future getMP4Files(String path) async {
    try {
      var dir = Directory(path);

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
            files.add({
              'file': file,
              'thumbnail': uint8list,
            });
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

  Future getFiles() async {
    var dir = '/storage/emulated/0/';
    for (var i in paths) {
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
          const DownloadPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade800,
        currentIndex: currentIndex,
        onTap: (index) {
          pageController.jumpToPage(index);
          setState(() => currentIndex = index);
        },
        iconSize: 24.sp,
        unselectedIconTheme: IconThemeData(
          color: Colors.grey[500],
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
        ),
        unselectedFontSize: 12.sp,
        selectedFontSize: 12.sp,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: "My Videos",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_download_outlined), label: "Downloaded"),
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
          ? const Center(
              child: Text(
                "No video file found! Click on plus icon to select any video.",
                style: TextStyle(
                  color: Colors.white70,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      file.path,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            );
}
