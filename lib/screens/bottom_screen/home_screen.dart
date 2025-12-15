import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset("assets/images/sajilofix_logo.png", height: 100),
                ],
              ),
              const Text(
                "Hello, Ankit 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              const Text(
                "Report problems around your community.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Report Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF041027), Color(0xFF3533cd)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Report an Issue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tap to capture and submit",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _CategoryItem(icon: Icons.streetview, label: "Road Damage"),
                  _CategoryItem(icon: Icons.lightbulb, label: "Street Light"),
                  _CategoryItem(icon: Icons.water_drop, label: "Water"),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Your Reports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _reportCard(
                title: "Road Pothole",
                location: "Kalanki",
                status: "Pending",
              ),

              const SizedBox(height: 12),

              _reportCard(
                title: "Street Light Issue",
                location: "Pulchowk",
                status: "Pending",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required String location,
    required String status,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(title),
        subtitle: Text(location),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: const TextStyle(color: Colors.orange)),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
