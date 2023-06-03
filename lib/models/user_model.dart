class UserModel {
  String username = "", expireIn = "", accessToken = "";

  UserModel({this.username = "", this.expireIn = "", this.accessToken = ""});

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    username: json["username"],
    expireIn: json["expire_in"],
    accessToken: json["access_token"],
  );

  Map<String, dynamic> toMap() => {
    "username": username,
    "expire_in": expireIn,
    "access_token": accessToken,
  };

}