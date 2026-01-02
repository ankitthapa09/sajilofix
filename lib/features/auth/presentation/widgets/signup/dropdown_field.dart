import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const DropdownField({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        final theme = Theme.of(context);

        return InputDecorator(
          decoration: InputDecoration(
            hintText: hintText,
            errorText: state.errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.value,
              isExpanded: true,
              hint: Text(hintText, style: theme.textTheme.bodyMedium),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (v) {
                state.didChange(v);
                onChanged(v);
              },
            ),
          ),
        );
      },
    );
  }
}
