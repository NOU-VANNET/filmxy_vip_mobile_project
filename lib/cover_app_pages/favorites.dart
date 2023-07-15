import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../models/detail_model.dart';
import '../pages/player_page/player_page.dart';
import '../utils/dark_light.dart';

class CoverFavoritesPage extends StatefulWidget {
  const CoverFavoritesPage({super.key});

  @override
  State<CoverFavoritesPage> createState() => _CoverFavoritesPageState();
}

class _CoverFavoritesPageState extends State<CoverFavoritesPage> {
  late SharedPreferences db;

  bool selecting = false;

  List<Map<String, dynamic>> _data = [];

  List<int> selectedFiles = [];

  bool cancelFetching = false;

  AudioPlayer audioPlayer = AudioPlayer();

  String currentAudioTitle = "";

  Future init() async {
    db = await SharedPreferences.getInstance();
    var src = db.getStringList('cover_favorites') ?? [];

    List<String> tempPaths = [];

    if (src.isNotEmpty) {
      for (var path in src) {
        tempPaths.add(path);
      }

      for (var path in tempPaths) {
        if (cancelFetching) break;
        var file = File(path);
        if (await file.exists()) {
          if (isVideo(path)) {
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
  }

  bool isVideo(String path) {
    return path.endsWith('.mov') ||
        path.endsWith('.mkv') ||
        path.endsWith('.mp4') ||
        path.endsWith('webm') ||
        path.endsWith('.avi');
  }

  void handleMenuSelect(String value) {
    if (value == 'select') {
      selecting = true;
      update();
    } else if (value == 'select all') {
      selecting = true;
      for (int i = 0; i < _data.length; i++) {
        selectedFiles.add(i);
      }
      update();
    }
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

  Future removeSelectedFiles() async {
    if (selectedFiles.isEmpty) return;

    cancelFetching = true;

    var db = await SharedPreferences.getInstance();

    if (selectedFiles.length == _data.length) {
      _data.clear();
      update();
    } else {
      for (int i in selectedFiles) {
        _data.removeAt(i);
        update();
      }
    }

    List<String> tempList = [];

    if (_data.isNotEmpty) {
      for (var i in _data) {
        var f = i['file'] as File;
        tempList.add(f.path);
      }
    }

    db.setStringList('cover_favorites', tempList);
    cancelFetching = false;
  }

  void reverseList() {
    _data = _data.reversed.toList();
    update();
  }

  void closeSelecting() {
    selectedFiles.clear();
    selecting = false;
    update();
  }

  void update() => mounted ? setState(() {}) : () {};

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var normalActions = [
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
        onPressed: () => removeSelectedFiles(),
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
      appBar: AppBar(
        actions: selecting ? selectingActions : normalActions,
      ),
      body: _data.isEmpty
          ? Center(
              child: Text(
                "No favorite added!",
                style: TextStyle(
                  color: darkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            )
          : GridView.builder(
              itemCount: _data.length,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 162,
              ),
              itemBuilder: (context, index) {
                var item = _data[index];
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
                      var path = item['file'].path as String;
                      if (!isVideo(path)) {
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
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey[700] : Colors.transparent,
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
                                Icons.audio_file,
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
                );
              },
            ),
      bottomNavigationBar: currentAudioTitle != ""
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
    );
  }
}
