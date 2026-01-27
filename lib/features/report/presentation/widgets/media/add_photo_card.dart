import 'package:flutter/material.dart';

class AddPhotoCard extends StatelessWidget {
  const AddPhotoCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: borderRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, size: 30, color: Colors.grey),
              SizedBox(height: 8),
              Text('Add Photo', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
