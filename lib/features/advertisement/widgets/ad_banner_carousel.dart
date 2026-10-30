import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import '../controllers/advertisement_controller.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import 'advertisement_card.dart';

class AdBannerCarousel extends StatefulWidget {
  final List<Advertisement> advertisements;
  final AdPlacement placement;
  final AdLayout layout;
  final double? height;

  const AdBannerCarousel({
    super.key,
    required this.advertisements,
    this.placement = AdPlacement.homeTop,
    this.layout = AdLayout.banner,
    this.height,
  });

  @override
  State<AdBannerCarousel> createState() => _AdBannerCarouselState();
}

class _AdBannerCarouselState extends State<AdBannerCarousel>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isResumed = true;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recordCurrentImpression();
  }

  @override
  void didUpdateWidget(covariant AdBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = widget.advertisements.take(5).toList();
    if (_currentIndex >= items.length && items.isNotEmpty) {
      _currentIndex = items.length - 1;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (_isResumed != resumed) {
      setState(() {
        _isResumed = resumed;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _recordCurrentImpression() {
    final items = widget.advertisements.take(5).toList();
    if (items.isEmpty) return;
    final index = _currentIndex.clamp(0, items.length - 1);
    final ad = items[index];
    if (Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>().recordImpression(ad, widget.placement);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.advertisements.take(5).toList();
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardHeight = widget.height ?? 110.h;

    // Static banner if only 1 item: neither auto-scroll nor carousel
    if (items.length == 1) {
      return AdvertisementCard(
        key: ValueKey('ad_banner_${widget.placement.code}_${items.first.id}'),
        advertisement: items.first,
        placement: widget.placement,
        layout: widget.layout,
        height: cardHeight,
        isActive: true,
      );
    }

    // Carousel for multiple items (max 5)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: items.length,
          itemBuilder: (context, index, realIndex) {
            final ad = items[index];
            final isActive = _currentIndex == index;
            return AdvertisementCard(
              key: ValueKey('ad_banner_${widget.placement.code}_${ad.id}_$index'),
              advertisement: ad,
              placement: widget.placement,
              layout: widget.layout,
              height: cardHeight,
              isActive: isActive,
              onVideoPlaybackChanged: (isPlaying) {
                if (_isVideoPlaying != isPlaying) {
                  setState(() {
                    _isVideoPlaying = isPlaying;
                  });
                }
              },
            );
          },
          options: CarouselOptions(
            height: cardHeight,
            viewportFraction: 1.0,
            autoPlay: _isResumed && !_isVideoPlaying,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
                _isVideoPlaying = false;
              });
              _recordCurrentImpression();
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.asMap().entries.map((entry) {
            final isSelected = _currentIndex == entry.key;
            return Semantics(
              label: 'Slide ${entry.key + 1} of ${items.length}',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 18.w : 6.w,
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.r),
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
