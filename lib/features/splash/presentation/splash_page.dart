import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilofix/core/constants/hero_tags.dart';
import 'package:sajilofix/features/auth/presentation/providers/auth_providers.dart';
import 'package:sajilofix/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sajilofix/features/onboarding/presentation/pages/onboarding_page1.dart';
//import 'package:sajilofix/screens/signup_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _loaderController;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    Timer(const Duration(seconds: 4), _routeFromSplash);
  }

  @override
  void dispose() {
    _loaderController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _routeFromSplash() async {
    try {
      final user = await ref.read(currentUserProvider.future);
      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          _smoothFadeRoute(const CitizenDashboard(initialIndex: 0)),
        );
      } else {
        Navigator.of(
          context,
        ).pushReplacement(_smoothFadeRoute(const OnboardingScreen()));
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(_smoothFadeRoute(const OnboardingScreen()));
    }
  }

  Route<void> _smoothFadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 650),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGradient = LinearGradient(
      colors: [Color(0xFF3533CD), Color(0xFF041027), Color(0xFF3533CD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF8FAFF),
              const Color(0xFFF3F5FF),
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      final t = Curves.easeInOut.transform(
                        _logoController.value,
                      );
                      final scale = 0.96 + (1.0 - 0.96) * t;
                      final opacity = 0.90 + (1.0 - 0.90) * t;

                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(scale: scale, child: child),
                      );
                    },
                    child: Hero(
                      tag: HeroTags.appLogo,
                      child: Image.asset(
                        'assets/images/sajilofix_logo.png',
                        width: 250,
                        height: 250,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _GradientSpinner(
                    controller: _loaderController,
                    gradient: brandGradient,
                    size: 44,
                    strokeWidth: 5,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Loading…',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientSpinner extends StatelessWidget {
  final AnimationController controller;
  final LinearGradient gradient;
  final double size;
  final double strokeWidth;

  const _GradientSpinner({
    required this.controller,
    required this.gradient,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.10);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.square(size),
          painter: _GradientSpinnerPainter(
            t: controller.value,
            gradient: gradient,
            strokeWidth: strokeWidth,
            trackColor: muted,
          ),
        );
      },
    );
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  final double t;
  final LinearGradient gradient;
  final double strokeWidth;
  final Color trackColor;

  const _GradientSpinnerPainter({
    required this.t,
    required this.gradient,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradient.colors,
        stops: _normalizeStops(gradient.stops, gradient.colors.length),
      ).createShader(rect);

    // Rotate the gradient + arc together for a smooth “premium” spinner.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);

    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * 1.35;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    canvas.restore();
  }

  List<double>? _normalizeStops(List<double>? stops, int colorsLength) {
    if (stops != null && stops.length == colorsLength) return stops;
    return null;
  }

  @override
  bool shouldRepaint(covariant _GradientSpinnerPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.gradient != gradient;
  }
}
