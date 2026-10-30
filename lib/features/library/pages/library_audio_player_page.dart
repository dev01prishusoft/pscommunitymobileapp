import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/utils/date_formatter.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/features/library/controllers/library_controller.dart';
import 'package:video_player/video_player.dart';

class LibraryAudioPlayerPage extends StatefulWidget {
  const LibraryAudioPlayerPage({super.key});

  @override
  State<LibraryAudioPlayerPage> createState() => _LibraryAudioPlayerPageState();
}

class _LibraryAudioPlayerPageState extends State<LibraryAudioPlayerPage>
    with SingleTickerProviderStateMixin {
  late final LibraryItemModel item;
  LibraryItemDetailsData? _details;
  bool _isLoadingDetails = false;
  int _selectedFileIndex = 0;

  VideoPlayerController? _audioController;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isLoading = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _waveAnimController;

  List<LibraryItemFile> get _files => _details?.files ?? <LibraryItemFile>[];
  LibraryItemFile? get _currentFile =>
      _files.isNotEmpty && _selectedFileIndex < _files.length
          ? _files[_selectedFileIndex]
          : null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is LibraryItemModel) {
      item = args;
    } else if (args is int) {
      item = LibraryItemModel(id: args.toString(), libraryItemId: args);
    } else if (args is String) {
      item = LibraryItemModel(id: args, libraryItemId: int.tryParse(args));
    } else {
      item = LibraryItemModel();
    }

    if (item.durationSeconds != null && item.durationSeconds! > 0) {
      _totalDuration = Duration(seconds: item.durationSeconds!);
    }

    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fetchDetailsAndInitAudio();
  }

  Future<void> _fetchDetailsAndInitAudio() async {
    final libraryController = Get.isRegistered<LibraryController>()
        ? Get.find<LibraryController>()
        : Get.put(LibraryController());

    final itemId = item.libraryItemId ?? int.tryParse(item.id);
    if (itemId != null) {
      setState(() => _isLoadingDetails = true);
      final details = await libraryController.fetchItemDetails(itemId);
      if (mounted) {
        setState(() {
          _details = details;
          _isLoadingDetails = false;

          if (_files.isNotEmpty) {
            final primaryIdx = _files.indexWhere((f) => f.isPrimary == true);
            if (primaryIdx != -1) {
              _selectedFileIndex = primaryIdx;
            }
          }

          final dur = _currentFile?.durationSeconds ?? details?.durationSeconds;
          if (dur != null) {
            final sec = int.tryParse(dur.toString());
            if (sec != null && sec > 0) {
              _totalDuration = Duration(seconds: sec);
            }
          }
        });
      }
    }

    final audioTarget = _currentFile?.filePath ??
        _files.firstOrNull?.filePath ??
        item.audioUrl ??
        item.primaryFilePath ??
        '';
    _initAudio(audioTarget);
  }

  Future<void> _initAudio([String? url, bool autoPlay = false]) async {
    setState(() => _isLoading = true);
    final targetUrl = (url != null && url.isNotEmpty)
        ? url
        : (_currentFile?.filePath ??
            _files.firstOrNull?.filePath ??
            item.audioUrl ??
            item.primaryFilePath ??
            '');
    if (targetUrl.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final fullUrl = LibraryController.resolveMediaUrl(targetUrl);

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      await controller.initialize();
      await controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (mounted) {
        setState(() {
          _audioController = controller;
          _isLoading = false;
          if (controller.value.duration > Duration.zero) {
            _totalDuration = controller.value.duration;
          }
        });

        controller.addListener(_onControllerUpdate);
        if (autoPlay) {
          controller.play();
          setState(() => _isPlaying = true);
        }
      }
    } catch (e) {
      debugPrint('Error initializing audio: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _switchTrack(int index) {
    if (index < 0 || index >= _files.length) return;
    if (index == _selectedFileIndex && _audioController != null) {
      _togglePlayPause();
      return;
    }

    setState(() {
      _selectedFileIndex = index;
      _currentPosition = Duration.zero;
    });

    final targetFile = _files[index];
    if (targetFile.durationSeconds != null) {
      final sec = int.tryParse(targetFile.durationSeconds.toString());
      if (sec != null && sec > 0) {
        setState(() => _totalDuration = Duration(seconds: sec));
      }
    }

    _audioController?.pause();
    _audioController?.removeListener(_onControllerUpdate);
    _audioController?.dispose();
    _audioController = null;

    _initAudio(targetFile.filePath, true);
  }

  void _onControllerUpdate() {
    final controller = _audioController;
    if (controller == null || !mounted) return;

    final isPlayingNow = controller.value.isPlaying;
    final pos = controller.value.position;

    setState(() {
      _currentPosition = pos;
      _isPlaying = isPlayingNow;
      if (controller.value.duration > Duration.zero) {
        _totalDuration = controller.value.duration;
      }
    });

    if (isPlayingNow) {
      if (!_waveAnimController.isAnimating) {
        _waveAnimController.repeat(reverse: true);
      }
    } else {
      if (_waveAnimController.isAnimating) {
        _waveAnimController.stop();
      }
    }

    if (controller.value.isCompleted) {
      setState(() {
        _isPlaying = false;
      });
      _waveAnimController.stop();
    }
  }

  void _togglePlayPause() {
    final controller = _audioController;
    if (controller != null && controller.value.isInitialized) {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        if (controller.value.isCompleted) {
          controller.seekTo(Duration.zero);
        }
        controller.play();
      }
    } else {
      PSDelightToastBar(
        snackbarDuration: const Duration(seconds: 2),
        builder: (context) => ToastCard(
          title: LK.library_audio_loading_title.tr,
          subtitle: LK.library_audio_loading_msg.tr,
        ),
      ).show();
    }
  }

  void _toggleMute() {
    final controller = _audioController;
    setState(() {
      _isMuted = !_isMuted;
    });

    if (controller != null && controller.value.isInitialized) {
      controller.setVolume(_isMuted ? 0.0 : 1.0);
    }
  }

  void _seekTo(double seconds) {
    final controller = _audioController;
    final target = Duration(seconds: seconds.toInt());
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(target);
    }
    setState(() {
      _currentPosition = target;
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _waveAnimController.dispose();
    _audioController?.removeListener(_onControllerUpdate);
    _audioController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _details?.title ?? item.title;
    final rawDate = _details?.publishedOn ?? item.date;
    final displayDate = formatDateString(rawDate, fallback: '');
    final badgeText =
        _details?.contentTypeBadge ?? _details?.contentTypeName ?? LK.library_audio_badge_fallback.tr;
    final displayDescription = _details?.description ??
        _details?.shortDescription ??
        item.about ??
        (item.description.isNotEmpty ? item.description : LK.library_audio_desc_fallback.tr);

    final activeFile = _currentFile;
    final activeFileTitle = activeFile?.caption?.isNotEmpty == true
        ? activeFile!.caption!
        : (activeFile?.fileName?.isNotEmpty == true
            ? activeFile!.fileName!
            : displayTitle);
    final activeFileFormat =
        activeFile?.mimeType?.split('/').last.toUpperCase() ?? badgeText;
    final activeFileSize =
        LibraryController.formatFileSize(activeFile?.fileSizeBytes);

    final maxSeconds = _totalDuration.inSeconds.toDouble() > 0
        ? _totalDuration.inSeconds.toDouble()
        : 1.0;
    final currentSec = _currentPosition.inSeconds.toDouble().clamp(
      0.0,
      maxSeconds,
    );

    return Scaffold(
      backgroundColor: AppColors.sfBackground,
      appBar: AppBar(
        title: Text(displayTitle),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingDetails) ...[
              LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                minHeight: 2.h,
              ),
              SizedBox(height: 12.h),
            ],

            // Top Audio Card
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Audio Icon Container
                  Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E24AA),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Title and Date / Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeFileTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          _files.length > 1
                              ? '${LK.library_audio_track_prefix.tr} ${_selectedFileIndex + 1} ${LK.library_audio_track_of.tr} ${_files.length}${displayDate.isNotEmpty ? " • $displayDate" : ""}'
                              : (displayDate.isNotEmpty
                                  ? (activeFileSize.isNotEmpty
                                      ? '$displayDate • $activeFileSize'
                                      : displayDate)
                                  : (activeFileSize.isNotEmpty ? activeFileSize : '')),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge MP3 / Format
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      activeFileFormat,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Audio Player Controls Box
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Row with Play Button, Progress Slider / Waveform, Volume
                  Row(
                    children: [
                      // Circular Play / Pause Button with AppColors.primary
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Seek Slider / Waveform
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Animated Waveform preview
                            SizedBox(
                              height: 18.h,
                              child: AnimatedBuilder(
                                animation: _waveAnimController,
                                builder: (context, child) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(24, (index) {
                                      final waveProgress =
                                          (_waveAnimController.value +
                                              (index / 24)) %
                                          1.0;
                                      final heightFactor = _isPlaying
                                          ? (0.25 + 0.75 * waveProgress)
                                          : 0.3;
                                      final isPlayed =
                                          (index / 24) <=
                                          (currentSec / maxSeconds);

                                      return Container(
                                        width: 2.5.w,
                                        height: 16.h * heightFactor,
                                        decoration: BoxDecoration(
                                          color: isPlayed
                                              ? AppColors.primary
                                              : const Color(0xFFCBD5E1),
                                          borderRadius: BorderRadius.circular(
                                            2.r,
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),

                            // Seek Slider
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3.5.h,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6.r,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: 12.r,
                                ),
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: const Color(0xFFE2E8F0),
                                thumbColor: AppColors.primary,
                              ),
                              child: Slider(
                                value: currentSec,
                                min: 0.0,
                                max: maxSeconds,
                                onChanged: _seekTo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),

                      // Interactive Volume / Mute button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: _toggleMute,
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              color: _isMuted
                                  ? const Color(0xFFDC2626)
                                  : AppColors.primary,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Time indicator row: e.g. 0:00 / 5:32
                  Padding(
                    padding: EdgeInsets.only(left: 60.w, right: 12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        if (_isMuted)
                          Text(
                            LK.library_audio_muted_badge.tr,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 22.h),

            // "About this audio" Section
            Text(
              LK.library_audio_about_heading.tr,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              displayDescription,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.sp,
                height: 1.5,
                color: const Color(0xFF64748B),
              ),
            ),

            if (_files.length > 1) ...[
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${LK.library_audio_tracks_heading.tr} (${_files.length})',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    LK.library_audio_tap_to_switch.tr,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _files.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, idx) {
                  final file = _files[idx];
                  final isSelected = idx == _selectedFileIndex;
                  final trackTitle = file.caption?.isNotEmpty == true
                      ? file.caption!
                      : (file.fileName?.isNotEmpty == true
                          ? file.fileName!
                          : '${LK.library_audio_track_title_fallback.tr} ${idx + 1}');
                  final durStr =
                      LibraryController.formatDuration(file.durationSeconds);
                  final sizeStr =
                      LibraryController.formatFileSize(file.fileSizeBytes);
                  final metaText = [
                    if (durStr.isNotEmpty) durStr,
                    if (sizeStr.isNotEmpty) sizeStr,
                    if (file.mimeType != null && file.mimeType!.isNotEmpty)
                      file.mimeType!.split('/').last.toUpperCase(),
                  ].join(' • ');

                  return InkWell(
                    onTap: () => _switchTrack(idx),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isSelected && _isPlaying
                                  ? const Icon(Icons.equalizer_rounded,
                                      color: Colors.white, size: 20)
                                  : Icon(
                                      isSelected
                                          ? Icons.play_arrow_rounded
                                          : Icons.music_note_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                      size: 18.sp,
                                    ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trackTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                if (metaText.isNotEmpty) ...[
                                  SizedBox(height: 3.h),
                                  Text(
                                    metaText,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: EdgeInsets.only(left: 8.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                _isPlaying ? LK.library_audio_playing_badge.tr : LK.library_audio_selected_badge.tr,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else if (_files.length == 1) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        color: Color(0xFF64748B), size: 20),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _files.first.fileName ?? LK.library_audio_file_fallback.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                    if (_files.first.fileSizeBytes != null)
                      Text(
                        LibraryController.formatFileSize(
                            _files.first.fileSizeBytes),
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
