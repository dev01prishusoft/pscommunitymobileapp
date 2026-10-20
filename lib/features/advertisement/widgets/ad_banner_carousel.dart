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
  final double? height;

  const AdBannerCarousel({
    super.key,
    required this.advertisements,
    this.placement = AdPlacement.homeTop,
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
    if (widget.advertisements.isEmpty) return;
    final index = _currentIndex.clamp(0, widget.advertisements.length - 1);
    final ad = widget.advertisements[index];
    if (Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>().recordImpression(ad, widget.placement);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advertisements.isEmpty) {
      return const SizedBox.shrink();
    }

    final cardHeight = widget.height ?? 130.h;

    // Static banner if only 1 item
    if (widget.advertisements.length == 1) {
      return AdvertisementCard(
        advertisement: widget.advertisements.first,
        placement: widget.placement,
        layout: AdLayout.banner,
        height: cardHeight,
      );
    }

    // Carousel for multiple items
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: widget.advertisements.length,
          itemBuilder: (context, index, realIndex) {
            final ad = widget.advertisements[index];
            return AdvertisementCard(
              advertisement: ad,
              placement: widget.placement,
              layout: AdLayout.banner,
              height: cardHeight,
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
          children: widget.advertisements.asMap().entries.map((entry) {
            final isSelected = _currentIndex == entry.key;
            return Semantics(
              label: 'Slide ${entry.key + 1} of ${widget.advertisements.length}',
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
