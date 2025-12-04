import 'package:flutter/material.dart';
import 'package:sajilofix/screens/signup_screen.dart';
import 'package:sajilofix/widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF2449DE), fontSize: 16),
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 30 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Page 1
                  OnboardingPageWidget(
                    icon: Icons.camera_alt,
                    iconColor: Colors.blue.shade600,
                    backgroundColor: Colors.blue.shade50,
                    title: 'Report Issues Easily',
                    description:
                        'Spot a problem? Snap a photo and report\nit in seconds',
                  ),

                  // Page 2
                  OnboardingPageWidget(
                    icon: Icons.location_on,
                    iconColor: Colors.blue.shade600,
                    backgroundColor: Colors.blue.shade50,
                    title: 'Track Your Reports',
                    description:
                        'Monitor progress from submission to\nresolution in real-time',
                  ),

                  // Page 3
                  OnboardingPageWidget(
                    icon: Icons.notifications_active,
                    iconColor: Colors.blue.shade600,
                    backgroundColor: Colors.blue.shade50,
                    title: 'Stay Updated',
                    description:
                        'Get instant notifications when your\nreports are reviewed or resolved',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2449DE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 9,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == 2 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (_currentPage < 2) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
