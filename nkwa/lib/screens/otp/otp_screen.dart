import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/progress_repository.dart';
import '../sign_in/sign_in_screen.dart';

const _otpLength = 6;
const _resendSeconds = 30;
const _simulatedOtp = '361234';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsRemaining = _resendSeconds;
  bool _showNotification = false;

  // Notification animation
  late final AnimationController _notifController;
  late final Animation<Offset> _notifSlide;
  late final Animation<double> _notifFade;

  @override
  void initState() {
    super.initState();

    _notifController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _notifSlide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _notifController, curve: Curves.easeOutCubic));
    _notifFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _notifController, curve: Curves.easeIn),
    );

    _startResendTimer();
    _triggerNotification();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _focusNodes) n.dispose();
    _resendTimer?.cancel();
    _notifController.dispose();
    super.dispose();
  }

  Future<void> _triggerNotification() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _showNotification = true);
    await _notifController.forward();

    // Auto-dismiss after 4 seconds
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    await _notifController.reverse();
    setState(() => _showNotification = false);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
    // Re-show notification on resend
    _triggerNotification();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    await ProgressRepository().completeOtp();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FB),
      body: Stack(
        children: [
          Column(
            children: [
              _Header(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 36.h, 24.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // OTP hint label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Enter 6-digit code',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // OTP boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _otpLength,
                          (i) => _OtpDigitBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (v) => _onDigitChanged(i, v),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Resend row
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38.w,
                              height: 38.w,
                              decoration: BoxDecoration(
                                color: AppColors.violet.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.sms_outlined,
                                color: AppColors.violet,
                                size: 18.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: _secondsRemaining == 0 ? _startResendTimer : null,
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                                    children: [
                                      const TextSpan(text: "Didn't get a code? "),
                                      TextSpan(
                                        text: _secondsRemaining > 0
                                            ? 'Resend in 0:${_secondsRemaining.toString().padLeft(2, '0')}'
                                            : 'Resend code',
                                        style: TextStyle(
                                          color: _secondsRemaining > 0
                                              ? AppColors.placeholder
                                              : AppColors.violet,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 36.h),
                      _VerifyButton(onTap: _verify),
                      SizedBox(height: 16.h),

                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(
                          'Change phone number',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.violet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating SMS notification
          if (_showNotification)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              left: 16.w,
              right: 16.w,
              child: SlideTransition(
                position: _notifSlide,
                child: FadeTransition(
                  opacity: _notifFade,
                  child: _SmsNotification(
                    onTap: () {
                      // Auto-fill OTP on tap
                      for (int i = 0; i < _otpLength; i++) {
                        _controllers[i].text = _simulatedOtp[i];
                      }
                      _focusNodes.last.requestFocus();
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notification Banner ────────────────────────────────────────────────────────

class _SmsNotification extends StatelessWidget {
  const _SmsNotification({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // App icon chip
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.violet, AppColors.violetDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.message_rounded, color: Colors.white, size: 20.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        'now',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Your Nkwa OTP code is $_simulatedOtp',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF3C3C43).withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Tap to autofill',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.violet,
                      fontWeight: FontWeight.w600,
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

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28.r),
        bottomRight: Radius.circular(28.r),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.violet, AppColors.violetDeep],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30.h,
              right: -30.w,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.chevron_left, color: Colors.white, size: 22.r),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Verify your number',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    // SizedBox(height: 6.h),
                    // Text(
                    //   'We sent a 6-digit code to your phone.\nCheck your messages to continue.',
                    //   style: TextStyle(
                    //     fontSize: 13.sp,
                    //     color: Colors.white.withValues(alpha: 0.80),
                    //     height: 1.5,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Verify Button ──────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            colors: [AppColors.violet, AppColors.violetDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'Verify',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── OTP Digit Box ──────────────────────────────────────────────────────────────

class _OtpDigitBox extends StatefulWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpDigitBox> createState() => _OtpDigitBoxState();
}

class _OtpDigitBoxState extends State<_OtpDigitBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46.w,
      height: 64.h,
      decoration: BoxDecoration(
        color: _isFocused
            ? AppColors.violet.withValues(alpha: 0.05)
            : filled
                ? AppColors.violet.withValues(alpha: 0.04)
                : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _isFocused
              ? AppColors.violet
              : filled
                  ? AppColors.violet.withValues(alpha: 0.4)
                  : const Color(0xFFE2E2E2),
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: (v) {
          setState(() {});
          widget.onChanged(v);
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.violet,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}