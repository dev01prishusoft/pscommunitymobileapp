import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:video_player/video_player.dart';
import '../controllers/advertisement_controller.dart';
import '../models/ad_placement.dart';
import '../models/advertisement.dart';

class AdFullScreenMediaViewer extends StatefulWidget {
  final Advertisement advertisement;
  final AdPlacement? placement;
  final VoidCallback? onTapCta;
  final VideoPlayerController? existingController;

  const AdFullScreenMediaViewer({
    super.key,
    required this.advertisement,
    this.placement,
    this.onTapCta,
    this.existingController,
  });

  @override
  State<AdFullScreenMediaViewer> createState() =>
      _AdFullScreenMediaViewerState();
}

class _AdFullScreenMediaViewerState extends State<AdFullScreenMediaViewer> {
  // ── Video player state ────────────────────────────────────────────────────
  VideoPlayerController? _controller;
  bool _isExternalController = false;
  bool _initialized = false;
  bool _hasError = false;
  String _lastError = '';
  bool _isPlaying = false;
  bool _isMuted = false;

  // ── Thumbnail state ───────────────────────────────────────────────────────
  bool _showThumbnail = true; // true until first real play frame is painted

  @override
  void initState() {
    super.initState();
    if (widget.advertisement.type == AdvertisementType.video) {
      if (widget.existingController != null) {
        _useExistingController(widget.existingController!);
      } else {
        _initPlayer();
      }
    }
  }

  void _useExistingController(VideoPlayerController ctrl) {
    _controller = ctrl;
    _isExternalController = true;
    _initialized = ctrl.value.isInitialized;
    _isPlaying = ctrl.value.isPlaying;
    _showThumbnail = false;
    _hasError = ctrl.value.hasError;
    _controller!.removeListener(_onControllerUpdate);
    _controller!.addListener(_onControllerUpdate);

    if (widget.placement != null &&
        Get.isRegistered<AdvertisementController>()) {
      Get.find<AdvertisementController>()
          .recordImpression(widget.advertisement, widget.placement!);
    }

    if (_initialized) {
      if (!_isPlaying) {
        _controller!.play();
      }
    } else {
      ctrl.initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _controller?.play();
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    }

    setState(() {});
  }

