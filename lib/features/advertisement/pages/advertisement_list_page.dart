import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import '../widgets/dynamic_ad_scaffold.dart';
import '../controllers/advertisement_list_controller.dart';
import '../models/ad_placement.dart';
import '../widgets/advertisement_card.dart';

class AdvertisementListPage extends StatefulWidget {
  const AdvertisementListPage({super.key});

  @override
  State<AdvertisementListPage> createState() => _AdvertisementListPageState();
}

class _AdvertisementListPageState extends State<AdvertisementListPage> {
  late final AdvertisementListController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdvertisementListController>();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicAdScaffold(
      route: AppRouter.advertisementList,
      appBar: AppBar(
        title: Text(
          LK.advertisements.tr,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.advertisements.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.ticket_expired,
                  size: 56.r,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 12.h),
                Text(
                  LK.noAdvertisements.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.onRefresh,
          child: ListView.separated(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: _controller.advertisements.length +
                (_controller.isMoreLoading.value ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index >= _controller.advertisements.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final ad = _controller.advertisements[index];
              return AdvertisementCard(
                advertisement: ad,
                placement: AdPlacement.advertisementList,
                layout: AdLayout.card,
                height: 150.h,
              );
            },
          ),
        );
      }),
    );
  }
}
