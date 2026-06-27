import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/progress_repository.dart';
import '../otp/otp_screen.dart';
import '../sign_in/sign_in_screen.dart';

const _ghanaRegions = [
  'Greater Accra',
  'Ashanti',
  'Western',
  'Central',
  'Eastern',
  'Volta',
  'Northern',
  'Upper East',
  'Upper West',
  'Bono',
  'Bono East',
  'Ahafo',
  'Savannah',
  'North East',
  'Oti',
  'Western North',
];

// Light border used on all idle fields — matches the screenshot's subtle outline
const _fieldBorder = Color(0xFFE5E0F5);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController    = TextEditingController();
  final _phoneController    = TextEditingController();
  final _addressController  = TextEditingController();
  final _passwordController = TextEditingController();
  final _regionFieldKey     = GlobalKey<FormFieldState<String>>();

  String? _selectedRegion;
  bool    _obscurePassword  = true;
  double  _passwordStrength = 0;
  String  _strengthLabel    = '';
  Color   _strengthColor    = AppColors.redLight;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    final score = _calculateStrength(value);
    setState(() {
      switch (score) {
        case 0:
          _passwordStrength = 0;
          _strengthLabel    = '';
          _strengthColor    = AppColors.redLight;
        case 1:
          _passwordStrength = 0.25;
          _strengthLabel    = 'Weak';
          _strengthColor    = const Color(0xFFEF4444);
        case 2:
          _passwordStrength = 0.5;
          _strengthLabel    = 'Medium';
          _strengthColor    = AppColors.gold;
        case 3:
          _passwordStrength = 0.75;
          _strengthLabel    = 'Strong';
          _strengthColor    = const Color(0xFF10B981);
        default:
          _passwordStrength = 1;
          _strengthLabel    = 'Very strong';
          _strengthColor    = AppColors.red;
      }
    });
  }

  int _calculateStrength(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 6) score++;
    if (value.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value) || RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) score++;
    return score.clamp(1, 4);
  }

  Future<void> _pickRegion() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            itemCount: _ghanaRegions.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: _fieldBorder),
            itemBuilder: (context, index) {
              final region = _ghanaRegions[index];
              return ListTile(
                title: Text(region),
                trailing: _selectedRegion == region
                    ? Icon(Icons.check, color: AppColors.red)
                    : null,
                onTap: () => Navigator.of(context).pop(region),
              );
            },
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _selectedRegion = selected);
      _regionFieldKey.currentState?.didChange(selected);
    }
  }

  // ── No validation — navigate straight to OTP ──────────────────
  Future<void> _submit() async {
    await ProgressRepository().completeSignup();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OtpScreen()),
    );
  }

  void _goToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Purple header ────────────────────────────────────────
          _Header(onBack: () => Navigator.of(context).maybePop()),

          // ── Scrollable form body ─────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 40.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Full name'),
                    _buildTextField(
                      controller: _fullNameController,
                      hint: 'Ama Boateng',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 20.h),
                    _FieldLabel('Email address'),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20.h),
                    _FieldLabel('Phone number'),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CountryCodeBox(),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              hint: '24 000 0000',
                              icon: Icons.call_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _FieldLabel('Region'),
                    FormField<String>(
                      key: _regionFieldKey,
                      builder: (state) {
                        return _RegionField(
                          value: _selectedRegion,
                          onTap: _pickRegion,
                          hasError: false,
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    _FieldLabel('Home address'),
                    _buildTextField(
                      controller: _addressController,
                      hint: 'Street, neighbourhood, landmark...',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                    ),
                    SizedBox(height: 20.h),
                    _FieldLabel('Password'),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Create a password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      onChanged: _onPasswordChanged,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.placeholder,
                          size: 20.r,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _PasswordStrengthBar(
                      strength: _passwordStrength,
                      label: _strengthLabel,
                      color: _strengthColor,
                    ),
                    SizedBox(height: 28.h),
                    const _TermsText(),
                    SizedBox(height: 24.h),
                    _CreateAccountButton(onTap: _submit),
                    SizedBox(height: 24.h),
                    const _OrDivider(),
                    SizedBox(height: 20.h),
                    const _SocialButtonsRow(),
                    SizedBox(height: 24.h),
                    _SignInPrompt(onTap: _goToSignIn),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Text field builder ───────────────────────────────────────────
Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  int maxLines = 1,
  Widget? suffixIcon,
  ValueChanged<String>? onChanged,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    maxLines: maxLines,
    onChanged: onChanged,
    // validator intentionally omitted — no validation on this screen
    style: TextStyle(fontSize: 14.sp, color: AppColors.inkDeep),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.placeholder),
      prefixIcon: Icon(icon, size: 20.r, color: AppColors.placeholder),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F3FF),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: _fieldBorder, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: _fieldBorder, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.red, width: 1.5),
      ),
      // Error borders kept in case the form is used elsewhere, but never triggered here
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: TextStyle(fontSize: 11.sp),
    ),
  );
}

// ─── Widgets ──────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft:  Radius.circular(28.r),
        bottomRight: Radius.circular(28.r),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [AppColors.red, AppColors.redDeep],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top:   -30.h,
              right: -30.w,
              child: Container(
                width:  120.w,
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
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width:  36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.chevron_left, color: Colors.white, size: 22.r),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create your account',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Join Nkwa — stay safe, stay connected.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.inkDeep,
        ),
      ),
    );
  }
}

class _CountryCodeBox extends StatelessWidget {
  const _CountryCodeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _fieldBorder, width: 1.0),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🇬🇭', style: TextStyle(fontSize: 18)),
          SizedBox(width: 6.w),
          Text(
            '+233',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
          SizedBox(width: 2.w),
          Icon(Icons.keyboard_arrow_down, size: 16.r, color: AppColors.placeholder),
        ],
      ),
    );
  }
}

class _RegionField extends StatelessWidget {
  const _RegionField({
    required this.value,
    required this.onTap,
    this.hasError = false,
  });
  final String?  value;
  final VoidCallback onTap;
  final bool     hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _fieldBorder, width: 1.0),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20.r, color: AppColors.placeholder),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                value ?? 'Select your region',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: value == null ? AppColors.placeholder : AppColors.inkDeep,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20.r, color: AppColors.placeholder),
          ],
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({
    required this.strength,
    required this.label,
    required this.color,
  });
  final double strength;
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = strength > i / 4;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == 3 ? 0 : 6.w),
                height: 4.h,
                decoration: BoxDecoration(
                  color: filled ? color : _fieldBorder,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            );
          }),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted, height: 1.5),
        children: [
          const TextSpan(text: 'By signing up you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.onTap});
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
            colors: [AppColors.red, AppColors.redDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.red.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'Create account',
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: _fieldBorder, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 12.sp, color: AppColors.placeholder),
          ),
        ),
        Expanded(child: Divider(color: _fieldBorder, thickness: 1)),
      ],
    );
  }
}

class _SocialButtonsRow extends StatelessWidget {
  const _SocialButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            child: Text(
              'G',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4285F4),
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            child: Icon(Icons.apple, size: 18.r, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _fieldBorder, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
