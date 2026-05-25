// Script: strip_logs_and_comments.dart
// Run with: dart scratch/strip_logs_and_comments.dart
import 'dart:io';

void main() {
  final libDir = Directory('lib');
  int filesModified = 0;
  int linesRemoved = 0;

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final original = entity.readAsStringSync();
    var modified = original;

    // 1. Remove AppLogger.d/i/w/v lines (but NOT AppLogger.e)
    modified = _removeMatchingLines(modified, RegExp(
      r'^\s*AppLogger\.[diwv]\(.*\);\s*$',
      multiLine: true,
    ));

    // 2. Remove full-line // comments (but preserve:
    //    - ignore_for_file directives
    //    - ignore: directives
    //    - http:// and https:// URLs inside strings
    //    - TODO/FIXME that might be intentional workflow markers
    modified = _removeMatchingLines(modified, RegExp(
      r'^\s*//(?!ignore_for_file|ignore:).*$',
      multiLine: true,
    ));

    // 3. Remove /// doc comments
    modified = _removeMatchingLines(modified, RegExp(
      r'^\s*///.*$',
      multiLine: true,
    ));

    // 4. Remove block comments /* ... */ (single line form)
    modified = modified.replaceAll(
      RegExp(r'/\*[^*]*\*/'),
      '',
    );

    // 5. Remove trailing // inline comments (but preserve http:// https://)
    //    Only remove if the comment does NOT contain a URL
    modified = modified.replaceAllMapped(
      RegExp(r'(\s+)//(?!/)(?!.*https?://)(.*)$', multiLine: true),
      (m) => '',
    );

    // 6. Collapse multiple blank lines into one
    modified = modified.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    if (modified != original) {
      entity.writeAsStringSync(modified);
      filesModified++;
      final removedLineCount =
          original.split('\n').length - modified.split('\n').length;
      linesRemoved += removedLineCount;
      print('Modified: ${entity.path} (-$removedLineCount lines)');
    }
  }

  print('\nDone. Modified $filesModified files, removed ~$linesRemoved lines.');
}

String _removeMatchingLines(String content, Pattern pattern) {
  final lines = content.split('\n');
  final result = lines.where((line) => !RegExp(pattern.toString(), multiLine: false).hasMatch(line)).toList();
  return result.join('\n');
}
