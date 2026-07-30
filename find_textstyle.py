import os
import re
import sys

files = [
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
]

def find_matching_bracket(text, start_idx):
    count = 0
    for i in range(start_idx, len(text)):
        if text[i] == '(':
            count += 1
        elif text[i] == ')':
            count -= 1
            if count == 0:
                return i
    return -1

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
    except Exception as e:
        print(f'Error reading {f}: {e}')
        continue
    
    idx = 0
    found = False
    while True:
        idx = content.find('TextStyle(', idx)
        if idx == -1:
            break
        
        # Check if it's pw.TextStyle
        if idx > 3 and content[idx-3:idx] == 'pw.':
            idx += 10
            continue
            
        end_idx = find_matching_bracket(content, idx + 9)
        if end_idx != -1:
            if not found:
                print(f'\\n--- {f} ---')
                found = True
            
            # get line number
            line_no = content.count('\\n', 0, idx) + 1
            print(f'Line {line_no}:\\n{content[idx:end_idx+1]}')
            
            idx = end_idx + 1
        else:
            idx += 10
