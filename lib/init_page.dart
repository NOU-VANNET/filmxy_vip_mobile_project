import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/login_page.dart';
import 'package:vip/models/cache_key_model.dart';
import 'package:vip/models/user_model.dart';
import 'package:vip/pages/bottom_nav.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/extensions.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {

  Future initialize() async {
    var db = await SharedPreferences.getInstance();
    String? data = db.getString(CacheKeyModel.userModelKey);
    if (data != null) {

      UserModel user = UserModel.fromMap(json.decode(data));
      bool isExpired = DateTime.parse(user.expireIn).checkExpireDate();

      if (isExpired) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MyPageRoute(builder: (_)=> AuthPage(expired: isExpired),),);
        }
      } else {
        token = user.accessToken;
        if (mounted) {
          Navigator.of(context).pushReplacement(MyPageRoute(builder: (_)=> const BottomNavPage(),),);
        }
      }

    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(MyPageRoute(builder: (_)=> const AuthPage(),),);
      }
    }

  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}