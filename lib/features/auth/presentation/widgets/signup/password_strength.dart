enum PasswordStrength { none, weak, medium, strong }

PasswordStrength passwordStrength(String value) {
  final v = value.trim();
  final hasUpper = v.contains(RegExp(r'[A-Z]'));
  final hasLower = v.contains(RegExp(r'[a-z]'));
  final hasDigit = v.contains(RegExp(r'\d'));
  final longEnough = v.length >= 8;

  final score = [
    hasUpper,
    hasLower,
    hasDigit,
    longEnough,
  ].where((e) => e).length;
  if (v.isEmpty) return PasswordStrength.none;
  if (score <= 1) return PasswordStrength.weak;
  if (score == 2) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
