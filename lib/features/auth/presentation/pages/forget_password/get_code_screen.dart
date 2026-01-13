import 'package:flutter/material.dart';
import 'package:sajilofix/app/routes/app_routes.dart';
import 'package:sajilofix/common/sajiloFix_snackbar.dart';
import 'package:sajilofix/core/widgets/gradiant_elevated_button.dart';
import 'package:sajilofix/core/widgets/otpbox_widget.dart';

class GetcodeScreen extends StatefulWidget {
  const GetcodeScreen({super.key});

  @override
  State<GetcodeScreen> createState() => _GetcodeScreenState();
}

class _GetcodeScreenState extends State<GetcodeScreen> {
  // 6 ota OTP box ko lagi controllers
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // 6 ota focus nodes
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
              "We've sent a 6-digit code to your email",
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 111, 109, 109),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => OtpboxWidget(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  index: index,
                  focusNodes: _focusNodes,
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: GradientElevatedButton(
                onPressed: () {
                  String otp = _controllers.map((e) => e.text).join();
                  if (otp.length != 6) {
                    showMySnackBar(
                      context: context,
                      message: "Please enter 6 digit OTP",
                    );
                    return;
                  }

                  showMySnackBar(
                    context: context,
                    message: "You can now reset your password",
                  );

                  Navigator.pushNamed(context, AppRoutes.resetPassword);
                },
                text: 'Verify Code',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
