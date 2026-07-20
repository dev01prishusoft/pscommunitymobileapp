import 'dart:io';

void main() {
  final file = File('lib/features/samaj/presentation/pages/samaj_sanstha_page.dart');
  var content = file.readAsStringSync();

  // Fix syntax error line 273: add `children: [`
  content = content.replaceAll(
    'Column(\n                      crossAxisAlignment: CrossAxisAlignment.end,\n                        if (hasDescription)',
    'Column(\n                      crossAxisAlignment: CrossAxisAlignment.end,\n                      children: [\n                        if (hasDescription)'
  );

  // Fix colors
  content = content.replaceAll(
    'final color = isActive ? AppColors.green : AppColors.red;',
    'final color = isActive ? AppColors.green : Colors.red;'
  );
  content = content.replaceAll(
    'final bgColor = isActive ? AppColors.green.shade50 : AppColors.red.shade50;',
    'final bgColor = isActive ? AppColors.green.shade50 : Colors.red.shade50;'
  );
  content = content.replaceAll(
    'final borderColor = isActive ? AppColors.green.shade100 : AppColors.red.shade100;',
    'final borderColor = isActive ? AppColors.green.shade100 : Colors.red.shade100;'
  );
  content = content.replaceAll(
    'final textColor = isActive ? AppColors.green.shade700 : AppColors.red.shade700;',
    'final textColor = isActive ? AppColors.green.shade700 : Colors.red.shade700;'
  );

  file.writeAsStringSync(content);
  print('Fixed samaj_sanstha_page.dart');
}
