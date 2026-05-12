import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

void main() {
  group('Translation Keys Integrity Tests', () {
    test('All LK.allValues must exist as keys in en_US.json', () {
      final file = File('assets/locales/en_US.json');
      final content = file.readAsStringSync();
      final Map<String, dynamic> translations =
          json.decode(content) as Map<String, dynamic>;


      for (final value in LK.allValues) {
        expect(
          translations.containsKey(value),
          true,
          reason: 'Key "$value" (from LK.allValues) is missing from en_US.json',
        );
      }
    });

    test('All LK.allValues must exist as keys in gu_IN.json', () {
      final file = File('assets/locales/gu_IN.json');
      final content = file.readAsStringSync();
      final Map<String, dynamic> translations =
          json.decode(content) as Map<String, dynamic>;


      for (final value in LK.allValues) {
        expect(
          translations.containsKey(value),
          true,
          reason: 'Key "$value" (from LK.allValues) is missing from gu_IN.json',
        );
      }
    });

    test('LK.allValues should not have duplicates', () {
      final distinct = LK.allValues.toSet().toList();
      expect(LK.allValues.length, distinct.length, reason: 'Duplicate keys found in LK.allValues');
    });
  });

  group('Dropdown and Status Keys Coverage Tests', () {
    const marriageFilterValues = [
      'All', 'Male', 'Female', 'Unmarried', 
      'Married', 'Widow', 'Divorced', 'Looking for Marriage', 'Active'
    ];

    const committeeRolesAndStatuses = [
      'Active', 'Inactive', 'President', 'Vice President', 
      'Secretary', 'Joint Secretary', 'Treasurer', 'Committee Member'
    ];

    test('all marriage filter values exist in en_US.json', () {
      final file = File('assets/locales/en_US.json');
      final content = file.readAsStringSync();
      final Map<String, dynamic> translations = json.decode(content) as Map<String, dynamic>;

      for (final val in marriageFilterValues) {
        expect(
          translations.containsKey(val), 
          isTrue, 
          reason: 'Marriage filter value "$val" is missing from en_US.json'
        );
      }
    });

    test('all marriage filter values exist in gu_IN.json', () {
      final file = File('assets/locales/gu_IN.json');
      final content = file.readAsStringSync();
      final Map<String, dynamic> translations = json.decode(content) as Map<String, dynamic>;

      for (final val in marriageFilterValues) {
        expect(
          translations.containsKey(val), 
          isTrue, 
          reason: 'Marriage filter value "$val" is missing from gu_IN.json'
        );
      }
    });

    test('all committee roles and statuses exist in en_US.json', () {
      final file = File('assets/locales/en_US.json');
      final content = file.readAsStringSync();
      final Map<String, dynamic> translations = json.decode(content) as Map<String, dynamic>;

      for (final val in committeeRolesAndStatuses) {
        expect(
          translations.containsKey(val), 
          isTrue, 
          reason: 'Role/Status value "$val" is missing from en_US.json'
        );
      }
    });

    test('all committee roles and statuses exist in gu_IN.json', () {
      final file = File('assets/locales/gu_IN.json');
      final content = file.readAsStringSync();
      final Map<String, dynamic> translations = json.decode(content) as Map<String, dynamic>;

      for (final val in committeeRolesAndStatuses) {
        expect(
          translations.containsKey(val), 
          isTrue, 
          reason: 'Role/Status value "$val" is missing from gu_IN.json'
        );
      }
    });
  });
}
