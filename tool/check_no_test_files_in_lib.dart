import 'dart:io';

void main() {
  final directory = Directory('lib');
  if (!directory.existsSync()) {
    exit(1);
  }

  int violations = 0;

  for (final file in directory.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final filename = file.path.split(Platform.pathSeparator).last;
      if (filename.toLowerCase().contains('test')) {
        violations++;
      }
    }
  }

  if (violations > 0) {
    exit(1);
  } else {
  }
}
