import json
import os

def restore_aliases(file_path, mappings):
    if not os.path.exists(file_path):
        return
    
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Add English strings as keys pointing to the same values as the symbolic keys
    for symbolic_key, english_string in mappings.items():
        if symbolic_key in data:
            data[english_string] = data[symbolic_key]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

mappings = {
    'common_app_title': 'PS Community',
    'common_welcome_title': 'Welcome to PrishuSoft Samaj',
    'common_welcomes_you': 'welcomes you',
    'common_mobile_number': 'Mobile Number',
    'common_mobile_hint': 'Enter 10-digit mobile number',
    'common_password': 'Password',
    'common_password_hint': '........',
    'common_reset': 'Reset',
    'common_samaj_name': 'Andhariya Ganata Samaj',
    'auth_sign_in': 'Sign In',
    'auth_welcome_back': 'Welcome Back',
    'auth_login_subtitle': 'Sign in to your PSCommunity account',
    'auth_forgot_password': 'Forgot Password?',
    'auth_admin_warning': 'Use your admin credentials to continue.',
    'auth_reset_password': 'Reset Password',
    'auth_new_password': 'New Password',
    'auth_confirm_new_password': 'Confirm New Password',
    'auth_update_password': 'Update Password',
    'auth_error_password_mismatch': 'Passwords do not match',
    'error_server': 'Server Error',
    'error_no_internet': 'No Internet Connection',
    'error_unauthorized': 'Unauthorized',
    'error_timeout': 'Request Timeout',
    'error_security_pinning': 'Security Error',
    'error_validation': 'Validation Error',
    'auth_error_invalid_credentials': 'Invalid credentials',
    'auth_error_enter_mobile': 'Please enter mobile number',
    'auth_error_enter_valid_mobile': 'Please enter a valid 10-digit mobile number',
    'auth_error_enter_password': 'Please enter password',
    'nav_family': 'Family',
    'nav_find_member': 'Find Member',
    'nav_committee': 'Committee',
    'nav_payment': 'Payment',
    'nav_occupation': 'Occupation Directory',
    'nav_contact_us': 'Contact Us',
    'nav_matrimonial': 'Matrimonial',
    'nav_support': 'Support',
    'nav_share': 'Share App',
    'nav_samaj_info': 'Samaj Profile',
    'matrimonial_marriage': 'Marriage',
    'matrimonial_looking_for': 'Looking for Marriage',
    'matrimonial_unmarried_male': 'Unmarried Male',
    'matrimonial_unmarried_female': 'Unmarried Female',
    'profile_address': 'Address',
    'profile_asset_life': 'Asset and Life',
    'profile_social_media': 'Social Media',
    'payment_make': 'Make Payment',
    'payment_history': 'Payment History',
    'payment_receipt': 'Payment Receipt',
    'payment_amount': 'Amount',
    'update_available': 'Update Available',
    'update_now': 'Update Now',
    'update_later': 'Update Later',
    'nav_privacy_policy': 'Privacy Policy',
    'support_need_help': 'Need help?',
    'common_search_hint': 'Search...',
    'common_showing': 'Showing',
    'common_members_count': 'Members',
    'common_courtesy': 'Courtesy',
    'common_social': 'Social',
    'common_devotion': 'Devotion',
    'payment_annual_membership': 'Annual Membership',
    'common_male': 'Male',
    'common_female': 'Female',
    'common_self': 'Self',
    'common_wife': 'Wife',
    'common_married': 'Married',
    'common_unmarried': 'Unmarried',
    'common_families_count': 'Families',
    'common_success': 'Success',
    'matrimonial_looking_for_label': 'Looking for Marriage',
    'matrimonial_unmarried': 'Unmarried',
    'matrimonial_married': 'Married',
    'matrimonial_widow': 'Widow',
    'matrimonial_widower': 'Widower',
    'matrimonial_divorced': 'Divorced',
    'matrimonial_any': 'Any',
    'matrimonial_all': 'All',
}

restore_aliases('assets/locales/en_US.json', mappings)
restore_aliases('assets/locales/gu_IN.json', mappings)
print("Aliases restored successfully.")
