import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:vip/controllers/tabs_data_controller.dart';
import 'package:vip/pages/detail_page/detail_page.dart';
import 'package:vip/pages/search_page/search_page.dart';
import 'package:vip/utils/custom_page_transition.dart';
import 'package:vip/utils/size.dart';
import 'package:vip/widgets/poster_widget.dart';
import 'package:vip/widgets/skeleton_widget.dart';

class TabBarViewData extends StatefulWidget {
  final void Function()? onDispose;
  final List<Map<String, dynamic>> tabsData;
  final int initialIndex;
  final bool showFilterOptions;
  const TabBarViewData({
    Key? key,
    this.showFilterOptions = false,
    this.onDispose,
    this.initialIndex = 0,
    required this.tabsData,
  }) : super(key: key);

  @override
  State<TabBarViewData> createState() => _TabBarViewDataState();
}

class _TabBarViewDataState extends State<TabBarViewData> {
  late int currentSelectedIndex;

  final scrollController = ScrollController();

  late AutoScrollController tabController;

  String _currentFilter = "All";

  String _currentType = "";

  Future initTabScroll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    tabController.scrollToIndex(
      currentSelectedIndex,
      duration: const Duration(milliseconds: 50),
      preferPosition: AutoScrollPosition.middle,
    );
  }

  @override
  void initState() {
    currentSelectedIndex = widget.initialIndex;
    tabController = AutoScrollController(
      axis: Axis.horizontal,
    );
    if (mounted) setState(() {});
    Get.put(TabsDataController()).initTab(
      widget.tabsData[currentSelectedIndex]["label"],
      widget.tabsData[currentSelectedIndex]["link"],
    );
    scrollController.addListener(scrollListener);
    initTabScroll();
    super.initState();
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      Get.put(TabsDataController()).nextPage();
    }
  }

  @override
  void dispose() {
    if (widget.onDispose != null) widget.onDispose!();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = width / 3;
    final h = width / 5;
    return GetBuilder<TabsDataController>(
      autoRemove: false,
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              widget.showFilterOptions &&
                      widget.tabsData[currentSelectedIndex]["label"] !=
                          "Playlist"
                  ? SizedBox(
                      width: 124,
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          bool canLoad = true;
                          String temp = "All";
                          if (value == "4k") {
                            temp = "4K Resolution";
                          } else if (value == "18plus") {
                            temp = "Adult Contents";
                          }
                          if (canLoad) {
                            setState(() {
                              _currentFilter = temp;
                            });
                            _currentType = value;
                            Get.put(TabsDataController()).initTab(
                              value.toUpperCase(),
                              widget.tabsData[currentSelectedIndex]["link"],
                              value,
                            );
                          }
                        },
                        color: Colors.grey.shade800,
                        child: Row(
                          children: [
                            Text(
                              _currentFilter,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15.sp,
                              ),
                            ),
                            const Spacer(),
                            RotatedBox(
                              quarterTurns: 1,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white70,
                                size: 22.sp,
                              ),
                            ),
                          ],
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value:
                                "${widget.tabsData[currentSelectedIndex]["link"]}",
                            child: Text(
                              "All",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 15.sp),
                            ),
                          ),
                          PopupMenuItem(
                            value: "4k",
                            child: Text(
                              "4K Resolution",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 15.sp),
                            ),
                          ),
                          PopupMenuItem(
                            value: "18plus",
                            child: Text(
                              "Adult Contents",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              SizedBox(width: 12),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(45.sp),
              child: SizedBox(
                height: 51.sp,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: tabController,
                  shrinkWrap: true,
                  children: List.generate(
                    widget.tabsData.length,
                    (index) => AutoScrollTag(
                      controller: tabController,
                      key: ValueKey(index),
                      index: index,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentSelectedIndex = index;
                              });
                              Get.put(TabsDataController()).initTab(
                                widget.tabsData[currentSelectedIndex]["label"],
                                widget.tabsData[currentSelectedIndex]["link"],
                                _currentType,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                              padding: EdgeInsets.symmetric(horizontal: 12.sp),
                            ),
                            child: Text(
                              widget.tabsData[index]["label"],
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontSize: index == currentSelectedIndex
                                    ? 16.sp
                                    : 15.sp,
                                color: index == currentSelectedIndex
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: currentSelectedIndex == index ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              color: Colors.green,
                              height: 3,
                              width: width / 4.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: Colors.transparent,
              ),
            ),
            child: ctrl.data.isNotEmpty
                ? Stack(
                    children: [
                      Scrollbar(
                        radius: const Radius.circular(4),
                        child: GridView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          itemCount: ctrl.data.length,
                          padding: EdgeInsets.only(
                            bottom: isMobile ? 34.sp : 12.sp,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 3 : 6,
                            mainAxisExtent:
                                isMobile ? (w + 56.sp) : (h + 10.sp),
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MyPageRoute(
                                builder: (builder) =>
                                    DetailPage(movie: ctrl.data[index]),
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(2.sp),
                                child: PosterWidget(
                                  posterImage: ctrl.data[index].thumbnail,
                                  adult: ctrl.data[index].isAdult,
                                  status: ctrl.data[index].status,
                                  runningEpisode:
                                      ctrl.data[index].runningEpisode,
                                  id: ctrl.data[index].postId,
                                  width: w,
                                  height: w + 56.sp,
                                  title: '',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4.sp,
                        right: 0,
                        left: 0,
                        child: ctrl.isLoadingMore
                            ? Center(
                                child: SkeletonWidget(
                                  width: width,
                                  height: 26.h,
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  )
                : ctrl.isEmptyList
                    ? Center(
                        heightFactor: 10,
                        child: Text(
                          "Not found!",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16.sp,
                          ),
                        ),
                      )
                    : const Center(
                        heightFactor: 10,
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
          ),
        );
      },
    );
  }
}
