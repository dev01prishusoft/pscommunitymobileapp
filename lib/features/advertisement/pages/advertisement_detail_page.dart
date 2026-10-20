import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import '../controllers/advertisement_controller.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import '../widgets/ad_fullscreen_media_viewer.dart';
import '../widgets/ad_video_player_widget.dart';
import '../widgets/sponsored_label.dart';

class AdvertisementDetailPage extends StatefulWidget {
  const AdvertisementDetailPage({super.key});

  @override
  State<AdvertisementDetailPage> createState() =>
      _AdvertisementDetailPageState();
}

class _AdvertisementDetailPageState extends State<AdvertisementDetailPage> {
  late final AdvertisementController _controller;
  Advertisement? _advertisement;
  bool _isLoading = true;
  bool _isUnavailable = false;
  bool _isVideoPlaying = false;
  bool _isEnlarged = false;
  VideoPlayerController? _activeVideoController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdvertisementController>();
    final args = Get.arguments;

    int adId = 0;
    if (args is Map) {
      if (args['advertisement'] is Advertisement) {
        _advertisement = args['advertisement'] as Advertisement;
      }
      adId = args['id'] is int
          ? args['id'] as int
          : int.tryParse(args['id']?.toString() ?? '') ?? 0;
    }

    if (adId <= 0 && _advertisement != null) {
      adId = _advertisement!.id;
    }

    _loadDetail(adId);
  }

  Future<void> _loadDetail(int id) async {
    if (id <= 0) {
      setState(() {
        _isUnavailable = true;
        _isLoading = false;
      });
      return;
    }

    final fresh = await _controller.getAdDetail(id);
    if (!mounted) return;

    if (fresh != null && fresh.isValid) {
      setState(() {
        _advertisement = fresh;
        _isLoading = false;
        _isUnavailable = false;
      });
      _controller.recordImpression(fresh, AdPlacement.other);
    } else if (_advertisement != null && _advertisement!.isValid) {
      // Keep existing passed item if network detail check fails
      setState(() {
        _isLoading = false;
      });
      _controller.recordImpression(_advertisement!, AdPlacement.other);
    } else {
      setState(() {
        _isUnavailable = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isUnavailable || _advertisement == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.info_circle,
                size: 56.r,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                LK.adUnavailable.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(LK.goBack.tr),
              ),
            ],
          ),
        ),
      );
    }

    final ad = _advertisement!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Creative Media Banner
          Stack(
            children: [
              AspectRatio(
                aspectRatio:
                    (ad.media.width != null &&
                        ad.media.height != null &&
                        ad.media.height! > 0)
                    ? (ad.media.width! / ad.media.height!)
                    : (16 / 9),
                child: ad.type == AdvertisementType.video
                    ? (_isEnlarged
                          ? Container(color: Colors.black87)
                          : AdVideoPlayerWidget(
                              videoUrl: ad.media.url,
                              thumbnailUrl:
                                  (ad.media.thumbnailUrl != null &&
                                      ad.media.thumbnailUrl!.trim().isNotEmpty)
                                  ? ad.media.thumbnailUrl
                                  : ad.media.url,
                              controller: _activeVideoController,
                              onControllerCreated: (ctrl) {
                                _activeVideoController = ctrl;
                              },
                              onPlayStarted: () => _controller.recordImpression(
                                ad,
                                AdPlacement.other,
                              ),
                              onPlaybackChanged: (isPlaying) {
                                if (mounted &&
                                    _isVideoPlaying != isPlaying &&
                                    !_isEnlarged) {
                                  setState(() {
                                    _isVideoPlaying = isPlaying;
                                  });
                                }
                              },
                            ))
                    : CachedImg(
                        url: ad.media.url,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
              ),
              if (ad.showSponsoredLabel)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: const SponsoredLabel(),
                ),

              // Enlarge icon button in bottom right side:
              // Shown for images ALWAYS, and for videos ONLY when actively playing!
              if (ad.type != AdvertisementType.video ||
                  (_isVideoPlaying && !_isEnlarged))
                Positioned(
                  bottom: 10.h,
                  right: 12.w,
                  child: Semantics(
                    label: ad.type == AdvertisementType.video
                        ? 'Enlarge advertisement video'
                        : 'Enlarge advertisement image',
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            _isEnlarged = true;
                          });
                          await Get.to(
                            () => AdFullScreenMediaViewer(
                              advertisement: ad,
                              placement: AdPlacement.other,
                              existingController: _activeVideoController,
                              onTapCta: () => _controller.handleAdClick(
                                ad,
                                AdPlacement.other,
                              ),
                            ),
                            transition: Transition.fadeIn,
                            fullscreenDialog: true,
                          );
                          if (mounted) {
                            setState(() {
                              _isEnlarged = false;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 0.9,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Title & Subtitle
                Text(
                  ad.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ad.subtitle != null && ad.subtitle!.trim().isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    ad.subtitle!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // 4. Description (Plain text)
                if (ad.description != null &&
                    ad.description!.trim().isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  Text(
                    ad.description!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],

                // 5. Contact Details Card
                if (ad.contact != null &&
                    ad.contact!.name.trim().isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  _buildContactCard(context, ad),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Widget _buildContactCard(BuildContext context, Advertisement ad) {
    final contact = ad.contact!;
    final initials = _getInitials(contact.name);
    final hasMobile = contact.mobile.trim().isNotEmpty;
    final hasEmail = contact.email.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Row: Initials Avatar + Name & Representative Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gradient Initials Circle Avatar
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials.isNotEmpty ? initials : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
        
                  // Name & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Authorized Representative',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        
              // Divider
              if (hasMobile || hasEmail) ...[
                SizedBox(height: 14.h),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color:
                      Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
                SizedBox(height: 14.h),
              ],
        
              // Phone Item (Tappable with Call Icon)
              if (hasMobile) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _controller.handleContactCall(ad, ad.placement),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 6.h, horizontal: 4.w),
                      child: Row(
                        children: [
                          Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.call,
                              size: 17.sp,
                              color: const Color(0xFF25D366),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  contact.mobile,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.sp,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
        
              // Email Item (Tappable with Mail Icon)
              if (hasEmail) ...[
                if (hasMobile) SizedBox(height: 6.h),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _controller.handleContactEmail(ad, ad.placement),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 6.h, horizontal: 4.w),
                      child: Row(
                        children: [
                          Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.sms,
                              size: 17.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  contact.email,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.sp,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
        
              // Action Buttons (Call / Email)
              if (contact.showActions && (hasMobile || hasEmail)) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    if (hasMobile)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _controller.handleContactCall(
                              ad, ad.placement),
                          icon: const Icon(Iconsax.call, size: 17),
                          label: Text(
                            LK.call.tr,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    if (hasMobile && hasEmail) SizedBox(width: 10.w),
                    if (hasEmail)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _controller.handleContactEmail(
                              ad, ad.placement),
                          icon: const Icon(Iconsax.sms, size: 17),
                          label: Text(
                            LK.email.tr,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activeVideoController?.dispose();
    _activeVideoController = null;
    super.dispose();
  }
}
