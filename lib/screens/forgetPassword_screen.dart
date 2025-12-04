import 'package:flutter/material.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/screens/getCode_screen.dart';

class ForgetpasswordScreen extends StatefulWidget {
  const ForgetpasswordScreen({super.key});

  @override
  State<ForgetpasswordScreen> createState() => _ForgetpasswordScreenState();
}

class _ForgetpasswordScreenState extends State<ForgetpasswordScreen> {
  final TextEditingController _getCodeEmailController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFFF9F9F9)),
      backgroundColor: Color(0xFFF9F9F9),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Text(
                  " Forgot\n Password?",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.mail),
                  labelText: "Enter your email address",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email address";
                  }
                  if (!value.contains("@")) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: const TextSpan(
                    text: "* ",
                    style: TextStyle(
                      fontSize: 18,

                      color: Color.fromARGB(255, 255, 59, 59),
                    ),

                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "A code will be sent to your email address to reset your password",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Color(0xFF2449DE),
                  ),
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      _getCodeEmailController.clear();

                      showMySnackBar(
                        context: context,
                        message: "Code sent to your gmail.",
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GetcodeScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(fontSize: 20, color: Colors.white),
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
