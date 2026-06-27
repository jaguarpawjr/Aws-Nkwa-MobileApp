import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';

// ── Service model ─────────────────────────────────────────────────────────────

class EmergencyCallService {
  const EmergencyCallService({
    required this.title,
    required this.subtitle,
    required this.number,
    required this.gradientA,
    required this.gradientB,
    required this.colorSoft,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String number;
  final Color gradientA;
  final Color gradientB;
  final Color colorSoft;
  final IconData icon;
}

// ── Purple palette constants ──────────────────────────────────────────────────

const _kViolet      = Color(0xFF6D28D9);
const _kVioletMid   = Color(0xFF7C3AED);
const _kVioletLight = Color(0xFFB388F5);
const _kVioletSoft  = Color(0xFFF3EEFF);
const _kVioletGlow  = Color(0xFFEDE9FE);

// ── Language model ────────────────────────────────────────────────────────────

class _Lang {
  const _Lang({
    required this.name,
    required this.native,
    required this.region,
    required this.code,
  });

  final String name;
  final String native;
  final String region;
  final String code;
}

const _languages = [
  _Lang(name: 'English',  native: 'English',   region: 'Nationwide',          code: 'EN'),
  _Lang(name: 'Twi',      native: 'Twi',       region: 'Ashanti & Brong-Ahafo', code: 'TW'),
  _Lang(name: 'Ga',       native: 'Gã',        region: 'Greater Accra',       code: 'GA'),
  _Lang(name: 'Ewe',      native: 'Eʋegbe',    region: 'Volta Region',        code: 'EW'),
 
  _Lang(name: 'Fante',    native: 'Fante',     region: 'Central Region',      code: 'FA'),
  _Lang(name: 'Dagbani',  native: 'Dagbanli',  region: 'Northern Region',     code: 'DB'),

 
];

// ── Screen ────────────────────────────────────────────────────────────────────

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key, required this.service});
  final EmergencyCallService service;

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  void _openCallModal(_Lang lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CallModal(service: widget.service, language: lang),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kVioletSoft,
      body: Column(
        children: [
          _ServiceHeader(
            service: widget.service,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
              itemCount: _languages.length,
              itemBuilder: (_, i) {
                final start = (i * 0.08).clamp(0.0, 0.8);
                final end   = (start + 0.45).clamp(0.0, 1.0);
                final anim  = CurvedAnimation(
                  parent: _listCtrl,
                  curve: Interval(start, end, curve: Curves.easeOut),
                );
                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, child) => Opacity(
                    opacity: anim.value,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - anim.value)),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _LanguageTile(
                      lang: _languages[i],
                      onTap: () => _openCallModal(_languages[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ServiceHeader extends StatelessWidget {
  const _ServiceHeader({required this.service, required this.onBack});
  final EmergencyCallService service;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kViolet, _kVioletMid, _kVioletLight],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // top-right decorative blob
          Positioned(
            top: -50.h,
            right: -40.w,
            child: Container(
              width: 170.w,
              height: 170.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // bottom-left accent blob
          Positioned(
            bottom: -30.h,
            left: -20.w,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 26.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // back button
                

                  // service icon + name + number
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
                      child: Icon(Icons.chevron_left, color: Colors.white, size: 22.r),
                    ),
                  ),
                      SizedBox(width: 14.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                            
                              Text(
                                'Service',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.75),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // subtitle pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 13.r,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Select your language to call',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
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
    );
  }
}

// ── Language tile ─────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.lang, required this.onTap});

  final _Lang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _kViolet.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // language code badge
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kViolet, _kVioletLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13.r),
                boxShadow: [
                  BoxShadow(
                    color: _kViolet.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                lang.code,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkDeep,
                        ),
                      ),
                      if (lang.native != lang.name) ...[
                        SizedBox(width: 6.w),
                        Text(
                          lang.native,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 10.r,
                        color: _kVioletLight,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        lang.region,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.placeholder,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _kVioletGlow,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: _kViolet, size: 16.r),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Call modal ────────────────────────────────────────────────────────────────

enum _CallStage { waiting, calling }

class _CallModal extends StatefulWidget {
  const _CallModal({required this.service, required this.language});
  final EmergencyCallService service;
  final _Lang language;

  @override
  State<_CallModal> createState() => _CallModalState();
}

class _CallModalState extends State<_CallModal> with TickerProviderStateMixin {
  _CallStage _stage = _CallStage.waiting;

  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _placeCall() {
    setState(() => _stage = _CallStage.calling);
    _waveCtrl.stop();
    _pulseCtrl.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: _kVioletGlow,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 22.h),

          // service + language chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Chip(
                icon: widget.service.icon,
                label: widget.service.title,
              ),
              SizedBox(width: 8.w),
              _Chip(
                icon: Icons.translate_rounded,
                label: widget.language.name,
              ),
            ],
          ),

          SizedBox(height: 36.h),

          // animated area
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _stage == _CallStage.waiting
                ? _WaitingContent(
                    key: const ValueKey('waiting'),
                    language: widget.language,
                    service: widget.service,
                    waveCtrl: _waveCtrl,
                    onTap: _placeCall,
                  )
                : _CallingContent(
                    key: const ValueKey('calling'),
                    service: widget.service,
                    language: widget.language,
                    pulseCtrl: _pulseCtrl,
                  ),
          ),

          SizedBox(height: 28.h),

          // cancel / end call
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 50.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _stage == _CallStage.calling
                    ? const Color(0xFFFFEEEE)
                    : _kVioletGlow,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                _stage == _CallStage.waiting ? 'Cancel' : 'End call',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _stage == _CallStage.calling
                      ? const Color(0xFFEF4444)
                      : _kViolet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _kVioletSoft,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _kViolet.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.r, color: _kViolet),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: _kViolet,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Waiting content ───────────────────────────────────────────────────────────

class _WaitingContent extends StatelessWidget {
  const _WaitingContent({
    super.key,
    required this.service,
    required this.language,
    required this.waveCtrl,
    required this.onTap,
  });

  final EmergencyCallService service;
  final _Lang language;
  final AnimationController waveCtrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200.w,
          height: 200.w,
          child: AnimatedBuilder(
            animation: waveCtrl,
            builder: (_, child) => Stack(
              alignment: Alignment.center,
              children: [
                _WaveRing(progress: waveCtrl.value, phase: 0.0),
                _WaveRing(progress: waveCtrl.value, phase: 0.33),
                _WaveRing(progress: waveCtrl.value, phase: 0.66),
                child!,
              ],
            ),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 82.w,
                height: 82.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kViolet, _kVioletLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kViolet.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.call_rounded, color: Colors.white, size: 34.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap to call ${service.title}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.inkDeep,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'in ${language.name}',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _WaveRing extends StatelessWidget {
  const _WaveRing({required this.progress, required this.phase});

  final double progress;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final p      = ((progress - phase) % 1.0 + 1.0) % 1.0;
    final eased  = math.sqrt(p);
    final diameter = 82.w + (200.w - 82.w) * eased;
    final opacity  = (1.0 - eased) * 0.22;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kViolet.withValues(alpha: opacity),
      ),
    );
  }
}

// ── Calling content ───────────────────────────────────────────────────────────

class _CallingContent extends StatelessWidget {
  const _CallingContent({
    super.key,
    required this.service,
    required this.language,
    required this.pulseCtrl,
  });

  final EmergencyCallService service;
  final _Lang language;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (_, child) => Transform.scale(
            scale: 1.0 + pulseCtrl.value * 0.08,
            child: child,
          ),
          child: Container(
            width: 82.w,
            height: 82.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kViolet, _kVioletLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: _kViolet.withValues(alpha: 0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.call_rounded, color: Colors.white, size: 34.r),
          ),
        ),
        SizedBox(height: 22.h),
        Text(
          'Placing call...',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.inkDeep,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: _kVioletSoft,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            service.title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _kViolet,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Calling in ${language.name}',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
