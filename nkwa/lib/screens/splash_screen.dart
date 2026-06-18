import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_flow_step.dart';
import '../core/progress_repository.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'otp/otp_screen.dart';
import 'sign_in/sign_in_screen.dart';
import 'signup/signup_screen.dart';

const _kGradientStart = Color(0xFF6D28D9);
const _kGradientEnd = Color(0xFFB388F5);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _progressRepository = ProgressRepository();

  static const _brandName = 'Nkwa';

  late final AnimationController _iconController;
  late final Animation<Offset> _iconSlide;
  late final Animation<double> _iconFade;

  // One controller drives all letter animations via intervals
  late final AnimationController _lettersController;
  late final List<Animation<double>> _letterFades;
  late final List<Animation<Offset>> _letterSlides;

  late final AnimationController _taglineController;
  late final Animation<double> _taglineFade;

  late final AnimationController _circlesController;
  late final Animation<double> _circlesScale;

  @override
  void initState() {
    super.initState();

    // --- Decorative circles ---
    _circlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _circlesScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _circlesController, curve: Curves.easeOutCubic),
    );

    // --- Icon ---
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic));
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeIn),
    );

    // --- Letters: staggered via a single controller + intervals ---
    // Each letter gets 1/N of the total duration, staggered by index.
    // Total controller duration covers all letters + a little overlap buffer.
    const letterCount = _brandName.length; // 4
    const staggerStep = 0.18; // fraction of total duration between each letter start
    const letterDuration = 0.35; // fraction of total duration each letter animation lasts

    _lettersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _letterFades = List.generate(letterCount, (i) {
      final start = i * staggerStep;
      final end = (start + letterDuration).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _lettersController,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );
    });

    _letterSlides = List.generate(letterCount, (i) {
      final start = i * staggerStep;
      final end = (start + letterDuration).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _lettersController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    // --- Tagline ---
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    _circlesController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    await _iconController.forward();

    await Future.delayed(const Duration(milliseconds: 60));
    await _lettersController.forward();

    await Future.delayed(const Duration(milliseconds: 80));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    await _navigateNext();
  }

  Future<void> _navigateNext() async {
    final step = await _progressRepository.currentStep();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => _screenFor(step)),
    );
  }

  Widget _screenFor(AppFlowStep step) {
    switch (step) {
      case AppFlowStep.onboarding:
        return const OnboardingScreen();
      case AppFlowStep.signup:
        return const SignupScreen();
      case AppFlowStep.otp:
        return const OtpScreen();
      case AppFlowStep.signIn:
        return const SignInScreen();
      case AppFlowStep.home:
        return const HomeScreen();
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _lettersController.dispose();
    _taglineController.dispose();
    _circlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kGradientStart, _kGradientEnd],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60.h,
              right: -60.w,
              child: ScaleTransition(
                scale: _circlesScale,
                child: _DecorativeCircle(size: 220.w),
              ),
            ),
            Positioned(
              bottom: -80.h,
              left: -80.w,
              child: ScaleTransition(
                scale: _circlesScale,
                child: _DecorativeCircle(size: 260.w),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  SlideTransition(
                    position: _iconSlide,
                    child: FadeTransition(
                      opacity: _iconFade,
                      child: Image.asset(
                        'assets/logo.png',
                        width: 90.w,
                        height: 90.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // "Nkwa" — each letter animates in independently
                  ClipRect(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_brandName.length, (i) {
                        return SlideTransition(
                          position: _letterSlides[i],
                          child: FadeTransition(
                            opacity: _letterFades[i],
                            child: Text(
                              _brandName[i],
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 35.h),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: Text(
                        'Help, the moment you need it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}