/// The Register form's old validator only checked the *shape*
/// `\d{2}/\d{2}/\d{4}` — that accepts "00/00/0000" because it's shaped
/// like a date without being one. This checks it's an actual calendar
/// date by round-tripping it through DateTime and rejecting anything
/// that doesn't survive, plus sanity-checks the year separately (DateTime
/// itself won't reject year 0000 as "invalid," it just becomes 1 BC).
class DateValidators {
  DateValidators._();

  static final _shapeRegex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

  /// Returns an error message, or null if [input] is a real, plausible
  /// date of birth in MM/DD/YYYY.
  static String? dateOfBirth(String? input) {
    if (input == null || input.isEmpty) return 'Date of birth is required';

    final match = _shapeRegex.firstMatch(input);
    if (match == null) return 'Use MM/DD/YYYY';

    final month = int.parse(match.group(1)!);
    final day = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    if (year < 1900 || year > DateTime.now().year) {
      return 'Enter a real year';
    }
    if (month < 1 || month > 12) return 'Enter a real month (01–12)';
    if (day < 1) return 'Enter a real day';

    // The actual calendar check: DateTime silently rolls "Feb 30" forward
    // into March, so constructing it and checking the fields survived
    // unchanged is what catches both 00/00/0000 and impossible-but-shaped
    // dates like 02/30/2024.
    final asDate = DateTime(year, month, day);
    final isRealDate =
        asDate.year == year && asDate.month == month && asDate.day == day;
    if (!isRealDate) return 'That date doesn\'t exist';

    if (asDate.isAfter(DateTime.now())) return 'Date of birth can\'t be in the future';

    return null;
  }
}
