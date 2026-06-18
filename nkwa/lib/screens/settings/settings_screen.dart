import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/progress_repository.dart';
import '../contacts/contacts_screen.dart';
import '../first_aid/first_aid_screen.dart';
import '../sign_in/sign_in_screen.dart';
import '../splash_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _notifyComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      ),
    );
  }

  void _openTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  }

  Future<void> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.inkDeep,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted, height: 1.5),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? const Color(0xFFEF4444) : AppColors.violet,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            ),
            child: Text(
              confirmLabel,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (isDestructive) {
      await ProgressRepository().reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } else {
      await ProgressRepository().signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  void _logOut() => _confirm(
        title: 'Log out?',
        message: "You'll need to sign in again to access your account.",
        confirmLabel: 'Log out',
        isDestructive: false,
      );

  void _deleteAccount() => _confirm(
        title: 'Delete account?',
        message:
            'This will permanently delete your account and all your data. '
            'This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Flat gradient header (no rounded edges, compact) ─────
          _SettingsHeader(),

          // ── Scrollable body ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile card pulls up over the header
                  _ProfileCard(),

                  SizedBox(height: 10.h),

                  // ── Account ──────────────────────────────────────
                  _SectionLabel('Account'),
                  SizedBox(height: 10.h),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.person_outline,
                        iconColor: AppColors.violet,
                        iconBg: AppColors.violetSoft,
                        label: 'Edit profile',
                        subtitle: 'Name, photo, phone, address',
                        onTap: () => _notifyComingSoon('Edit profile'),
                      ),
                      _SettingsRow(
                        icon: Icons.lock_outline,
                        iconColor: AppColors.violet,
                        iconBg: AppColors.violetSoft,
                        label: 'Change password',
                        subtitle: 'Update your login credentials',
                        onTap: () => _notifyComingSoon('Change password'),
                      ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  // ── Legal ────────────────────────────────────────
                  _SectionLabel('Legal'),
                  SizedBox(height: 10.h),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF374151),
                        iconBg: const Color(0xFFE5E7EB),
                        label: 'Terms & conditions',
                        subtitle: 'Usage terms and privacy policy',
                        onTap: _openTerms,
                      ),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  // ── Account actions ──────────────────────────────
                  _SectionLabel('Account actions'),
                  SizedBox(height: 10.h),
                  _SettingsGroup(
                    children: [
                      _SettingsRow(
                        icon: Icons.logout_outlined,
                        iconColor: const Color(0xFFB45309),
                        iconBg: const Color(0xFFFEF3C7),
                        label: 'Log out',
                        subtitle: 'You can sign back in anytime',
                        onTap: _logOut,
                      ),
                      _SettingsRow(
                        icon: Icons.delete_outline,
                        iconColor: const Color(0xFFEF4444),
                        iconBg: const Color(0xFFFEE2E2),
                        label: 'Delete account',
                        subtitle: 'Permanently remove all your data',
                        labelColor: const Color(0xFFEF4444),
                        onTap: _deleteAccount,
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // version footer
                  Center(
                    child: Text(
                      'Nkwa · Version 1.0.0 · Made with care in Ghana 🇬🇭',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.placeholder,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom nav ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: _BottomNavBar(
              onTabTap: (index) async {
                if (index == 3) return;
                if (index == 0) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  return;
                }
                if (index == 1) {
                  await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const FirstAidScreen()),
                    (route) => route.isFirst,
                  );
                  return;
                }
                if (index == 2) {
                  await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const ContactsScreen()),
                    (route) => route.isFirst,
                  );
                  return;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FLAT GRADIENT HEADER — no rounded edges, shorter height
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // straight edges — no BorderRadius at all
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet, AppColors.violetDeep],
        ),
      ),
      child: Stack(
        children: [
          // subtle orb — top right only, kept very faint
          Positioned(
            top: -40.h,
            right: -40.w,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PREFERENCES',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // notification bell in header
                  Container(
                    width: 38.w,
                    height: 38.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20.r,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE CARD — white card overlapping the flat header
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  static const String _avatarUrl = 'https://i.pravatar.cc/150?img=47';

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -24.h),
      child: Container(
         margin: EdgeInsets.only(top: 30.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFEDE8FB), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // network avatar
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17.r),
                border: Border.all(
                  color: AppColors.violet.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.violetSoft,
                  alignment: Alignment.center,
                  child: Text(
                    'AB',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violet,
                    ),
                  ),
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.violetSoft,
                    alignment: Alignment.center,
                    child: Text(
                      'AB',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet,
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(width: 14.w),

            // name + email + active pill
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ama Boateng',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkDeep,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'ama.boateng@email.com',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 7.h),
                  // active status pill
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Account active',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            // edit shortcut button
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16.r,
                  color: AppColors.violet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.placeholder,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS GROUP
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEDE8FB), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 58.w,
                endIndent: 0,
                color: const Color(0xFFF2EEFB),
              ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        child: Row(
          children: [
            // coloured icon box
            Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 18.r, color: iconColor),
            ),
            SizedBox(width: 12.w),
            // label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.inkDeep,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, size: 18.r, color: AppColors.placeholder),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV BAR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.onTabTap});
  final ValueChanged<int> onTabTap;

  static const labels = ['Home', 'First Aid', 'Contacts', 'Settings'];
  static const _icons = [
    Icons.home_rounded,
    Icons.medical_services_outlined,
    Icons.people_alt_outlined,
    Icons.settings_outlined,
  ];
  static const _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == _selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 5.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.violet : Colors.transparent,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      size: 17.r,
                      color: isActive ? Colors.white : AppColors.placeholder,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : AppColors.placeholder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}