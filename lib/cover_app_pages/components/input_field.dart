import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vip/utils/dark_light.dart';

class CoverInputField extends StatelessWidget {
  const CoverInputField({
    super.key,
    this.onChanged,
    this.controller,
    this.searching = false,
  });

  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      width: context.width,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: darkMode ? Colors.grey[800] : Colors.grey[300],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: Colors.white,
        style: TextStyle(
          color: darkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: darkMode ? Colors.white70 : Colors.black87,
          ),
          suffixIconConstraints: const BoxConstraints(
            maxHeight: 24,
            maxWidth: 24,
          ),
          suffixIcon: searching
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 2.5,
                  ),
                )
              : null,
          border: InputBorder.none,
          hintText: "Search",
          hintStyle: TextStyle(
            color: darkMode ? Colors.white54 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
