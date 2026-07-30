import 'dart:io';

void main() {
  List<String> files = [
    'lib/core/widgets/fatal_error_screen.dart',
    'lib/core/widgets/paginated_list_view.dart',
    'lib/features/home/presentation/pages/home_page.dart',
    'lib/features/home/presentation/pages/share_app_page.dart',
    'lib/features/family/presentation/pages/family_areas_page.dart',
    'lib/features/member/presentation/pages/add_family_member_page.dart',
    'lib/features/member/presentation/pages/added_members_list_page.dart',
    'lib/features/member/presentation/pages/edit_profile_page.dart',
    'lib/features/marriage/presentation/pages/marriage_page.dart',
    'lib/features/payment/presentation/pages/make_payment_page.dart',
    'lib/features/payment/presentation/pages/payment_history_page.dart',
    'lib/features/payment/presentation/pages/payments_page.dart',
    'lib/features/samaj/presentation/pages/bank_account_details_page.dart',
    'lib/features/samaj/presentation/pages/bank_details_page.dart',
    'lib/features/samaj/presentation/pages/samaj_sanstha_page.dart',
    'lib/features/support/presentation/pages/support_page.dart'
  ];

  int findMatchingBracket(String text, int startIdx) {
    int count = 0;
    for (int i = startIdx; i < text.length; i++) {
      if (text[i] == '(') {
        count++;
      } else if (text[i] == ')') {
        count--;
        if (count == 0) {
          return i;
        }
      }
    }
    return -1;
  }

  for (String f in files) {
    try {
      File file = File(f);
      if (!file.existsSync()) continue;
      String content = file.readAsStringSync();
      
      int idx = 0;
      bool found = false;
      
      while (true) {
        idx = content.indexOf('TextStyle(', idx);
        if (idx == -1) break;
        
        // Check if it's pw.TextStyle
        if (idx >= 3 && content.substring(idx - 3, idx) == 'pw.') {
          idx += 10;
          continue;
        }
        
        int endIdx = findMatchingBracket(content, idx + 9);
        if (endIdx != -1) {
          if (!found) {
            print('\\n--- \$f ---');
            found = true;
          }
          
          int lineNo = content.substring(0, idx).split('\\n').length;
          print('Line \$lineNo:\\n\${content.substring(idx, endIdx + 1)}');
          
          idx = endIdx + 1;
        } else {
          idx += 10;
        }
      }
    } catch (e) {
      print('Error reading \$f: \$e');
    }
  }
}
