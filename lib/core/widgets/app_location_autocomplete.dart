import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/models/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/services/app_setting_service.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';

class AppLocationAutoComplete extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final Widget? prefixIcon;
  final ProfileUpdateStatus? updateStatus;
  final Function(String location, double lat, double lng)? onLocationSelected;

  const AppLocationAutoComplete({
    super.key,
    this.updateStatus,
    required this.controller,
    required this.label,
    this.isRequired = false,
    this.prefixIcon,
    this.onLocationSelected,
  });

  @override
  State<AppLocationAutoComplete> createState() =>
      _AppLocationAutoCompleteState();
}

class _AppLocationAutoCompleteState extends State<AppLocationAutoComplete> {
  Timer? _debounce;
  String _googleApiKey = AppSettingService.maybe?.cachedGoogleApiKey ?? '';
  bool _isKeyLoading = false;
  final Dio _dio = Dio();

  bool _isLoading = false;
  String? _lastSelectedLocation;

  @override
  void initState() {
    super.initState();
    _lastSelectedLocation = widget.controller.text;
    if (_googleApiKey.isEmpty) _loadGoogleApiKey();
  }

  Future<void> _loadGoogleApiKey() async {
    final service = AppSettingService.maybe;
    if (service == null) return;
    setState(() => _isKeyLoading = true);
    final key = await service.getGoogleApiKey();
    if (!mounted) return;
    setState(() {
      _googleApiKey = key;
      _isKeyLoading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _dio.close(force: true);
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (_googleApiKey.isEmpty || query.trim().length < 3) return [];
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'input': query,
          'types': '(regions)',
          'components': 'country:in',
          'key': _googleApiKey,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          var predictions = List<Map<String, dynamic>>.from(
            (data['predictions'] as List).map(
              (p) => Map<String, dynamic>.from(p),
            ),
          );
          for (var i = 0; i < predictions.length; i++) {
            var desc = predictions[i]['description'] as String?;
            if (desc != null) {
              var parts = desc.split(', ');
              if (parts.length > 1) {
                parts.removeLast();
                predictions[i]['description'] = parts.join(', ');
              }
            }
          }
          return predictions;
        }
      }
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> _getPlaceDetails(String placeId, String description) async {
    if (_googleApiKey.isEmpty || placeId.isEmpty) return;
    const String url =
        'https://maps.googleapis.com/maps/api/place/details/json';

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': _googleApiKey,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          if (widget.onLocationSelected != null) {
            widget.onLocationSelected!(
              description,
              (lat as num).toDouble(),
              (lng as num).toDouble(),
            );
          }
        }
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'AppLocationAutoComplete._getPlaceDetails failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_googleApiKey.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: widget.label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey),
              children: [
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.red,
                    ),
                  ),
              ],
            ),
          ).paddingOnly(left: 5.w, bottom: 6.h),
          TextFormField(
            controller: widget.controller,
            maxLength: 250,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
            decoration: InputDecoration(
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: const IconThemeData(size: 20),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: _isKeyLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              helperText: _isKeyLoading
                  ? null
                  : 'Location autocomplete disabled (API key missing)',
              helperStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
            validator: (value) {
              if (widget.isRequired &&
                  (value == null || value.trim().isEmpty)) {
                return '${widget.label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
              }
              return null;
            },
          ),
          if (widget.updateStatus != null)
            ProfileUpdateStatusBadge(status: widget.updateStatus!),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey),
            children: [
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.red,
                  ),
                ),
            ],
          ),
        ).paddingOnly(left: 5.w, bottom: 6.h),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.length < 3) {
              return const Iterable<Map<String, dynamic>>.empty();
            }

            // Debounce
            if (_debounce?.isActive ?? false) _debounce!.cancel();

            Completer<Iterable<Map<String, dynamic>>> completer = Completer();

            _debounce = Timer(const Duration(milliseconds: 500), () async {
              if (!mounted) return completer.complete(const []);
              setState(() => _isLoading = true);
              final results = await _getSuggestions(textEditingValue.text);
              if (mounted) {
                setState(() => _isLoading = false);
              }
              completer.complete(results);
            });

            return completer.future;
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['description']?.toString() ?? '',
          onSelected: (Map<String, dynamic> selection) {
            final description = selection['description']?.toString() ?? '';
            widget.controller.text = description;
            _lastSelectedLocation = description;
            _getPlaceDetails(
              selection['place_id']?.toString() ?? '',
              description,
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            if (widget.controller.text.isNotEmpty &&
                fieldTextEditingController.text.isEmpty) {
              fieldTextEditingController.text = widget.controller.text;
            }

            fieldTextEditingController.addListener(() {
              if (widget.controller.text != fieldTextEditingController.text) {
                widget.controller.text = fieldTextEditingController.text;
              }
            });

            return TextFormField(
              maxLength: 250,
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: const IconThemeData(size: 20),
                        child: widget.prefixIcon!,
                      )
                    : null,
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              validator: (value) {
                if (widget.isRequired &&
                    (value == null || value.trim().isEmpty)) {
                  return '${widget.label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
                }
                if (value != null &&
                    value.trim().isNotEmpty &&
                    value != _lastSelectedLocation) {
                  return LK.selectValidLocation.tr;
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<Map<String, dynamic>> onSelected,
            Iterable<Map<String, dynamic>> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 250.h),
                  width: MediaQuery.of(context).size.width -
                      32.w, // Match padding roughly
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> option = options.elementAt(
                        index,
                      );
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(
                          option['description']?.toString() ?? '',
                          style: AppTextStyles.bodyMedium,
                        ),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.updateStatus != null)
          ProfileUpdateStatusBadge(status: widget.updateStatus!),
      ],
    );
  }
}
