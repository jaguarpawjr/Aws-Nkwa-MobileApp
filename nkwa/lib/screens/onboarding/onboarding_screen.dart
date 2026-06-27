import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/progress_repository.dart';
import '../signup/signup_screen.dart';
import 'onboarding_page_data.dart';
import 'widgets/animated_illustration.dart';

// ─── Brand tokens ────────────────────────────────────────────────
const _inkDeep = AppColors.inkDeep;
const _violet = AppColors.red;
const _violetSoft = AppColors.redSoft;
const _lavender = AppColors.redLight;
const _gold = AppColors.gold;
const _surface = AppColors.surface;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  final _progressRepository = ProgressRepository();
  int _currentPage = 0;

  // Text reveal animation (runs on every page change)
  late AnimationController _textReveal;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // Floating illustration animation (continuous)
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // Forward-button pulse (continuous)
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _textReveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _textFade = CurvedAnimation(parent: _textReveal, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textReveal, curve: Curves.easeOutCubic));
    _textReveal.forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textReveal.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await _progressRepository.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _textReveal
      ..reset()
      ..forward();
  }

  void _goToNextPage() {
    if (_currentPage == onboardingPages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          // ── Background blobs ────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(
              color: _violet.withValues(alpha: 0.18),
              size: 280.r,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _GlowBlob(
              color: _lavender.withValues(alpha: 0.22),
              size: 240.r,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Step counter
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _violetSoft,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${_currentPage + 1} / ${onboardingPages.length}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: _violet,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: _violet,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Progress bar ────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _AnimatedProgressBar(
                    progress: (_currentPage + 1) / onboardingPages.length,
                  ),
                ),

                SizedBox(height: 8.h),

                // ── Illustration ─────────────────────────────────
                Expanded(
                  flex: 5,
                  child: AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Padding(
                        key: ValueKey(_currentPage),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: AnimatedIllustration(
                          assetPath: onboardingPages[_currentPage].imagePath,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Wave divider ─────────────────────────────────
                SizedBox(
                  height: 40.h,
                  width: double.infinity,
                  child: CustomPaint(painter: _WavePainter()),
                ),

                // ── Text card ────────────────────────────────────
                Expanded(
                  flex: 4,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingPages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, index) {
                      final page = onboardingPages[index];
                      return FadeTransition(
                        opacity: _textFade,
                        child: SlideTransition(
                          position: _textSlide,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                padding: EdgeInsets.symmetric(horizontal: 32.w),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4.h),
                                      Text(
                                        page.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w800,
                                          color: _inkDeep,
                                          height: 1.2,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(height: 14.h),
                                      Text(
                                        page.description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF6B6480),
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Nav row ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Row(
                    children: [
                      // Back button (hidden on first page)
                      AnimatedOpacity(
                        opacity: _currentPage == 0 ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: _currentPage == 0,
                          child: _CircleBack(onTap: _goToPreviousPage),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Forward / Get-started pill
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, child) => Transform.scale(
                            scale: isLast ? _pulseAnim.value : 1.0,
                            child: child,
                          ),
                          child: _ForwardPill(
                            isLast: isLast,
                            onTap: _goToNextPage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Dot indicators ───────────────────────────────
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (i) => _Dot(active: i == _currentPage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  const _AnimatedProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3.h,
      decoration: BoxDecoration(
        color: _violetSoft,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          widthFactor: progress,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              gradient: const LinearGradient(colors: [_violet, _gold]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: active ? 22.w : 7.w,
      height: 7.h,
      decoration: BoxDecoration(
        color: active ? _violet : _lavender,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _violetSoft,
          border: Border.all(color: _lavender, width: 1.5),
        ),
        child: Icon(Icons.arrow_back_rounded, color: _violet, size: 22.r),
      ),
    );
  }
}

class _ForwardPill extends StatelessWidget {
  const _ForwardPill({required this.isLast, required this.onTap});
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 52.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            colors: [_violet, Color(0xFF5B21B6)],
          ),
          boxShadow: [
            BoxShadow(
              color: _violet.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Get Started' : 'Next',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ─── Wave divider painter ─────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _violetSoft
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.1,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.9,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => false;
}
