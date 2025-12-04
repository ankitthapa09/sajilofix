import 'package:flutter/material.dart';

class GetcodeScreen extends StatefulWidget {
  const GetcodeScreen({super.key});

  @override
  State<GetcodeScreen> createState() => _GetcodeScreenState();
}

class _GetcodeScreenState extends State<GetcodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 1, horizontal: 18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/verified.png",
                  width: 200,
                  height: 200,
                ),
              ],
            ),
            Text(
              "Enter verification code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 9),
            Text(
              "We've sent a 6-digit code to",
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 111, 109, 109),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
