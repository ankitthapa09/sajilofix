import 'package:flutter/material.dart';

Color _snackForegroundFor(Color background) {
  final brightness = ThemeData.estimateBrightnessForColor(background);
  return brightness == Brightness.dark ? Colors.white : const Color(0xFF041027);
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
  IconData? icon,
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
  bool clearCurrent = true,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  final backgroundColor =
      color ?? (isError ? scheme.error : scheme.inverseSurface);
  final foregroundColor = _snackForegroundFor(backgroundColor);

  final messenger = ScaffoldMessenger.of(context);
  if (clearCurrent) {
    messenger.hideCurrentSnackBar();
  }

  return messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 10,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: backgroundColor,
      duration: duration,
      showCloseIcon: true,
      closeIconColor: foregroundColor.withValues(alpha: 0.9),
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: foregroundColor),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: scheme.primary,
            )
          : null,
    ),
  );
}
