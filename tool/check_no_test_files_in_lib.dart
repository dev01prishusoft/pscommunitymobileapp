// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final directory = Directory('lib');
  if (!directory.existsSync()) {
    print('Run this script from the project root.');
    exit(1);
  }

  int violations = 0;

  for (final file in directory.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final filename = file.path.split(Platform.pathSeparator).last;
      if (filename.toLowerCase().contains('test')) {
        print('Violation: Test file found in lib/ directory -> ${file.path}');
        violations++;
      }
    }
  }

  if (violations > 0) {
    print('\nFound $violations test file(s) in lib/ directory!');
    print('Please move all test files to the test/ directory.');
    exit(1);
  } else {
    print('No test files found in lib/ directory. Architecture is clean!');
  }
}
