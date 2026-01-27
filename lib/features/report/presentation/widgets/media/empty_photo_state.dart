import 'package:flutter/material.dart';

class EmptyPhotoState extends StatelessWidget {
  const EmptyPhotoState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Icon(Icons.camera_alt_outlined, size: 70, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          'No photos added yet',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 6),
        Text(
          'Add at least one photo to continue',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
