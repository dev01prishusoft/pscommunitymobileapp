import 'dart:io';

void main() {
  final file = File('lib/features/samaj/presentation/pages/samaj_sanstha_page.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:get/get.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:get/get.dart';");
  }

  final oldLogic = '''
  Widget build(BuildContext context) {
    final initials = _getInitials(widget.sanstha.name);
    final hasDescription =
        widget.sanstha.description.isNotEmpty ||
        widget.sanstha.descriptionEnglish.isNotEmpty;

    final descriptionText = widget.sanstha.description.isNotEmpty
        ? widget.sanstha.description
        : widget.sanstha.descriptionEnglish;

    final showEnglishSubtitle =
        widget.sanstha.nameEnglish.isNotEmpty &&
        widget.sanstha.nameEnglish.toLowerCase() !=
            widget.sanstha.name.toLowerCase();
''';

  final newLogic = '''
  Widget build(BuildContext context) {
    final isEnglish = Get.locale?.languageCode == 'en';
    
    String displayName = isEnglish && widget.sanstha.nameEnglish.isNotEmpty 
        ? widget.sanstha.nameEnglish 
        : widget.sanstha.name;
    if (displayName.isEmpty) {
      displayName = isEnglish ? widget.sanstha.name : widget.sanstha.nameEnglish;
    }

    String displayDescription = isEnglish && widget.sanstha.descriptionEnglish.isNotEmpty 
        ? widget.sanstha.descriptionEnglish 
        : widget.sanstha.description;
    if (displayDescription.isEmpty) {
      displayDescription = isEnglish ? widget.sanstha.description : widget.sanstha.descriptionEnglish;
    }

    final initials = _getInitials(displayName);
    final hasDescription = displayDescription.isNotEmpty;
    final showEnglishSubtitle = false;
''';

  content = content.replaceFirst(oldLogic, newLogic);
  
  // also update references
  content = content.replaceAll('widget.sanstha.name,', 'displayName,');
  content = content.replaceAll('\${widget.sanstha.name}\\n', '\${displayName}\\n');
  content = content.replaceAll('descriptionText,', 'displayDescription,');
  content = content.replaceAll('\\n\\n\$descriptionText\';', '\\n\\n\$displayDescription\';');

  // And remove the english description text block at line 311
  final oldEnglishDescBlock = '''
                              if (widget
                                      .sanstha
                                      .descriptionEnglish
                                      .isNotEmpty &&
                                  widget.sanstha.descriptionEnglish !=
                                      widget.sanstha.description) ...[
                                const SizedBox(height: 8),
                                Text(
                                  widget.sanstha.descriptionEnglish,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ],
''';
  content = content.replaceFirst(oldEnglishDescBlock, '');

  file.writeAsStringSync(content);
  print('Updated samaj_sanstha_page.dart');
}
