import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/cover_app_pages/home.dart';
import 'package:vip/models/cache_key_model.dart';
import 'package:vip/models/user_model.dart';
import 'package:vip/pages/bottom_nav.dart';
import 'package:vip/register_page.dart';
import 'package:vip/services/services.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vip/utils/utils.dart';

class AuthPage extends StatefulWidget {
  final bool expired;
  const AuthPage({Key? key, this.expired = false}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final loginEditor = TextEditingController();
  final passwordEditor = TextEditingController();

  bool textObscure = true;

  bool isLogging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 40.sp,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(isMobile ? 80.sp : 50.sp),
            child: Image.asset(
              "assets/icons/v.png",
              fit: BoxFit.fitHeight,
              height: isMobile ? 80.sp : 50.sp,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isMobile ? (height / 16) : 30.sp, width: width),
              Text(
                "Member Login",
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: isMobile ? 24.sp : 20.sp,
                  color: whiteBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 30.sp : 25.sp),
              if (widget.expired)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12.sp : width / 1.5,
                  ),
                  child: Text(
                    " The session is expired! Please log in with your account again.",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              if (widget.expired) SizedBox(height: isMobile ? 14.sp : 10.sp),
              buildTextField(
                loginEditor,
                "Email or Username",
                Icons.person,
                type: TextInputType.emailAddress,
              ),
              SizedBox(height: isMobile ? 12.sp : 10.sp),
              buildTextField(
                passwordEditor,
                "Password",
                Icons.lock_rounded,
                secure: textObscure,
                suffixIcon: InkWell(
                  onTap: () => setState(() => textObscure = !textObscure),
                  child: Icon(
                    textObscure
                        ? Icons.remove_red_eye_outlined
                        : Icons.remove_red_eye,
                    size: normalIconSize,
                    color: Colors.white54,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 12.sp : 10.sp),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isLogging ? 120.sp : (width / 1.8),
                height: 40.sp,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: EdgeInsets.all(8.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () => login(),
                  child: isLogging
                      ? SizedBox(
                          width: 24.sp,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 16.sp : 14.sp,
                          ),
                        ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 24.sp, top: 12.sp),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => RegisterPage(
                          callback: (email, pw) async {
                            if (email.isNotEmpty && pw.isNotEmpty) {
                              loginEditor.text = email;
                              passwordEditor.text = pw;
                              setState(() {});
                              await Future.delayed(
                                  const Duration(milliseconds: 100));
                              login();
                            }
                          },
                        ),
                      ),
                    ),
                    child: Text(
                      "Create an account",
                      style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.g_mobiledata_rounded,
                        color: Colors.black,
                        size: 36,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    Widget? suffixIcon,
    bool secure = false,
    TextInputType? type,
  }) {
    return Container(
      height: isMobile ? 48.sp : 34.sp,
      width: isMobile ? width / 1.1 : width / 1.5,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 6.sp),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        cursorColor: Colors.white,
        style: TextStyle(
          fontSize: isMobile ? 15.sp : 13.sp,
          color: Colors.white,
        ),
        obscureText: secure,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: normalIconSize, color: Colors.white70),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: isMobile ? 15.sp : 13.sp,
            color: Colors.grey[500],
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future login() async {
    if (isLogging) return;
    setState(() => isLogging = true);
    Map<String, dynamic> result = await Services().serverLogin(
      loginEditor.text,
      passwordEditor.text,
    );

    if (result['code'] == "success") {
      final map = json.decode(result["data"]);
      UserModel user = UserModel(
        username: map["user_name"],
        expireIn: DateTime.now().toString(),
        accessToken: map["token"],
      );

      var db = await SharedPreferences.getInstance();
      await db.setString(CacheKeyModel.userModelKey, json.encode(user.toMap()));

      token = user.accessToken;

      bool canShowMovie = await Services().canShowMovie;

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MyPageRoute(
            builder: (_) =>
                canShowMovie ? const BottomNavPage() : const CoverHomePage(),
          ),
          (route) => false,
        );
      }
      Services().saveAuthFromClient(map);
    } else {
      setState(() => isLogging = false);
      Utils().showToast(Utils.stripHtmlIfNeeded(result["message"]));
    }
  }

  Future signInWithGoogle() async {
    try {
      if (isLogging) return;
      Utils().showToast("Please wait...");
      var googleSignIn = GoogleSignIn();
      GoogleSignInAccount? credential = await googleSignIn.signIn();
      if (credential != null) {
        GoogleSignInAuthentication? authResult = await credential.authentication;
        var accessToken = authResult.accessToken;
        if (accessToken != null) {
          var map = await Services().googleSignIn(
            accessToken,
            email: credential.email,
            displayName: credential.displayName,
          );
          if (map != null) {
            String? authToken = map["token"] as String?;

            if (authToken == null) {
              Utils().showToast("Authentication failed! please try again.");
              return;
            }

            setState(() => isLogging = true);
            UserModel user = UserModel(
              username: map["user_name"] ?? "",
              expireIn: DateTime.now().toString(),
              accessToken: authToken,
            );

            var db = await SharedPreferences.getInstance();
            await db.setString(CacheKeyModel.userModelKey, json.encode(user.toMap()));

            token = user.accessToken;

            bool canShowMovie = await Services().canShowMovie;

            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MyPageRoute(
                  builder: (_) =>
                  canShowMovie ? const BottomNavPage() : const CoverHomePage(),
                ),
                    (route) => false,
              );
            }
            Services().saveAuthFromClient(map);
          }
        } else {
          setState(() => isLogging = false);
          Utils().showToast("Authentication failed! please try again.");
        }
      } else {
        setState(() => isLogging = false);
        Utils().showToast("Error couldn't sign in at this time!");
      }
    } on PlatformException catch (e) {
      setState(() => isLogging = false);
      Utils().showToast("Error! ${e.message}");
    }
  }
}
