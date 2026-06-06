import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppFormTimePicker extends StatefulWidget {
  const AppFormTimePicker({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isRequired;
  final String? Function(String?)? validator;

  @override
  State<AppFormTimePicker> createState() => _AppFormTimePickerState();
}

class _AppFormTimePickerState extends State<AppFormTimePicker> {
  late final TextEditingController _displayController;

  @override
  void initState() {
    super.initState();
    _displayController = TextEditingController();
    _updateDisplay();
    widget.controller.addListener(_updateDisplay);
  }

  @override
  void didUpdateWidget(AppFormTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updateDisplay);
      widget.controller.addListener(_updateDisplay);
      _updateDisplay();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateDisplay);
    _displayController.dispose();
    super.dispose();
  }

  void _updateDisplay() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      if (_displayController.text.isNotEmpty) _displayController.text = '';
      return;
    }
    
    // Parse 24h format from the main controller
    try {
      final parts = text.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final time = TimeOfDay(hour: hour, minute: minute);
        
        final displayHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
        final displayMinute = time.minute.toString().padLeft(2, '0');
        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
        final newDisplayText = '$displayHour:$displayMinute $period';
        
        if (_displayController.text != newDisplayText) {
          _displayController.text = newDisplayText;
        }
      }
    } catch (_) {
      // If parsing fails (maybe it's already AM/PM somehow), just use it
      if (_displayController.text != text) {
        _displayController.text = text;
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (widget.controller.text.isNotEmpty) {
      try {
        final parts = widget.controller.text.split(':');
        if (parts.length >= 2) {
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.foreground,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );
    
    if (picked != null) {
      // Save 24h format to the underlying controller
      final String hour = picked.hour.toString().padLeft(2, '0');
      final String minute = picked.minute.toString().padLeft(2, '0');
      widget.controller.text = '$hour:$minute';
      // _updateDisplay will be called automatically via the listener
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
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
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _displayController,
          readOnly: true,
          onTap: () => _selectTime(context),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            prefixIcon: Icon(
              Icons.access_time,
              color: AppColors.mutedForeground,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.red),
            ),
          ),
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return LK.fieldRequired.tr;
            }
            if (widget.validator != null) {
              return widget.validator!(widget.controller.text);
            }
            return null;
          },
        ),
      ],
    );
  }
}

