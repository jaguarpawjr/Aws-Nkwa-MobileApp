import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/first_aid_entry.dart';

class FirstAidDetailScreen extends StatelessWidget {
  const FirstAidDetailScreen({super.key, required this.entry});

  final FirstAidEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _DetailHeader(entry: entry, onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: entry.hasDetail
                ? _DetailBody(entry: entry)
                : _ComingSoonBody(entry: entry),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.entry, required this.onBack});

  final FirstAidEntry entry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet, Color(0xFF9333EA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40.h,
            right: -40.w,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // back row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 22.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'First Aid',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  // icon + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(entry.icon, color: Colors.white, size: 24.r),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  // chips
                  Row(
                    children: [
                      _HeaderChip(
                        icon: Icons.category_outlined,
                        label: entry.category,
                      ),
                      SizedBox(width: 8.w),
                      _HeaderChip(
                        icon: Icons.checklist_rounded,
                        label: '${entry.steps} steps',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white.withValues(alpha: 0.9)),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detailed body (for guides with full content) ──────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.entry});

  final FirstAidEntry entry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview
          if (entry.overview != null) ...[
            _SectionLabel('Overview'),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                entry.overview!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Steps
          _SectionLabel('Step by step'),
          SizedBox(height: 10.h),
          ...entry.stepsDetail.map(
            (step) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _StepCard(step: step, entry: entry),
            ),
          ),

          // Warning
          if (entry.warning != null) ...[
            SizedBox(height: 14.h),
            _WarningCard(text: entry.warning!),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.placeholder,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.entry});

  final FirstAidStep step;
  final FirstAidEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number badge
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${step.number}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: entry.iconColor,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkDeep,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                    height: 1.55,
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

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 18.r,
              color: const Color(0xFFD97706),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'When to call 112',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFB45309),
                    height: 1.55,
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

// ── Coming soon body ──────────────────────────────────────────────────────────

class _ComingSoonBody extends StatelessWidget {
  const _ComingSoonBody({required this.entry});

  final FirstAidEntry entry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.iconBg,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(entry.icon, color: entry.iconColor, size: 30.r),
            ),
            SizedBox(height: 18.h),
            Text(
              entry.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.inkDeep,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'The full step-by-step guide for this topic is being written by our medical team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textMuted,
                height: 1.55,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.violetSoft,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_rounded, size: 15.r, color: AppColors.violet),
                  SizedBox(width: 8.w),
                  Text(
                    'Full guide coming soon',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.violet,
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
