// To parse this JSON data, do
//
//     final routeMap = routeMapFromMap(jsonString);

import 'dart:convert';

NotificationModel notificationFromMap(String str) => NotificationModel.fromMap(json.decode(str));

String notificationToMap(NotificationModel data) => json.encode(data.toMap());

class NotificationModel {
  NotificationModel({
    this.route = "",
    required this.movie,
    this.image = "",
    this.createdAt = "",
    required this.title,
    required this.body,
  });

  String route = "",
      image = "",
      title = "",
      body = "",
      createdAt = "";
  Map<String, dynamic> movie = {};

  factory NotificationModel.fromMap(Map<String, dynamic> json) => NotificationModel(
        route: json["route"],
        movie: json["item"],
        image: json["image"],
        title: json["title"],
        body: json["body"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toMap() => {
        "route": route,
        "item": movie,
        "image": image,
        "title": title,
        "body": body,
        "created_at": createdAt,
      };
}
