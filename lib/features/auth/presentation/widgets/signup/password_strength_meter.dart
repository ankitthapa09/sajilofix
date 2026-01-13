import 'package:flutter/material.dart';

import 'password_strength.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  final String? labelPrefix;

  const PasswordStrengthMeter({
    super.key,
    required this.strength,
    this.labelPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final strengthText = switch (strength) {
      PasswordStrength.none => '',
      PasswordStrength.weak => 'Weak',
      PasswordStrength.medium => 'Medium',
      PasswordStrength.strong => 'Strong',
    };

    final strengthColor = switch (strength) {
      PasswordStrength.none => Colors.transparent,
      PasswordStrength.weak => Colors.red,
      PasswordStrength.medium => Colors.orange,
      PasswordStrength.strong => Colors.green,
    };

    final strengthValue = switch (strength) {
      PasswordStrength.none => 0.0,
      PasswordStrength.weak => 0.33,
      PasswordStrength.medium => 0.66,
      PasswordStrength.strong => 1.0,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (strength != PasswordStrength.none)
          Row(
            children: [
              Text(
                labelPrefix ?? 'Password strength:',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(width: 6),
              Text(
                strengthText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: strengthValue,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              strength == PasswordStrength.none
                  ? Colors.transparent
                  : strengthColor,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
