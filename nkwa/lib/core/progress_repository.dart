import 'package:shared_preferences/shared_preferences.dart';

import 'app_flow_step.dart';

class ProgressRepository {
  static const _onboardingKey = 'progress_onboarding_complete';
  static const _signupKey = 'progress_signup_complete';
  static const _otpKey = 'progress_otp_verified';
  static const _signInKey = 'progress_signed_in';

  Future<AppFlowStep> currentStep() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_onboardingKey) ?? false)) return AppFlowStep.onboarding;
    if (!(prefs.getBool(_signupKey) ?? false)) return AppFlowStep.signup;
    if (!(prefs.getBool(_otpKey) ?? false)) return AppFlowStep.otp;
    if (!(prefs.getBool(_signInKey) ?? false)) return AppFlowStep.signIn;
    return AppFlowStep.home;
  }

  Future<void> completeOnboarding() => _setFlag(_onboardingKey);
  Future<void> completeSignup() => _setFlag(_signupKey);
  Future<void> completeOtp() => _setFlag(_otpKey);
  Future<void> completeSignIn() => _setFlag(_signInKey);

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signInKey);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_signupKey);
    await prefs.remove(_otpKey);
    await prefs.remove(_signInKey);
  }

  Future<void> _setFlag(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }
}
