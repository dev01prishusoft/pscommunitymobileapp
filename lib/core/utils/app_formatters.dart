import 'package:flutter/services.dart';

class DecimalAutoInsertFormatter extends TextInputFormatter {
  DecimalAutoInsertFormatter({
    this.maxIntegerDigits = 3,
    this.maxDecimalDigits = 2,
  });

  final int maxIntegerDigits;
  final int maxDecimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String newText = newValue.text;

    // Check if the input has a decimal point
    if (newText.contains('.')) {
      final parts = newText.split('.');
      if (parts.length > 2) {
        return oldValue; // Multiple decimals not allowed
      }

      final integerPart = parts[0];
      final decimalPart = parts[1];

      // Integer part exceeds max length
      if (integerPart.length > maxIntegerDigits) {
        return oldValue;
      }

      // Decimal part exceeds max length
      if (decimalPart.length > maxDecimalDigits) {
        return oldValue;
      }

      return newValue;
    } else {
      // No decimal point
      if (newText.length > maxIntegerDigits) {
        // Auto-insert decimal point
        final integerPart = newText.substring(0, maxIntegerDigits);
        final decimalPart = newText.substring(maxIntegerDigits);

        if (decimalPart.length > maxDecimalDigits) {
          // If still exceeds, reject
          return oldValue;
        }

        final insertedText = '$integerPart.$decimalPart';
        return TextEditingValue(
          text: insertedText,
          selection: TextSelection.collapsed(offset: insertedText.length),
        );
      }

      return newValue;
    }
  }
}
