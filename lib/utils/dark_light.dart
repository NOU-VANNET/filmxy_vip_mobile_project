import 'package:flutter/material.dart';

bool darkMode = false;

Color get darkLight => darkMode ? Colors.grey.shade900 : Colors.grey.shade200;

Color get whiteBlack => darkMode ? Colors.white : Colors.black;