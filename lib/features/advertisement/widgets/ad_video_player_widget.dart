import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';

class AdVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final VoidCallback? onPlayStarted;
  final ValueChanged<bool>? onPlaybackChanged;
  final bool autoPlay;
  final BoxFit fit;
  final bool showProgressBar;
  final VideoPlayerController? controller;
  final ValueChanged<VideoPlayerController>? onControllerCreated;

  const AdVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.onPlayStarted,
    this.onPlaybackChanged,
    this.autoPlay = false,
    this.fit = BoxFit.cover,
    this.showProgressBar = false,
    this.controller,
    this.onControllerCreated,
  });

  @override
  State<AdVideoPlayerWidget> createState() => _AdVideoPlayerWidgetState();
}

class _AdVideoPlayerWidgetState extends State<AdVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isExternalController = false;
  bool _isPlaying = false;
  bool _hasStartedPlaying = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _useExistingController(widget.controller!);
    } else {
      _initController();
    }
  }

  @override
  void didUpdateWidget(covariant AdVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller && widget.controller != null) {
      _controller?.removeListener(_handleControllerUpdate);
      if (!_isExternalController) {
        _controller?.dispose();
      }
      _useExistingController(widget.controller!);
    }
  }

  Future<void> _useExistingController(VideoPlayerController ctrl) async {
    _controller = ctrl;
    _isExternalController = true;
    try {
      if (!ctrl.value.isInitialized) {
        await ctrl.initialize();
      }
      if (!mounted) return;
      _isPlaying = ctrl.value.isPlaying;
      _hasStartedPlaying = ctrl.value.isPlaying;
      _hasError = ctrl.value.hasError;
      _controller?.removeListener(_handleControllerUpdate);
      _controller?.addListener(_handleControllerUpdate);
      widget.onControllerCreated?.call(ctrl);

      setState(() {});
      if (widget.autoPlay && !_isPlaying) {
        await _play();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  Future<void> _initController() async {
    try {
      String resolvedVideoUrl = widget.videoUrl.trim();
      if (resolvedVideoUrl.isNotEmpty &&
          !resolvedVideoUrl.startsWith('http://') &&
          !resolvedVideoUrl.startsWith('https://')) {
        try {
          final baseUrl = AppEnvironment.I.apiBaseUrl;
          final cleanBase = baseUrl.endsWith('/')
              ? baseUrl.substring(0, baseUrl.length - 1)
              : baseUrl;
          final cleanPath = resolvedVideoUrl.startsWith('/')
              ? resolvedVideoUrl
              : '/$resolvedVideoUrl';
          resolvedVideoUrl = '$cleanBase$cleanPath';
        } catch (_) {}
      }
      final uri = Uri.parse(resolvedVideoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();

      _controller!.addListener(_handleControllerUpdate);
      widget.onControllerCreated?.call(_controller!);

      if (mounted) {
        setState(() {});
        if (widget.autoPlay) {
          _play();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _handleControllerUpdate() {
    if (_controller == null || !mounted) return;
    final val = _controller!.value;
    final isPlayingNow = val.isPlaying;

    if (isPlayingNow && !_hasStartedPlaying) {
      _hasStartedPlaying = true;
      widget.onPlayStarted?.call();
    }

    if (isPlayingNow != _isPlaying) {
      setState(() {
        _isPlaying = isPlayingNow;
      });
      widget.onPlaybackChanged?.call(isPlayingNow);
    }

    // When video finishes, reset to beginning and pause
    if (val.duration > Duration.zero && val.position >= val.duration) {
      _controller!.seekTo(Duration.zero);
      _controller!.pause();
      setState(() {
        _isPlaying = false;
      });
      widget.onPlaybackChanged?.call(false);
    }
  }

  Future<void> _play() async {
    if (_controller == null) return;
    if (!_controller!.value.isInitialized) {
      try {
        await _controller!.initialize();
      } catch (_) {}
    }
    await _controller!.play();
  }

  Future<void> _pause() async {
    if (_controller == null) return;
    await _controller!.pause();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerUpdate);
    if (!_isExternalController) {
      _controller?.dispose();
    }
    _controller = null;
    super.dispose();
  }

  bool _isImageThumbnail(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final lower = url.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black87,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white70, size: 24.sp),
        ),
      );
    }

    final hasValidThumb = _isImageThumbnail(widget.thumbnailUrl);

    // If video is NOT playing: ALWAYS SHOW THUMBNAIL with Play button!
    if (!_isPlaying) {
      return Container(
        color: Colors.black,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // 1. Thumbnail Image or Initialized Video 1st Frame
              if (hasValidThumb)
                CachedImg(
                  url: widget.thumbnailUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              else if (_controller != null &&
                  _controller!.value.isInitialized &&
                  _controller!.value.size.width > 0 &&
                  _controller!.value.size.height > 0)
                FittedBox(
                  fit: widget.fit,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
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
                ),

              // 2. Play Button Icon (▶️)
              Center(
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // When video IS PLAYING: show video with Pause button (⏸) only!
    return Container(
      color: Colors.black,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            // 1. Video Playing
            if (_controller != null &&
                _controller!.value.isInitialized &&
                _controller!.value.size.width > 0 &&
                _controller!.value.size.height > 0)
              FittedBox(
                fit: widget.fit,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                ),
              ),

          // 2. Pause Icon (⏸) Only
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _pause,
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),

          // 3. Optional Progress Bar for fullscreen
          if (widget.showProgressBar &&
              _controller != null &&
              _controller!.value.isInitialized)
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 60.h,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).primaryColor,
                  bufferedColor: Colors.white.withValues(alpha: 0.3),
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}
