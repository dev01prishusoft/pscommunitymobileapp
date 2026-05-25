// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final directory = Directory('lib');
  if (!directory.existsSync()) {
    print('Run this script from the project root.');
    exit(1);
  }

  final patterns = [RegExp(r'\w+\.tr\b')];

  int violations = 0;

  for (final file in directory.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        // Skip comments
        if (line.trim().startsWith('//')) continue;

        // Strip out valid usages
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
            print('Violation in ${file.path}:${i + 1}');
            print('  ${line.trim()}');
            violations++;
            break;
          }
        }
      }
    }
  }

  if (violations > 0) {
    print('\nFound $violations potential .tr violations!');
    print('Please use LK constants or explicit Enum Mappers.');
    exit(1);
  } else {
    print('No invalid .tr usages found. Architecture is clean!');
  }
}
