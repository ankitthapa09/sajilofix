import 'package:flutter/material.dart';

class AddPhotoCard extends StatelessWidget {
  const AddPhotoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.camera_alt, size: 30, color: Colors.grey),
          SizedBox(height: 8),
          Text("Add Photo", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
