import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

AppStatusModel appStatusModelFromMap(String str) => AppStatusModel.fromMap(json.decode(str));

String appStatusModelToMap(AppStatusModel data) => json.encode(data.toMap());

class AppStatusModel {
  String status;
  String appVersion;
  bool appForceUpdate;
  bool appDisabled;
  bool admobDisabled;
  String admobFrequency;
  String apiVersion;

  AppStatusModel({
    this.status = '',
    this.appVersion = '',
    this.appForceUpdate = true,
    this.appDisabled = false,
    this.admobDisabled = false,
    this.admobFrequency = '',
    this.apiVersion = '',
  });

  Future<bool> get isUpdateNow async {
    var info = await PackageInfo.fromPlatform();
    String currentAppVersion = info.version;
    String storeAppVersion = appVersion;
    int currentVersion = int.parse(currentAppVersion.replaceAll(".", ""));
    int storeVersion = int.parse(storeAppVersion.replaceAll(".", ""));
    return storeVersion > currentVersion;
  }

  factory AppStatusModel.fromMap(Map<String, dynamic> json) => AppStatusModel(
    status: json["status"] ?? '',
    appVersion: json["app_version"] ?? '',
    appForceUpdate: json["app_force_update"] ?? true,
    appDisabled: json["app_disabled"] ?? false,
    admobDisabled: json["admob_disabled"] ?? false,
    admobFrequency: json["admob_frequency"] ?? '',
    apiVersion: json["api_version"] ?? '',
  );

  Map<String, dynamic> toMap() => {
    "status": status,
    "app_version": appVersion,
    "app_force_update": appForceUpdate,
    "app_disabled": appDisabled,
    "admob_disabled": admobDisabled,
    "admob_frequency": admobFrequency,
    "api_version": apiVersion,
  };
}
