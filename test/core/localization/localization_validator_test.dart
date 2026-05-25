import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/core/localization/localization_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'LocalizationValidator should not throw exceptions on valid JSON',
    () async {
      // This assumes the actual assets are valid
      await expectLater(LocalizationValidator.validate(), completes);
    },
  );
}
