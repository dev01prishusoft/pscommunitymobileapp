import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import '../controllers/advertisement_controller.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';
import 'ad_fullscreen_media_viewer.dart';
import 'ad_video_player_widget.dart';

enum AdLayout { banner, card }

class AdvertisementCard extends StatefulWidget {
  final Advertisement advertisement;
  final AdPlacement placement;
  final AdLayout layout;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onVideoPlaybackChanged;
  final double? height;
  final bool isActive;

  const AdvertisementCard({
    super.key,
    required this.advertisement,
    required this.placement,
    this.layout = AdLayout.card,
    this.onTap,
    this.onVideoPlaybackChanged,
    this.height,
    this.isActive = true,
  });

  @override
  State<AdvertisementCard> createState() => _AdvertisementCardState();
}

class _AdvertisementCardState extends State<AdvertisementCard> {
  bool _isVideoPlaying = false;
  bool _isEnlarged = false;
  VideoPlayerController? _activeVideoController;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideoPreviewIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AdvertisementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.advertisement.id != oldWidget.advertisement.id ||
        widget.advertisement.media.url != oldWidget.advertisement.media.url) {
      _activeVideoController?.pause();
      _activeVideoController?.dispose();
      _activeVideoController = null;
      _isControllerInitialized = false;
      _isVideoPlaying = false;
      _initVideoPreviewIfNeeded();
      return;
    }

    // When slide becomes inactive (user swiped away in carousel), pause video cleanly!
    if (oldWidget.isActive && !widget.isActive) {
      _handleSlideInactive();
    }
  }

  void _handleSlideInactive() {
    if (_isVideoPlaying) {
      _activeVideoController?.pause();
      if (mounted) {
        setState(() {
          _isVideoPlaying = false;
        });
      }
      widget.onVideoPlaybackChanged?.call(false);
    }
  }

  void _initVideoPreviewIfNeeded() {
    final isVideo = widget.advertisement.type == AdvertisementType.video;
    if (isVideo && !widget.advertisement.media.hasValidImageThumbnail) {
      final videoUrl = widget.advertisement.media.url.trim();
      if (videoUrl.isNotEmpty) {
        final uri = Uri.tryParse(videoUrl);
        if (uri != null) {
          final ctrl = VideoPlayerController.networkUrl(uri);
          _activeVideoController = ctrl;
          ctrl
              .initialize()
              .then((_) {
                if (mounted && _activeVideoController == ctrl) {
                  setState(() {
                    _isControllerInitialized = true;
                  });
                }
              })
              .catchError((_) {
                if (mounted && _activeVideoController == ctrl) {
                  setState(() {
                    _isControllerInitialized = false;
                  });
                }
              });
        }
      }
    }
  }

  void _handleClick(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    if (Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>().handleAdClick(
        widget.advertisement,
        widget.placement,
      );
    }
  }

  void _startVideo() {
    setState(() {
      _isVideoPlaying = true;
    });
    widget.onVideoPlaybackChanged?.call(true);
    if (Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>().recordImpression(
        widget.advertisement,
        widget.placement,
      );
    }
  }

  void _stopVideo() {
    _activeVideoController?.pause();
    if (_activeVideoController != null &&
        _activeVideoController!.value.isInitialized &&
        _activeVideoController!.value.position >=
            _activeVideoController!.value.duration) {
      _activeVideoController?.seekTo(Duration.zero);
    }
    if (mounted) {
      setState(() {
        _isVideoPlaying = false;
      });
    }
    widget.onVideoPlaybackChanged?.call(false);
  }

  Future<void> _openFullscreenMedia(BuildContext context) async {
    setState(() {
      _isEnlarged = true;
    });

    await Get.to(
      () => AdFullScreenMediaViewer(
        advertisement: widget.advertisement,
        placement: widget.placement,
        existingController: _activeVideoController,
        onTapCta: () => _handleClick(context),
      ),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    );

    if (mounted) {
      setState(() {
        _isEnlarged = false;
        if (_activeVideoController != null &&
            _activeVideoController!.value.isInitialized) {
          _isVideoPlaying = _activeVideoController!.value.isPlaying;
        }
      });
      widget.onVideoPlaybackChanged?.call(_isVideoPlaying);
    }
  }

  @override
  void dispose() {
    _activeVideoController?.pause();
    _activeVideoController?.dispose();
    _activeVideoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.advertisement.type == AdvertisementType.video;

    return Semantics(
      label: 'Sponsored advertisement, ${widget.advertisement.title}',
      button: true,
      child: Container(
        height: widget.height ?? 130.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isVideo ? const Color(0xFF151515) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            isVideo && _isVideoPlaying && !_isEnlarged
                ? _buildActiveVideoPlayer(context)
                : _buildBannerCard(context, isVideo: isVideo),

            // Enlarge icon button in bottom right side:
            // Shown for images ALWAYS, and for videos ONLY when actively playing!
            if (!isVideo || (_isVideoPlaying && !_isEnlarged))
              Positioned(
                bottom: 6.h,
                right: 8.w,
                child: _buildEnlargeButton(context, isVideo: isVideo),
              ),
          ],
        ),
      ),
    );
  }

  /// Active Video Playback View (Only video playing with Pause button)
  Widget _buildActiveVideoPlayer(BuildContext context) {
    final thumb =
        widget.advertisement.media.thumbnailUrl != null &&
            widget.advertisement.media.thumbnailUrl!.trim().isNotEmpty
        ? widget.advertisement.media.thumbnailUrl!
        : null;
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Video Player with only Play/Pause controls and thumbnail when paused
        AdVideoPlayerWidget(
          videoUrl: widget.advertisement.media.url,
          thumbnailUrl: thumb,
          autoPlay: true,
          controller: _activeVideoController,
          onControllerCreated: (ctrl) {
            _activeVideoController = ctrl;
          },
          onPlaybackChanged: (isPlaying) {
            if (!isPlaying && mounted && !_isEnlarged) {
              _stopVideo();
            } else {
              widget.onVideoPlaybackChanged?.call(isPlaying);
            }
          },
          onPlayStarted: () {
            if (Get.isRegistered<AdvertisementController>()) {
              Get.find<AdvertisementController>().recordImpression(
                widget.advertisement,
                widget.placement,
              );
            }
          },
        ),

        // 2. Floating CTA Pill Button at Bottom-Left
        Positioned(
          bottom: 6.h,
          left: 8.w,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleClick(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                widget.advertisement.ctaLabel.isNotEmpty
                    ? widget.advertisement.ctaLabel
                    : 'Know More',
                style: TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // 3. Sponsored Badge on Top-Right
        if (widget.advertisement.showSponsoredLabel)
          Positioned(top: 8.h, right: 8.w, child: _buildSponsoredBadge()),
      ],
    );
  }

  /// Normal Banner Card (Shows Thumbnail for Video when paused or image for Image ads)
  Widget _buildBannerCard(BuildContext context, {required bool isVideo}) {
    final hasValidThumb = widget.advertisement.media.hasValidImageThumbnail;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleClick(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Direct Background: Valid image thumbnail or video 1st frame
          if (isVideo)
            if (hasValidThumb)
              CachedImg(
                url: widget.advertisement.media.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else if (_isControllerInitialized &&
                _activeVideoController != null &&
                _activeVideoController!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _activeVideoController!.value.size.width,
                  height: _activeVideoController!.value.size.height,
                  child: VideoPlayer(_activeVideoController!),
                ),
              )
            else
              Container(
                color: Colors.black87,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
          else
            CachedImg(
              url: widget.advertisement.media.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

          // 2. Subtle Dark Gradient for Text Readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 0.85],
              ),
            ),
          ),

          // 3. Left Side: Title (2 lines) and CTA Pill Button
          Positioned(
            top: 12.h,
            bottom: 12.h,
            left: 14.w,
            right: isVideo ? 80.w : 130.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.advertisement.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                if (widget.advertisement.subtitle != null &&
                    widget.advertisement.subtitle!.trim().isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    widget.advertisement.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w400,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  child: InkWell(
                    onTap: () => _handleClick(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 5.h,
                      ),
                      child: Text(
                        widget.advertisement.ctaLabel.isNotEmpty
                            ? widget.advertisement.ctaLabel
                            : 'Know More',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Play Button Overlay (when media type is video)
          if (isVideo)
            Positioned(
              right: 24.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _startVideo,
                  child: Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

          // 5. Top-Right Corner: Sponsored Badge
          if (widget.advertisement.showSponsoredLabel)
            Positioned(top: 8.h, right: 8.w, child: _buildSponsoredBadge()),
        ],
      ),
    );
  }

  Widget _buildSponsoredBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.6,
        ),
      ),
      child: Text(
        'Sponsored',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEnlargeButton(BuildContext context, {required bool isVideo}) {
    return Semantics(
      label: isVideo ? 'Enlarge advertisement video' : 'Enlarge advertisement image',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openFullscreenMedia(context),
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            width: 24.r,
            height: 24.r,
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
              size: 15,
            ),
          ),
        ),
      ),
    );
  }
}
