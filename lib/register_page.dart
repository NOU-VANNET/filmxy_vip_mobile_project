import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vip/services/services.dart';

import 'utils/size.dart';
import 'utils/utils.dart';

class RegisterPage extends StatefulWidget {
  final void Function(String login, String pw)? callback;
  const RegisterPage({Key? key, this.callback}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var emailCtrl = TextEditingController();
  var usernameCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  var inviteCodeCtrl = TextEditingController();

  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create an account",
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTextField(
              usernameCtrl,
              "Username",
              Icons.person,
            ),
            const SizedBox(height: 8),
            buildTextField(
              emailCtrl,
              "Email",
              Icons.email,
            ),
            const SizedBox(height: 8),
            buildTextField(
              passwordCtrl,
              "Password",
              Icons.lock,
            ),
            const SizedBox(height: 8),
            buildTextField(
              inviteCodeCtrl,
              "Invite Code (Optional)",
              Icons.confirmation_number,
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isRegistering ? 120.sp : (width / 1.8),
              height: 40.sp,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.all(8.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => register(),
                child: isRegistering
                    ? SizedBox(
                        width: 24.sp,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16.sp : 14.sp,
                        ),
                      ),
              ),
            ),
          ],
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

  Future register() async {
    if (isRegistering) return;
    setState(() => isRegistering = true);
    var result = await Services().serverRegister(
      usernameCtrl.text,
      emailCtrl.text,
      passwordCtrl.text,
      inviteCodeCtrl.text,
    );
    if (result['code'] == 'success') {
      widget.callback?.call(usernameCtrl.text, passwordCtrl.text);
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() => isRegistering = false);
      Utils().showToast(Utils.stripHtmlIfNeeded(result["message"]));
    }
  }
}
