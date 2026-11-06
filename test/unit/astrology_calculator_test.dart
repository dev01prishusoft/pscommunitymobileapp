import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/core/utils/astrology_calculator.dart';
import 'package:pscommunitymobileapp/features/member/controllers/personal_info_controller.dart';

void main() {
  group('AstrologyCalculator - Logic 1 (Western Sun Sign)', () {
    test('Aries: March 21 to April 19 -> ID: 3', () {
      expect(AstrologyCalculator.calculateWesternSunSign(3, 21).id, 3);
      expect(AstrologyCalculator.calculateWesternSunSign(4, 10).id, 3);
      expect(AstrologyCalculator.calculateWesternSunSign(4, 19).id, 3);
      expect(AstrologyCalculator.calculateWesternSunSign(4, 19).englishName, 'Aries');
      expect(AstrologyCalculator.calculateWesternSunSign(4, 19).gujaratiName, 'મેષ');
    });

    test('Taurus: April 20 to May 20 -> ID: 4', () {
      expect(AstrologyCalculator.calculateWesternSunSign(4, 20).id, 4);
      expect(AstrologyCalculator.calculateWesternSunSign(5, 1).id, 4);
      expect(AstrologyCalculator.calculateWesternSunSign(5, 20).id, 4);
      expect(AstrologyCalculator.calculateWesternSunSign(5, 20).englishName, 'Taurus');
      expect(AstrologyCalculator.calculateWesternSunSign(5, 20).gujaratiName, 'વૃષભ');
    });

    test('Gemini: May 21 to June 20 -> ID: 5', () {
      expect(AstrologyCalculator.calculateWesternSunSign(5, 21).id, 5);
      expect(AstrologyCalculator.calculateWesternSunSign(6, 10).id, 5);
      expect(AstrologyCalculator.calculateWesternSunSign(6, 20).id, 5);
      expect(AstrologyCalculator.calculateWesternSunSign(6, 20).englishName, 'Gemini');
      expect(AstrologyCalculator.calculateWesternSunSign(6, 20).gujaratiName, 'મિથુન');
    });

    test('Cancer: June 21 to July 22 -> ID: 17', () {
      expect(AstrologyCalculator.calculateWesternSunSign(6, 21).id, 17);
      expect(AstrologyCalculator.calculateWesternSunSign(7, 1).id, 17);
      expect(AstrologyCalculator.calculateWesternSunSign(7, 22).id, 17);
      expect(AstrologyCalculator.calculateWesternSunSign(7, 22).englishName, 'Cancer');
      expect(AstrologyCalculator.calculateWesternSunSign(7, 22).gujaratiName, 'કર્ક');
    });

    test('Leo: July 23 to August 22 -> ID: 7', () {
      expect(AstrologyCalculator.calculateWesternSunSign(7, 23).id, 7);
      expect(AstrologyCalculator.calculateWesternSunSign(8, 10).id, 7);
      expect(AstrologyCalculator.calculateWesternSunSign(8, 22).id, 7);
      expect(AstrologyCalculator.calculateWesternSunSign(8, 22).englishName, 'Leo');
      expect(AstrologyCalculator.calculateWesternSunSign(8, 22).gujaratiName, 'સિંહ');
    });

    test('Virgo: August 23 to Sept 22 -> ID: 8', () {
      expect(AstrologyCalculator.calculateWesternSunSign(8, 23).id, 8);
      expect(AstrologyCalculator.calculateWesternSunSign(9, 10).id, 8);
      expect(AstrologyCalculator.calculateWesternSunSign(9, 22).id, 8);
      expect(AstrologyCalculator.calculateWesternSunSign(9, 22).englishName, 'Virgo');
      expect(AstrologyCalculator.calculateWesternSunSign(9, 22).gujaratiName, 'કન્યા');
    });

    test('Libra: Sept 23 to October 22 -> ID: 9', () {
      expect(AstrologyCalculator.calculateWesternSunSign(9, 23).id, 9);
      expect(AstrologyCalculator.calculateWesternSunSign(10, 10).id, 9);
      expect(AstrologyCalculator.calculateWesternSunSign(10, 22).id, 9);
      expect(AstrologyCalculator.calculateWesternSunSign(10, 22).englishName, 'Libra');
      expect(AstrologyCalculator.calculateWesternSunSign(10, 22).gujaratiName, 'તુલા');
    });

    test('Scorpio: October 23 to Nov 21 -> ID: 10', () {
      expect(AstrologyCalculator.calculateWesternSunSign(10, 23).id, 10);
      expect(AstrologyCalculator.calculateWesternSunSign(11, 10).id, 10);
      expect(AstrologyCalculator.calculateWesternSunSign(11, 21).id, 10);
      expect(AstrologyCalculator.calculateWesternSunSign(11, 21).englishName, 'Scorpio');
      expect(AstrologyCalculator.calculateWesternSunSign(11, 21).gujaratiName, 'વૃશ્ચિક');
    });

    test('Sagittarius: Nov 22 to December 21 -> ID: 11', () {
      expect(AstrologyCalculator.calculateWesternSunSign(11, 22).id, 11);
      expect(AstrologyCalculator.calculateWesternSunSign(12, 10).id, 11);
      expect(AstrologyCalculator.calculateWesternSunSign(12, 21).id, 11);
      expect(AstrologyCalculator.calculateWesternSunSign(12, 21).englishName, 'Sagittarius');
      expect(AstrologyCalculator.calculateWesternSunSign(12, 21).gujaratiName, 'ધનુ');
    });

    test('Capricorn: Dec 22 to January 19 -> ID: 12', () {
      expect(AstrologyCalculator.calculateWesternSunSign(12, 22).id, 12);
      expect(AstrologyCalculator.calculateWesternSunSign(1, 1).id, 12);
      expect(AstrologyCalculator.calculateWesternSunSign(1, 19).id, 12);
      expect(AstrologyCalculator.calculateWesternSunSign(1, 19).englishName, 'Capricorn');
      expect(AstrologyCalculator.calculateWesternSunSign(1, 19).gujaratiName, 'મકર');
    });

    test('Aquarius: January 20 to Feb 18 -> ID: 13', () {
      expect(AstrologyCalculator.calculateWesternSunSign(1, 20).id, 13);
      expect(AstrologyCalculator.calculateWesternSunSign(2, 5).id, 13);
      expect(AstrologyCalculator.calculateWesternSunSign(2, 18).id, 13);
      expect(AstrologyCalculator.calculateWesternSunSign(2, 18).englishName, 'Aquarius');
      expect(AstrologyCalculator.calculateWesternSunSign(2, 18).gujaratiName, 'કુંભ');
    });

    test('Pisces: February 19 to March 20 -> ID: 14', () {
      expect(AstrologyCalculator.calculateWesternSunSign(2, 19).id, 14);
      expect(AstrologyCalculator.calculateWesternSunSign(3, 5).id, 14);
      expect(AstrologyCalculator.calculateWesternSunSign(3, 20).id, 14);
      expect(AstrologyCalculator.calculateWesternSunSign(3, 20).englishName, 'Pisces');
      expect(AstrologyCalculator.calculateWesternSunSign(3, 20).gujaratiName, 'મીન');
    });
  });

  group('AstrologyCalculator - Logic 2 (Indian Vedic Moon Sign)', () {
    test('1995-08-15 10:30 IST -> Meena (Pisces / મીન) -> ID: 14', () {
      final sign = AstrologyCalculator.calculateVedicMoonSign(1995, 8, 15, 10, 30);
      expect(sign.id, 14);
      expect(sign.englishName, 'Pisces');
      expect(sign.gujaratiName, 'મીન');
      expect(sign.sanskritName, 'Meena');
      expect(sign.isVedic, true);
    });

    test('2000-01-01 12:00 IST -> Tula (Libra / તુલા) -> ID: 9', () {
      final sign = AstrologyCalculator.calculateVedicMoonSign(2000, 1, 1, 12, 0);
      expect(sign.id, 9);
      expect(sign.englishName, 'Libra');
      expect(sign.gujaratiName, 'તુલા');
      expect(sign.sanskritName, 'Tula');
      expect(sign.isVedic, true);
    });

    test('2023-10-24 18:45 IST -> Kumbha (Aquarius / કુંભ) -> ID: 13', () {
      final sign = AstrologyCalculator.calculateVedicMoonSign(2023, 10, 24, 18, 45);
      expect(sign.id, 13);
      expect(sign.englishName, 'Aquarius');
      expect(sign.gujaratiName, 'કુંભ');
      expect(sign.sanskritName, 'Kumbha');
      expect(sign.isVedic, true);
    });

    test('2026-11-02 17:00 IST -> Karka (Cancer / કર્ક) -> ID: 17', () {
      final sign = AstrologyCalculator.calculateVedicMoonSign(2026, 11, 2, 17, 0);
      expect(sign.id, 17);
      expect(sign.englishName, 'Cancer');
      expect(sign.gujaratiName, 'કર્ક');
      expect(sign.sanskritName, 'Karka');
      expect(sign.isVedic, true);
    });
  });

  group('AstrologyCalculator - calculateSignFromStrings (Auto Switch)', () {
    test('DOB only -> switches to Western Sun Sign', () {
      final sign = AstrologyCalculator.calculateSignFromStrings(
        dobString: '15-08-1995',
        tobString: '',
      );
      expect(sign, isNotNull);
      expect(sign!.id, 7); // Leo (Aug 15)
      expect(sign.englishName, 'Leo');
      expect(sign.isVedic, false);
    });

    test('DOB and TOB -> switches to Indian Vedic Moon Sign', () {
      final sign = AstrologyCalculator.calculateSignFromStrings(
        dobString: '15-08-1995',
        tobString: '10:30',
      );
      expect(sign, isNotNull);
      expect(sign!.id, 14); // Pisces (Vedic Moon)
      expect(sign.englishName, 'Pisces');
      expect(sign.isVedic, true);
    });

    test('Handles 12-hour AM/PM string formats', () {
      final signAm = AstrologyCalculator.calculateSignFromStrings(
        dobString: '15-08-1995',
        tobString: '10:30 AM',
      );
      expect(signAm, isNotNull);
      expect(signAm!.id, 14);

      final signPm = AstrologyCalculator.calculateSignFromStrings(
        dobString: '24-10-2023',
        tobString: '06:45 PM',
      );
      expect(signPm, isNotNull);
      expect(signPm!.id, 13);
    });

    test('Handles ISO / yyyy-MM-dd DOB format', () {
      final sign = AstrologyCalculator.calculateSignFromStrings(
        dobString: '1995-08-15',
        tobString: '10:30:00',
      );
      expect(sign, isNotNull);
      expect(sign!.id, 14);
    });

    test('Returns null on empty DOB', () {
      expect(AstrologyCalculator.calculateSignFromStrings(dobString: ''), isNull);
      expect(AstrologyCalculator.calculateSignFromStrings(dobString: null), isNull);
    });
  });

  group('PersonalInfoController - Auto-Selection Integration', () {
    test('Selecting DOB auto-selects Western Sun Sign', () {
      final controller = PersonalInfoController();
      controller.onInit();

      controller.dobCtrl.text = '15-08-1995';
      expect(controller.sign.value, 'Leo');

      controller.onClose();
    });

    test('Entering TOB switches to Indian Vedic Moon Sign', () {
      final controller = PersonalInfoController();
      controller.onInit();

      controller.dobCtrl.text = '15-08-1995';
      expect(controller.sign.value, 'Leo');

      controller.tobCtrl.text = '10:30';
      expect(controller.sign.value, 'Pisces');

      // Clearing TOB switches back to Western Sun Sign
      controller.tobCtrl.text = '';
      expect(controller.sign.value, 'Leo');

      controller.onClose();
    });

    test('Selects matching key in signIdMap when backend dropdown is in Gujarati', () {
      final controller = PersonalInfoController();
      controller.onInit();

      // Simulate backend /Sign/dropdown loaded with Gujarati names
      controller.signIdMap.addAll({
        'મેષ': 3,
        'વૃષભ': 4,
        'મિથુન': 5,
        'કર્ક': 17,
        'સિંહ': 7,
        'કન્યા': 8,
        'તુલા': 9,
        'વૃશ્ચિક': 10,
        'ધનુ': 11,
        'મકર': 12,
        'કુંભ': 13,
        'મીન': 14,
      });
      controller.signList.addAll(controller.signIdMap.keys);

      // Set DOB + TOB -> Pisces (ID: 14)
      controller.dobCtrl.text = '15-08-1995';
      controller.tobCtrl.text = '10:30';

      // Must select the Gujarati key 'મીન' from signIdMap
      expect(controller.sign.value, 'મીન');

      // Set DOB only -> Leo (ID: 7)
      controller.tobCtrl.text = '';
      expect(controller.sign.value, 'સિંહ');

      controller.onClose();
    });
  });
}

