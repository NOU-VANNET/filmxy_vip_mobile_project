import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:vip/cover_app_pages/components/drawer.dart';
import 'package:vip/cover_app_pages/components/input_field.dart';
import 'package:vip/cover_app_pages/utils.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:path_provider/path_provider.dart';

import '../models/detail_model.dart';
import '../pages/player_page/player_page.dart';
import '../utils/utils.dart';

class CoverHomePage extends StatefulWidget {
  const CoverHomePage({super.key});

  @override
  State<CoverHomePage> createState() => _CoverHomePageState();
}

class _CoverHomePageState extends State<CoverHomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _data = [];

  List<Map<String, dynamic>> _searched = [];

  List<int> selectedFiles = [];

  bool selecting = false;
  bool fetching = true;
  bool searching = false;

  bool isAudioMode = false;

  bool cancelGettingPreviousFiles = false;

  AudioPlayer audioPlayer = AudioPlayer();

  String currentAudioTitle = "";

  Future searchMedia(String query) async {
    if (_data.isNotEmpty) {
      searching = true;
      _searched.clear();
      update();
      var result = _data
          .where((e) => e['file']
              .path
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      if (result.isNotEmpty) {
        _searched = result;
      }
      update();
      Future.delayed(
        const Duration(milliseconds: 1000),
        () {
          searching = false;
          update();
        },
      );
    }
  }

  Future getFiles(String path, {String extension = 'mp4'}) async {
    try {
      var dir = Directory(path);

      if (await dir.exists()) {
        List<FileSystemEntity> filesDir = dir.listSync(recursive: true);

        for (FileSystemEntity file in filesDir) {
          if (cancelGettingPreviousFiles) {
            cancelGettingPreviousFiles = false;
            break;
          }
          if (file is File && file.path.toLowerCase().endsWith('.$extension')) {
            if (!isAudioMode) {
              final uint8list = await VideoThumbnail.thumbnailData(
                video: file.path,
                imageFormat: ImageFormat.JPEG,
                maxWidth: 240,
                quality: 24,
              );
              _data.add({
                'file': file,
                'thumbnail': uint8list,
              });
              update();
            } else {
              _data.add({
                'file': file,
                'thumbnail': null,
              });
              update();
            }
          }
        }
      }

      fetching = false;

      update();

      return;
    } on PlatformException catch (_) {
      return;
    }
  }

  Future<File> getAssetFile(String assetPath) async {
    ByteData assetData = await rootBundle.load(assetPath);
    List<int> bytes = assetData.buffer.asUint8List();

    String docPath = (await getApplicationDocumentsDirectory()).path;
    String fileName = assetPath.split('/').last;
    File file = File('$docPath/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future getAllVideoFiles() async {
    _data.clear();
    update();
    var dir = '/storage/emulated/0/';
    final videoExt = ['mp4', 'webm', 'mov', 'avi', 'mkv'];
    for (var ext in videoExt) {
      for (var i in filePaths) {
        await getFiles('$dir$i/', extension: ext);
      }
    }
    if (_data.isEmpty) {
      String docPath = (await getApplicationDocumentsDirectory()).path;
      File file = File('$docPath/Big Buck Bunny 10s.mp4');
      if (await file.exists()) {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 360,
          quality: 42,
        );
        _data.add({
          'file': file,
          'thumbnail': uint8list,
        });
        update();
      } else {
        final f = await getAssetFile('assets/files/Big Buck Bunny 10s.mp4');
        final uint8list = await VideoThumbnail.thumbnailData(
          video: f.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 360,
          quality: 42,
        );
        _data.add({
          'file': f,
          'thumbnail': uint8list,
        });
        update();
      }
    }
  }

  Future getAllAudioFiles() async {
    _data.clear();
    update();
    var dir = '/storage/emulated/0/';
    final audioExt = ['mp3', 'wav', 'ogg'];
    for (var ext in audioExt) {
      for (var i in filePaths) {
        await getFiles('$dir$i/', extension: ext);
      }
    }

    if (_data.isEmpty) {
      String docPath = (await getApplicationDocumentsDirectory()).path;
      File file = File('$docPath/Rington.mp3');
      if (await file.exists()) {
        _data.add({
          'file': file,
          'thumbnail': null,
        });
        update();
      } else {
        final f = await getAssetFile('assets/files/Rington.mp3');
        _data.add({
          'file': f,
          'thumbnail': null,
        });
        update();
      }
    }
  }

  void reverseList() {
    if (_searched.isNotEmpty) {
      _searched = _searched.reversed.toList();
    } else {
      _data = _data.reversed.toList();
    }
    update();
  }

  Future selectFiles() async {
    var extension = isAudioMode ? FileType.audio : FileType.video;
    var result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: extension,
    );

    if (result != null) {
      for (var i in result.files) {
        if (i.path != null) {
          var file = File(i.path!);
          if (extension == FileType.video) {
            final uint8list = await VideoThumbnail.thumbnailData(
              video: file.path,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128,
              quality: 25,
            );
            var obj = {
              'file': file,
              'thumbnail': uint8list,
            };
            _data = [obj, ..._data];
            update();
          } else {
            var obj = {
              'file': file,
              'thumbnail': null,
            };
            _data = [obj, ..._data];
            update();
          }
        }
      }
    }
  }

  Future init() async {
    fetching = true;
    _data.clear();
    update();
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      var st = await Permission.storage.request();
      if (st != PermissionStatus.granted) {
        Utils().showToast("Permission is granted!");
      } else {
        if (isAudioMode) {
          getAllAudioFiles();
        } else {
          getAllVideoFiles();
        }
      }
    } else {
      if (isAudioMode) {
        getAllAudioFiles();
      } else {
        getAllVideoFiles();
      }
    }
  }

  void update() => mounted ? setState(() {}) : () {};

  @override
  void initState() {
    init();
    super.initState();
  }

  final _moreMenu = [
    PopupMenuItem(
      value: 'select',
      child: Row(
        children: const [
          Icon(
            Icons.done,
            color: Colors.black,
          ),
          SizedBox(width: 4),
          Text("Select"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'select all',
      child: Row(
        children: const [
          Icon(
            Icons.done_all,
            color: Colors.black,
          ),
          SizedBox(width: 4),
          Text("Select all"),
        ],
      ),
    ),
  ];

  void handleMenuSelect(String value) {
    if (value == 'select') {
      selecting = true;
      update();
    } else if (value == 'select all') {
      selecting = true;
      for (int i = 0;
          i < (_searched.isNotEmpty ? _searched.length : _data.length);
          i++) {
        selectedFiles.add(i);
      }
      update();
    }
  }

  Future addToFavorites() async {
    if (selectedFiles.isEmpty) return;
    var db = await SharedPreferences.getInstance();
    var oldList = db.getStringList('cover_favorites') ?? [];
    for (var i in selectedFiles) {
      var file = _data[i]['file'] as File;
      oldList.add(file.path);
    }
    await db.setStringList('cover_favorites', oldList);
    Utils().showToast('Added to favorites!');
    closeSelecting();
  }

  Future deleteSelectedFiles() async {
    if (selectedFiles.isEmpty) return;
    Get.dialog(
      AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(
              color: Colors.green,
            ),
            SizedBox(width: 6),
            Text("Deleting..."),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    for (int i in selectedFiles) {
      var file = _data[i]['file'] as File;
      if (await file.exists()) {
        await file.delete();
        _data.removeAt(i);
        update();
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    Get.back();
    closeSelecting();
  }

  void closeSelecting() {
    selectedFiles.clear();
    selecting = false;
    update();
  }

  @override
  Widget build(BuildContext context) {
    var normalActions = [
      IconButton(
        onPressed: () => init(),
        icon: fetching
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(
                Icons.refresh,
                color: darkMode ? Colors.white : Colors.black,
              ),
      ),
      IconButton(
        onPressed: () => reverseList(),
        icon: Icon(
          Icons.sort,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
      PopupMenuButton<String>(
        itemBuilder: (context) => _moreMenu,
        onSelected: handleMenuSelect,
        child: Icon(
          Icons.more_vert_outlined,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
      const SizedBox(width: 12),
    ];

    var selectingActions = [
      IconButton(
        onPressed: () => addToFavorites(),
        icon: Icon(
          Icons.favorite,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
      IconButton(
        onPressed: () => deleteSelectedFiles(),
        icon: Icon(
          Icons.delete,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
      IconButton(
        onPressed: () => closeSelecting(),
        icon: Icon(
          Icons.close,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
    ];

    return Scaffold(
      extendBody: true,
      key: scaffoldKey,
      drawer: Drawer(
        backgroundColor: darkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        width: context.width / 2,
        child: CoverDrawerWidget(
          currentMediaType:
              isAudioMode ? CoverMediaType.audio : CoverMediaType.video,
          onChangeMediaType: (type) async {
            _searched.clear();
            isAudioMode = type == CoverMediaType.audio;
            cancelGettingPreviousFiles = true;
            await Future.delayed(const Duration(milliseconds: 50));
            _data.clear();
            update();
            scaffoldKey.currentState?.closeDrawer();
            await Future.delayed(const Duration(milliseconds: 50));
            cancelGettingPreviousFiles = false;
            _data.clear();
            update();
            if (isAudioMode) {
              getAllAudioFiles();
            } else {
              getAllVideoFiles();
            }
          },
        ),
      ),
      appBar: AppBar(
        actions: selecting ? selectingActions : normalActions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: CoverInputField(
            searching: searching,
            onChanged: (value) => searchMedia(value),
          ),
        ),
      ),
      body: _data.isEmpty
          ? Center(
              child: !fetching
                  ? Text(
                      "No ${isAudioMode ? 'audio' : 'video'} file found in your phone!",
                      style: TextStyle(
                        color: darkMode ? Colors.white70 : Colors.black87,
                      ),
                    )
                  : const CircularProgressIndicator(
                      color: Colors.green,
                    ),
            )
          : GridView.builder(
              itemCount: _searched.isNotEmpty ? _searched.length : _data.length,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 162,
              ),
              itemBuilder: (context, index) {
                var item =
                    _searched.isNotEmpty ? _searched[index] : _data[index];
                var isSelected =
                    selectedFiles.where((e) => e == index).toList().isNotEmpty;
                return InkWell(
                  onLongPress: () {
                    handleMenuSelect('select');
                    selectedFiles.add(index);
                    update();
                  },
                  onTap: () async {
                    if (selecting) {
                      if (isSelected) {
                        selectedFiles.remove(index);
                      } else {
                        selectedFiles.add(index);
                      }
                      update();
                    } else {
                      if (isAudioMode) {
                        var path = item['file'].path as String;
                        currentAudioTitle = path.split('/').last;
                        await audioPlayer.play(DeviceFileSource(path));
                        update();
                      } else {
                        audioPlayer.stop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlayerPage(
                              file: FileLink(),
                              subUrl: '',
                              type: "",
                              offline: true,
                              offlineVideoPath: item['file'].path,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Center(
                    child: Container(
                      width: context.width,
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.grey[700] : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: item['thumbnail'] == null
                            ? MainAxisAlignment.spaceEvenly
                            : MainAxisAlignment.center,
                        children: [
                          item['thumbnail'] == null
                              ? const Icon(
                                  Icons.audiotrack,
                                  size: 38,
                                  color: Colors.white54,
                                )
                              : Image.memory(
                                  item['thumbnail'],
                                  fit: BoxFit.cover,
                                  height: 120,
                                ),
                          const SizedBox(height: 2),
                          Text(
                            item['file'].path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: darkMode ? Colors.white70 : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: currentAudioTitle != ''
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.audiotrack,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: context.width / 2.2,
                      child: Text(
                        currentAudioTitle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        if (audioPlayer.state == PlayerState.playing) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.resume();
                        }
                        update();
                      },
                      icon: Icon(
                        audioPlayer.state == PlayerState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await audioPlayer.stop();
                        currentAudioTitle = '';
                        update();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: selecting
          ? null
          : FloatingActionButton(
              onPressed: () => selectFiles(),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
    );
  }
}
