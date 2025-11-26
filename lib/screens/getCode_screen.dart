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
        padding: EdgeInsetsGeometry.symmetric(vertical: 1, horizontal: 20),
      ),
    );
  }
}
