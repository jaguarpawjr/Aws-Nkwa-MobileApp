import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../../core/progress_repository.dart';
import '../contacts/add_contact_screen.dart';
import '../contacts/contacts_screen.dart';
import '../emergency_call/emergency_call_screen.dart';
import '../first_aid/first_aid_screen.dart';
import '../settings/settings_screen.dart';
import '../sos/sos_detail_screen.dart';
import '../splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('contacts_prompt_shown') ?? false;
    if (shown || !mounted) return;
    await prefs.setBool('contacts_prompt_shown', true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showAddContactModal();
    });
  }

  void _showAddContactModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddContactPromptSheet(
        onAdd: () {
          Navigator.of(context).pop();
          showAddContactSheet(context);
        },
        onSkip: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _resetProgress() async {
    await ProgressRepository().reset();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  void _notifyComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  Future<void> _onTabTap(int index) async {
    if (index == 1) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const FirstAidScreen()),
      );
      if (mounted) setState(() => _selectedTab = 0);
      return;
    }
    if (index == 2) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ContactsScreen()),
      );
      if (mounted) setState(() => _selectedTab = 0);
      return;
    }
    if (index == 3) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      if (mounted) setState(() => _selectedTab = 0);
      return;
    }
    setState(() => _selectedTab = index);
    if (index != 0) _notifyComingSoon(_BottomNavBar.labels[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(onNotificationTap: () => _notifyComingSoon('Notifications')),
                    SizedBox(height: 18.h),
                    _ProfileCard(onAvatarLongPress: _resetProgress),
                    SizedBox(height: 26.h),
                    Text(
                      'Place emergency call',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkDeep,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _EmergencyActionCard(
                      icon: Icons.emergency_outlined,
                      iconColor: const Color(0xFF10B981),
                      iconBg: const Color(0xFFD1FAE5),
                      title: 'Ambulance',
                      subtitle: 'Medical emergency response',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const EmergencyCallScreen(
                          service: EmergencyCallService(
                            title: 'Ambulance',
                            subtitle: 'Medical emergency response',
                            number: '193',
                            gradientA: Color(0xFF059669),
                            gradientB: Color(0xFF10B981),
                            colorSoft: Color(0xFFD1FAE5),
                            icon: Icons.emergency_outlined,
                          ),
                        ),
                      )),
                    ),
                    SizedBox(height: 12.h),
                    _EmergencyActionCard(
                      icon: Icons.local_fire_department_outlined,
                      iconColor: const Color(0xFFF97316),
                      iconBg: const Color(0xFFFEE2E2),
                      title: 'Fire Service',
                      subtitle: 'Fire & rescue operations',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const EmergencyCallScreen(
                          service: EmergencyCallService(
                            title: 'Fire Service',
                            subtitle: 'Fire & rescue operations',
                            number: '192',
                            gradientA: Color(0xFFEA580C),
                            gradientB: Color(0xFFF97316),
                            colorSoft: Color(0xFFFFEDD5),
                            icon: Icons.local_fire_department_outlined,
                          ),
                        ),
                      )),
                    ),
                    SizedBox(height: 12.h),
                    _EmergencyActionCard(
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.violet,
                      iconBg: AppColors.violetSoft,
                      title: 'Police',
                      subtitle: 'Crime & security response',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const EmergencyCallScreen(
                          service: EmergencyCallService(
                            title: 'Police',
                            subtitle: 'Crime & security response',
                            number: '191',
                            gradientA: Color(0xFF5B21B6),
                            gradientB: Color(0xFF7C3AED),
                            colorSoft: Color(0xFFEDE9FE),
                            icon: Icons.shield_outlined,
                          ),
                        ),
                      )),
                    ),
                    SizedBox(height: 12.h),
                    _EmergencyActionCard(
                      icon: Icons.campaign_outlined,
                      iconColor: const Color(0xFFEF4444),
                      iconBg: const Color(0xFFFEE2E2),
                      title: 'SOS Alert',
                      subtitle: 'Instant panic & alert dispatch',
                      onTap: () => showSosConfirmation(context),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
              child: _BottomNavBar(selectedIndex: _selectedTab, onTap: _onTabTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotificationTap});
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20.r, color: AppColors.placeholder),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Search help, contacts, first aid...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.placeholder),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        _NotificationButton(count: 3, onTap: onNotificationTap),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.notifications_outlined, color: AppColors.inkDeep, size: 22.r),
          ),
          if (count > 0)
            Positioned(
              top: -4.h,
              right: -4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                constraints: BoxConstraints(minWidth: 18.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onAvatarLongPress});
  final VoidCallback onAvatarLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B0E8C), Color(0xFF6D28D9), Color(0xFF9333EA)],
          stops: [0.0, 0.52, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6D28D9).withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // decorative orbs
          Positioned(
            top: -28.h,
            right: 48.w,
            child: Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -24.h,
            left: -16.w,
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MY PROFILE',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.5),
                            letterSpacing: 1.3,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Ama Boateng',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'ama.boateng@email.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  // avatar — person silhouette icon
                  GestureDetector(
                    onLongPress: onAvatarLongPress,
                    child: Container(
                      width: 58.w,
                      height: 58.w,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: -6.h,
                            child: Icon(
                              Icons.person_rounded,
                              size: 50.r,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.location_on_rounded,
                    label: 'Greater Accra',
                  ),
                  SizedBox(width: 8.w),
                  _InfoChip(
                    icon: Icons.pin_drop_outlined,
                    label: 'GA-123-4567',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white.withValues(alpha: 0.75)),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyActionCard extends StatelessWidget {
  const _EmergencyActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
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
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14.r)),
              child: Icon(icon, color: iconColor, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.inkDeep),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(Icons.chevron_right, color: iconColor, size: 18.r),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const labels = ['Home', 'First Aid', 'Contacts', 'Settings'];
  static const _icons = [
    Icons.home_rounded,
    Icons.medical_services_outlined,
    Icons.people_alt_outlined,
    Icons.settings_outlined,
  ];

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
          final isActive = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
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
                        fontWeight: FontWeight.w600,
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

// ── First-visit add-contact prompt ────────────────────────────────────────────

class _AddContactPromptSheet extends StatelessWidget {
  const _AddContactPromptSheet({required this.onAdd, required this.onSkip});
  final VoidCallback onAdd;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.fieldBorder,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          // icon
          Container(
            width: 64.w,
            height: 64.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Icons.people_alt_rounded, size: 30.r, color: AppColors.violet),
          ),
          SizedBox(height: 16.h),
          Text(
            'Build your safety circle',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.inkDeep,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add trusted contacts who\'ll be instantly alerted\nwhen you trigger an SOS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textMuted,
              height: 1.55,
            ),
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Add a contact',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
