import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:vip/utils/utils.dart';

class DownloadController extends GetxController {

  final ReceivePort _port = ReceivePort();

  bool _isExpand = true;
  bool get isExpand => _isExpand;

  List<Map> _downloadListMaps = [];
  List<Map> get downloadListMaps => _downloadListMaps;

  static const String _portName = 'downloader_send_port_vip';

  Future init() async {
    await loadTask();
    bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName(_portName);
    send!.send([id, status, progress]);
  }

  void unbindBackgroundIsolate() => IsolateNameServer.removePortNameMapping(_portName);

  void bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      var task = _downloadListMaps.where((element) => element['id'] == id);
      for (var element in task) {
        element['progress'] = progress;
        element['status'] = status;
        update();
      }
      update();
    });
  }

  Future loadTask() async {
    _downloadListMaps = await _getItemList();
    update();
  }

  Future<List<Map<dynamic, dynamic>>> _getItemList() async {
    List<DownloadTask> getTasks = await FlutterDownloader.loadTasks() ?? [];
    List<Map> mapList = [];
    for (var task in getTasks) {
      Map map = {
        'status': task.status,
        'progress': task.progress,
        'id': task.taskId,
        'filename': task.filename,
        'savedDirectory': task.savedDir,
      };
      mapList.add(map);
    }
    return mapList;
  }

  List<Map> get downloadedList {
    final downloaded = _downloadListMaps.where((element) => element['status'] == DownloadTaskStatus.complete).toList();
    if (downloaded.isNotEmpty) {
      return downloaded;
    } else {
      return [];
    }
  }

  List<Map> get downloadingList {
    final downloading = _downloadListMaps.where((element) => element['status'] != DownloadTaskStatus.complete).toList();
    if (downloading.isNotEmpty) {
      return downloading;
    } else {
      return [];
    }
  }

  void expandCollapse({bool isDownload = false}) {
    _isExpand = !_isExpand;
    update();
  }

  Future removeItem(int index, String taskId, bool withContent) async {
    _downloadListMaps.removeAt(index);
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: withContent);
    loadTask();
    update();
    Utils().showToast('Deleted');
  }

  ///Give filename parameter to check specific file from storage and remove it.
  Future<bool> checkAndRemoveDownloadItems({String? path}) async {
    if (path != null) {
      bool exist = await File(path).exists();

      if (!exist) {

        final filename = path.split("/").last;
        final downloadItem = _downloadListMaps.firstWhereOrNull((e) => e['filename'] == filename);

        if (downloadItem != null) {
          await FlutterDownloader.remove(taskId: downloadItem["id"], shouldDeleteContent: false);
          update();
        }

      }

      return exist;
    } else {
      bool e = false;
      for (int i = 0; i < _downloadListMaps.length; i++) {
        bool exist = await File("${_downloadListMaps[i]["savedDirectory"]}${_downloadListMaps[i]["filename"]}").exists();
        e = exist;
        if (!exist) {
          await FlutterDownloader.remove(taskId: _downloadListMaps[i]["id"], shouldDeleteContent: false);
          update();
        }

      }

      return e;
    }
  }

  Future pauseResumeRetryItem(String taskId, DownloadTaskStatus status) async {
    if (status == DownloadTaskStatus.running) {
      await FlutterDownloader.pause(taskId: taskId);
      loadTask();
    } else if (status == DownloadTaskStatus.paused) {
      await FlutterDownloader.resume(taskId: taskId);
      loadTask();
    } else if (status == DownloadTaskStatus.failed) {
      await FlutterDownloader.retry(taskId: taskId);
      loadTask();
    }
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

}
