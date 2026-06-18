import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

const _placeholderSections = [
  (
    heading: '1. Acceptance of terms',
    body:
        'By creating an account and using Nkwa, you agree to be bound by these '
        'Terms & Conditions. If you do not agree, please do not use the app.',
  ),
  (
    heading: '2. Emergency services disclaimer',
    body:
        'Nkwa helps route alerts to your emergency contacts and nearby dispatchers, '
        'but it is not a substitute for directly contacting local emergency services '
        'where available.',
  ),
  (
    heading: '3. Your data',
    body:
        'We only share your live location and alert details with the contacts and '
        'responders you choose, for the purpose of responding to an emergency.',
  ),
  (
    heading: '4. Changes to these terms',
    body:
        'We may update these terms from time to time. Continued use of the app after '
        'changes take effect constitutes acceptance of the revised terms.',
  ),
];

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.inkDeep),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.inkDeep,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: June 2026',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 20.h),
            for (final section in _placeholderSections) ...[
              Text(
                section.heading,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkDeep,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                section.body,
                style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted, height: 1.6),
              ),
              SizedBox(height: 20.h),
            ],
          ],
        ),
      ),
    );
  }
}
