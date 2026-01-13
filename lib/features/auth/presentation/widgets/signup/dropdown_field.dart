import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const DropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  bool _isOpen = false;

  Future<String?> _showPicker({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String? selected,
  }) async {
    if (!mounted) return null;
    setState(() => _isOpen = true);

    final result = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DropdownBottomSheet(
          title: title,
          items: items,
          selected: selected,
        );
      },
    );

    if (!mounted) return result;
    setState(() => _isOpen = false);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.value,
      validator: widget.validator,
      builder: (state) {
        final theme = Theme.of(context);

        final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
        final fillColor = theme.colorScheme.surface;

        final hasValidValue = state.value == null
            ? true
            : widget.items.contains(state.value);
        if (!hasValidValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.value != null && !widget.items.contains(state.value)) {
              state.didChange(null);
            }
          });
        }

        final effectiveValue = widget.enabled && hasValidValue
            ? state.value
            : null;

        final displayText = effectiveValue ?? widget.hintText;
        final displayStyle = theme.textTheme.bodyMedium?.copyWith(
          color: effectiveValue == null
              ? muted
              : (widget.enabled
                    ? theme.colorScheme.onSurface
                    : muted.withValues(alpha: 0.5)),
          fontWeight: effectiveValue == null
              ? FontWeight.w500
              : FontWeight.w700,
        );

        return InputDecorator(
          decoration: InputDecoration(
            errorText: state.errorText,
            isDense: true,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
          isFocused: _isOpen,
          isEmpty: effectiveValue == null,
          child: InkWell(
            onTap: (!widget.enabled || widget.items.isEmpty)
                ? null
                : () async {
                    final picked = await _showPicker(
                      context: context,
                      title: widget.hintText,
                      items: widget.items,
                      selected: effectiveValue,
                    );
                    if (picked == null) return;
                    state.didChange(picked);
                    widget.onChanged(picked);
                  },
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: displayStyle,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: widget.enabled ? muted : muted.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DropdownBottomSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selected;

  const _DropdownBottomSheet({
    required this.title,
    required this.items,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final height = MediaQuery.sizeOf(context).height * 0.55;

    return SafeArea(
      top: false,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selected;

                  final bg = isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.10)
                      : theme.colorScheme.surface;
                  final border = isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.45)
                      : theme.dividerColor.withValues(alpha: 0.25);

                  return Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).pop(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: muted.withValues(alpha: 0.55),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
