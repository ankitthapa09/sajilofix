import 'package:flutter/material.dart';

class OtpboxWidget extends StatelessWidget {
  const OtpboxWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.focusNodes,
    required this.index,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final List<FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
    ;
  }
}
