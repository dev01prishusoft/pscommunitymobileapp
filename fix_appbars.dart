import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final overrideRegex = RegExp(r'appBar:\s*AppBar\s*\(\s*(backgroundColor:.*?,\s*)?(elevation:.*?,\s*)?(leading:.*?,\s*)?title:\s*Text\s*\(\s*(.*?),\s*(style:.*?)?\s*\)(,\s*centerTitle:.*?,?)?\s*\)', dotAll: true);

  for (final file in files) {
    final content = file.readAsStringSync();
    if (content.contains('appBar: AppBar(')) {
      // Find all matches
      final newContent = content.replaceAllMapped(overrideRegex, (match) {
        final titleText = match.group(4) ?? '';
        return 'appBar: AppBar(title: Text($titleText))';
      });

      if (newContent != content) {
        file.writeAsStringSync(newContent);
        // ignore: avoid_print
        print('Updated \${file.path}');
      }
    }
  }
}
