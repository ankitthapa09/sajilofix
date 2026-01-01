import 'package:flutter/material.dart';
import 'package:sajilofix/common/sajiloFix_snackbar.dart';
import 'package:sajilofix/features/auth/presentation/pages/login_page.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool showPass = false;
  bool showConfirmPass = false;

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      showMySnackBar(
        context: context,
        message: "Password Changed Successfully!!",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: const Text(
                      "Reset\nPassword",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Image.asset("assets/images/sajilofix_logo.png", height: 120),
                ],
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _passController,
                obscureText: !showPass,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => showPass = !showPass);
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Enter new password";
                  if (value.length < 6) return "Minimum 6 characters required";
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _confirmController,
                obscureText: !showConfirmPass,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => showConfirmPass = !showConfirmPass);
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return "Confirm your password";
                  if (value != _passController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
