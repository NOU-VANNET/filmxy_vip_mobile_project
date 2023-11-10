import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/controllers/search_controller.dart' as search;
import 'package:vip/pages/search_page/components/item_view.dart';
import 'package:vip/utils/dark_light.dart';
import 'package:vip/utils/size.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<search.SearchController>(
      init: search.SearchController(),
      autoRemove: false,
      builder: (c) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: darkLight,
          appBar: AppBar(
            titleSpacing: 0,
            backgroundColor: darkLight,
            iconTheme: IconThemeData(
              color: whiteBlack,
            ),
            title: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: darkMode ? Colors.grey.shade800 : Colors.grey.shade500,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                cursorColor: Colors.white,
                controller: c.txtEditorController,
                style: TextStyle(
                    color: Colors.white, fontSize: isMobile ? null : 7.sp),
                textAlign: TextAlign.start,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Type to search...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIconConstraints: BoxConstraints(
                    maxHeight: 24.sp,
                  ),
                  suffixIcon: InkWell(
                    onTap: () => c.clear(),
                    child:
                        const Icon(Icons.clear_rounded, color: Colors.white70),
                  ),
                ),
                onChanged: (String query) {
                  if (query.isNotEmpty) {
                    c.search(query);
                  } else {
                    c.clear();
                  }
                },
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                isMobile
                    ? 44.sp
                    : isTablet
                        ? 24.sp
                        : 20.sp,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  bottom: isMobile
                      ? 12.sp
                      : isTablet
                          ? 8.sp
                          : 6.sp,
                ),
                child: Row(
                  children: [
                    Text(
                      c.movieList.isNotEmpty
                          ? "Result: ${c.movieList.length}"
                          : "",
                      style: TextStyle(
                        color: whiteBlack,
                        fontSize: normalLabelSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: c.loading
              ? const Center(
                  heightFactor: 12,
                  child: CircularProgressIndicator(color: Colors.green),
                )
              : c.movieList.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (c.status.split(' ').first == "No")
                                  ? Icons.search_off
                                  : Icons.search,
                              color: darkMode ? Colors.white54 : Colors.black54,
                              size: isMobile ? 56.sp : 24.sp,
                            ),
                            Text(
                              c.status,
                              textAlign: TextAlign.center,
                              style: greyedTextStyle,
                            ),
                            SizedBox(height: 200.sp),
                          ],
                        ),
                      ),
                    )
                  : SafeArea(
                      child: ListView.builder(
                        itemCount: c.movieList.length,
                        shrinkWrap: true,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        itemBuilder: (context, index) =>
                            SearchItemView(movie: c.movieList[index]),
                      ),
                    ),
        ),
      ),
    );
  }
}
