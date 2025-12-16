import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LocationCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueGrey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: Text("edit")),
        ],
      ),
    );
  }
}
