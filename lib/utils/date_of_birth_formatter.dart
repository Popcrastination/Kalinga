import 'package:flutter/services.dart';

/// Auto-inserts slashes as the user types a date of birth, so the field
/// fills in as MM/DD/YYYY without the user typing the separators.
/// Used on the Register screen only — not shared, so it lives in utils/
/// rather than widgets/.
class DateOfBirthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digitsOnly.length > 8 ? digitsOnly.substring(0, 8) : digitsOnly;

    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      final isMonthBoundary = i == 1;
      final isDayBoundary = i == 3;
      if ((isMonthBoundary || isDayBoundary) && i != limited.length - 1) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
