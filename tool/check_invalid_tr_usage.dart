import 'dart:io';

void main() {
  final directory = Directory('lib');
  if (!directory.existsSync()) {
    exit(1);
  }

  final patterns = [RegExp(r'\w+\.tr\b')];

  int violations = 0;

  for (final file in directory.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().startsWith('//')) continue;
        final checkLine = line
            .replaceAll(RegExp(r'LK\.\w+\.tr'), '')
            .replaceAll(RegExp(r'\w+Mapper\.getLabelKey\([^)]*\)\?\.tr'), '')
            .replaceAll(
              RegExp(
                r"['"
                '"'
                r"']All['"
                '"'
                r"']\.tr",
              ),
              '',
            ) // safe static texts
            .replaceAll(RegExp(r'\b\w*Key\.tr\b'), '') // extracted keys
            .replaceAll('key.tr', ''); // explicit catch

        for (final pattern in patterns) {
          if (pattern.hasMatch(checkLine)) {
            violations++;
            break;
          }
        }
      }
    }
  }

  if (violations > 0) {
    exit(1);
  } else {
  }
}