  // ── URL resolver (same logic as AdVideoPlayerWidget) ─────────────────────
  String _resolveUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final base = AppEnvironment.I.apiBaseUrl;
      final cleanBase =
          base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      final cleanPath =
          trimmed.startsWith('/') ? trimmed : '/$trimmed';
      return '$cleanBase$cleanPath';
    } catch (_) {
      return trimmed;
    }
  }

  // ── Initialise the video controller ──────────────────────────────────────
  Future<void> _initPlayer({bool isRetry = false}) async {
    // Clean up any previous controller first
    if (!_isExternalController) {
      final prev = _controller;
      _controller = null;
      prev?.removeListener(_onControllerUpdate);
      await prev?.dispose();
    } else {
      _controller?.removeListener(_onControllerUpdate);
      _controller = null;
      _isExternalController = false;
    }

    if (!mounted) return;
    setState(() {
      _hasError = false;
      _initialized = false;
      _isPlaying = false;
      _showThumbnail = true;
      _lastError = '';
    });

    // Give the hardware decoder time to release (critical on Android)
    final delay = isRetry ? 500 : 200;
    await Future.delayed(Duration(milliseconds: delay));
    if (!mounted) return;

    try {
      final raw = widget.advertisement.media.url;
      // media.url is already resolved by AdvertisementMedia.fromJson,
      // but apply _resolveUrl as a safety net for relative paths.
      final url = _resolveUrl(raw);
      debugPrint('AdFullScreenMediaViewer: loading video → $url');

      if (url.isEmpty) throw StateError('Video URL is empty after resolution.');

      Uri uri;
      try {
        uri = Uri.parse(url);
      } catch (_) {
        uri = Uri.parse(Uri.encodeFull(url));
      }

      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;
      _isExternalController = false;
      controller.addListener(_onControllerUpdate);

      await controller.initialize();

      debugPrint(
          'AdFullScreenMediaViewer: initialized – size=${controller.value.size}, '
          'duration=${controller.value.duration}');

      if (!mounted) return;

      // Record impression
      if (widget.placement != null &&
          Get.isRegistered<AdvertisementController>()) {
        Get.find<AdvertisementController>()
            .recordImpression(widget.advertisement, widget.placement!);
      }

      setState(() {
        _initialized = true;
      });

      await controller.play();
    } catch (e, st) {
      debugPrint('AdFullScreenMediaViewer: ERROR – $e\n$st');
      if (mounted) {
        setState(() {
          _hasError = true;
          _lastError = e.toString();
        });
      }
    }
  }

  // ── Controller listener ───────────────────────────────────────────────────
  void _onControllerUpdate() {
    if (_controller == null || !mounted) return;
    final val = _controller!.value;

    // Once the video starts painting real frames, remove the thumbnail overlay
    if (val.isPlaying && _showThumbnail) {
      setState(() {
        _showThumbnail = false;
      });
    }

    final nowPlaying = val.isPlaying;
    if (nowPlaying != _isPlaying && mounted) {
      setState(() {
        _isPlaying = nowPlaying;
      });
    }
  }

  // ── Controls ──────────────────────────────────────────────────────────────
  void _togglePlayPause() {
    if (_controller == null || !_initialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _toggleMute() {
    if (_controller == null) return;
    final muted = !_isMuted;
    setState(() => _isMuted = muted);
    _controller!.setVolume(muted ? 0.0 : 1.0);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    if (!_isExternalController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isVideo = widget.advertisement.type == AdvertisementType.video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── 1. Media area ──────────────────────────────────────────────
            Positioned.fill(
              child: isVideo ? _buildVideoArea() : _buildImageArea(),
            ),

            // ── 2. Top bar: close + sponsored ─────────────────────────────
            Positioned(
              top: 12.h,
              left: 14.w,
              right: 14.w,
              child: _buildTopBar(),
            ),

            // ── 3. Bottom bar: controls + title + CTA ─────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(isVideo),
            ),
          ],
        ),
      ),
    );
  }

  // ── Video area ────────────────────────────────────────────────────────────
  Widget _buildVideoArea() {
    // Error state
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_outlined,
                color: Colors.white70, size: 48.sp),
            SizedBox(height: 12.h),
            Text('Failed to load video',
                style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            if (_lastError.isNotEmpty) ...[  
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  _lastError,
                  style: TextStyle(color: Colors.white54, fontSize: 10.5.sp),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => _initPlayer(isRetry: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    // Loading / not yet initialized
    if (!_initialized || _controller == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
          strokeWidth: 2.5,
        ),
      );
    }

    // Compute aspect ratio
    final size = _controller!.value.size;
    final aspectRatio =
        (size.width > 0 && size.height > 0) ? size.width / size.height : 16 / 9;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video frame
          Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Thumbnail overlay shown until first play frame
          if (_showThumbnail) _buildThumbnailOverlay(),

          // Centre play icon when paused
          if (!_isPlaying && !_showThumbnail)
            Center(
              child: IgnorePointer(
                child: Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 38),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailOverlay() {
    final thumb = widget.advertisement.media.thumbnailUrl;
    final isImageThumb =
        thumb != null && thumb.isNotEmpty && !_isVideoUrl(thumb);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isImageThumb)
          CachedImg(
            url: thumb,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          )
        else
          Container(color: Colors.black),

        // "Loading video..." indicator until auto-play kicks in
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                  color: Theme.of(context).primaryColor, strokeWidth: 2.5),
              SizedBox(height: 12.h),
              Text('Loading video…',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
            ],
          ),
        ),
      ],
    );
  }

  bool _isVideoUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi');
  }

  // ── Image area ────────────────────────────────────────────────────────────
  Widget _buildImageArea() {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4.0,
      child: CachedImg(
        url: widget.advertisement.media.url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35), width: 1),
            ),
            child:
                const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          ),
        ),
        if (widget.advertisement.showSponsoredLabel)
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35), width: 0.8),
            ),
            child: Text(
              'Sponsored',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
      ],
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(bool isVideo) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video progress scrubber + mute
          if (isVideo && _initialized && _controller != null) ...[
            _buildVideoControls(),
            SizedBox(height: 8.h),
          ],

          // Title + CTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.advertisement.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
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
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5.sp),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    if (widget.onTapCta != null) {
                      widget.onTapCta!();
                      return;
                    }
                    if (widget.placement != null &&
                        Get.isRegistered<AdvertisementController>()) {
                      Get.find<AdvertisementController>().handleAdClick(
                          widget.advertisement, widget.placement!);
                    }
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 7.h),
                    child: Text(
                      widget.advertisement.ctaLabel.isNotEmpty
                          ? widget.advertisement.ctaLabel
                          : 'Know More',
                      style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Video scrubber + play/pause/mute row ──────────────────────────────────
  Widget _buildVideoControls() {
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          colors: VideoProgressColors(
            playedColor: Theme.of(context).primaryColor,
            bufferedColor: Colors.white.withValues(alpha: 0.35),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '${_fmt(pos)} / ${_fmt(dur)}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11.sp),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
