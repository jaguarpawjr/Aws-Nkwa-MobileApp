import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/contacts_store.dart';

// ── Public API ─────────────────────────────────────────────────────────────────

void showSosConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _SosConfirmDialog(
      onConfirm: () {
        Navigator.of(ctx).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SosDetailScreen()),
        );
      },
      onCancel: () => Navigator.of(ctx).pop(),
    ),
  );
}

// ── Confirm Dialog ─────────────────────────────────────────────────────────────

class _SosConfirmDialog extends StatelessWidget {
  const _SosConfirmDialog({required this.onConfirm, required this.onCancel});
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68.w,
              height: 68.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_rounded,
                size: 34.r,
                color: Color(0xFFEF4444),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'High Priority Alert',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.inkDeep,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Are you sure you are in need of this high priority service?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'This will immediately alert dispatchers and your emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.placeholder,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Yes, activate SOS',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.fieldBorder.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'No, cancel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SOS Detail Screen ──────────────────────────────────────────────────────────

class SosDetailScreen extends StatefulWidget {
  const SosDetailScreen({super.key});

  @override
  State<SosDetailScreen> createState() => _SosDetailScreenState();
}

class _SosDetailScreenState extends State<SosDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _showSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactCount = ContactsStore.contacts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: Column(
        children: [
          _SosHeader(pulseCtrl: _pulseCtrl),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AlertSentCard(contactCount: contactCount),
                  SizedBox(height: 24.h),
                  Text(
                    'Select options below',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Give more info about your current situation',
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 16.h),
                  _OptionCard(
                    icon: Icons.mic_rounded,
                    iconColor: AppColors.red,
                    iconBg: AppColors.redSoft,
                    title: 'Record environment audio',
                    subtitle: 'Auto-sends 1-min clips for up to 10 minutes',
                    onTap: () => _showSheet(const _RecordAudioSheet()),
                  ),
                  SizedBox(height: 12.h),
                  _OptionCard(
                    icon: Icons.edit_note_rounded,
                    iconColor: AppColors.red,
                    iconBg: AppColors.redSoft,
                    title: 'Type a message',
                    subtitle: 'Describe what\'s happening right now',
                    onTap: () => _showSheet(const _TypeMessageSheet()),
                  ),
                  SizedBox(height: 12.h),
                  _OptionCard(
                    icon: Icons.list_alt_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'Choose from situations',
                    subtitle: 'Help responders understand your situation',
                    onTap: () => _showSheet(const _SituationSheet()),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _SosHeader extends StatelessWidget {
  const _SosHeader({required this.pulseCtrl});
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12.h,
        bottom: 28.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16.r,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: pulseCtrl,
                builder: (_, child) => Opacity(
                  opacity: 0.65 + pulseCtrl.value * 0.35,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'SOS ACTIVE',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.campaign_rounded, size: 28.r, color: Colors.white),
          ),
          SizedBox(height: 12.h),
          Text(
            'Emergency Alert',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'SOS signal has been activated',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alert Sent Card ────────────────────────────────────────────────────────────

class _AlertSentCard extends StatelessWidget {
  const _AlertSentCard({required this.contactCount});
  final int contactCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 26.r,
              color: const Color(0xFF16A34A),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alert message already sent',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF15803D),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Sent to dispatcher and $contactCount emergency contact${contactCount == 1 ? '' : 's'}.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF166534),
                    height: 1.4,
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

// ── Option Card ────────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  const _OptionCard({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, size: 22.r, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: AppColors.placeholder,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Record Audio Sheet ─────────────────────────────────────────────────────────

class _RecordAudioSheet extends StatefulWidget {
  const _RecordAudioSheet();

  @override
  State<_RecordAudioSheet> createState() => _RecordAudioSheetState();
}

class _RecordAudioSheetState extends State<_RecordAudioSheet>
    with TickerProviderStateMixin {
  static const _maxSeconds = 600;  // 10 minutes total
  static const _chunkSize = 60;    // send clip every 1 minute

  final List<DateTime> _clips = [];
  int _totalSeconds = 0;
  int _chunkSeconds = 0;
  bool _stopped = false;

  Timer? _timer;
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _totalSeconds++;
        _chunkSeconds++;
        if (_chunkSeconds >= _chunkSize) {
          _clips.add(DateTime.now());
          _chunkSeconds = 0;
        }
        if (_totalSeconds >= _maxSeconds) {
          _stopRecording();
        }
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _waveCtrl.stop();
    _pulseCtrl.stop();
    setState(() => _stopped = true);
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _timestamp(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 36.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          SizedBox(height: 20.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _stopped
                ? _buildDoneState()
                : _buildActiveState(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveState() {
    final countdown = _chunkSize - _chunkSeconds;
    final progress = _totalSeconds / _maxSeconds;

    return Column(
      key: const ValueKey('active'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row + pulsing LIVE badge
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording audio',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Clips auto-sent every 1 minute',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => Opacity(
                opacity: 0.55 + _pulseCtrl.value * 0.45,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.redSoft,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.red,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Wave animation + countdown card
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 22.h),
          decoration: BoxDecoration(
            color: AppColors.redSoft,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 100.w,
                height: 100.w,
                child: AnimatedBuilder(
                  animation: _waveCtrl,
                  builder: (_, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      for (final phase in [0.0, 0.33, 0.66])
                        _RecordRing(ctrl: _waveCtrl, phase: phase),
                      Container(
                        width: 52.w,
                        height: 52.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mic_rounded, size: 24.r, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Next clip sends in',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
              ),
              SizedBox(height: 3.h),
              Text(
                _fmt(countdown),
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.red,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // Total progress bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_fmt(_totalSeconds)} elapsed',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.inkDeep,
              ),
            ),
            Text(
              '10:00 max',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6.h,
            backgroundColor: AppColors.fieldBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
          ),
        ),
        SizedBox(height: 16.h),

        // Sent clips list (newest first)
        if (_clips.isNotEmpty) ...[
          Text(
            'Sent clips (${_clips.length})',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkDeep,
            ),
          ),
          SizedBox(height: 8.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 160.h),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _clips.length,
              separatorBuilder: (_, i) => SizedBox(height: 6.h),
              itemBuilder: (_, i) {
                final ri = _clips.length - 1 - i; // newest at top
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.fieldBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.redSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.graphic_eq_rounded,
                          size: 16.r,
                          color: AppColors.red,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Clip ${ri + 1}  ·  1 min',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkDeep,
                          ),
                        ),
                      ),
                      Text(
                        _timestamp(_clips[ri]),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
        ],

        // Stop button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _stopRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop_rounded, size: 18.r),
                SizedBox(width: 8.w),
                Text(
                  'Stop recording',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneState() {
    return Column(
      key: const ValueKey('done'),
      children: [
        Icon(Icons.check_circle_rounded, size: 60.r, color: const Color(0xFF22C55E)),
        SizedBox(height: 16.h),
        Text(
          'Recording complete',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.inkDeep,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _clips.isEmpty
              ? 'No clips were captured.'
              : '${_clips.length} audio clip${_clips.length == 1 ? '' : 's'} sent to responders.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
        ),
        SizedBox(height: 28.h),
        _DoneButton(onTap: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _RecordRing extends StatelessWidget {
  const _RecordRing({required this.ctrl, required this.phase});
  final AnimationController ctrl;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final p = (ctrl.value + phase) % 1.0;
    final size = 52.w + (100.w - 52.w) * p;
    final opacity = (1.0 - p) * 0.30;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.red.withValues(alpha: opacity),
          width: 2.5,
        ),
      ),
    );
  }
}

// ── Type Message Sheet ─────────────────────────────────────────────────────────

enum _MsgStage { compose, sent }

class _TypeMessageSheet extends StatefulWidget {
  const _TypeMessageSheet();

  @override
  State<_TypeMessageSheet> createState() => _TypeMessageSheetState();
}

class _TypeMessageSheetState extends State<_TypeMessageSheet> {
  final _ctrl = TextEditingController();
  _MsgStage _stage = _MsgStage.compose;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _stage = _MsgStage.sent);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            SizedBox(height: 20.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _stage == _MsgStage.compose
                  ? _MsgComposeContent(
                      key: const ValueKey('compose'),
                      ctrl: _ctrl,
                      onSend: _send,
                    )
                  : _MsgSentContent(
                      key: const ValueKey('sent'),
                      onClose: () => Navigator.of(context).pop(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MsgComposeContent extends StatelessWidget {
  const _MsgComposeContent({super.key, required this.ctrl, required this.onSend});
  final TextEditingController ctrl;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send a message',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.inkDeep,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Describe what\'s happening to help responders.',
          style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: ctrl,
          maxLines: 4,
          minLines: 4,
          autofocus: true,
          style: TextStyle(fontSize: 14.sp, color: AppColors.inkDeep),
          decoration: InputDecoration(
            hintText: 'e.g. I\'m being followed near Accra Mall on Ring Road...',
            hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.placeholder),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(14.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: AppColors.red, width: 1.5),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 17.r),
                SizedBox(width: 8.w),
                Text(
                  'Send message',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MsgSentContent extends StatelessWidget {
  const _MsgSentContent({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.check_circle_rounded, size: 56.r, color: const Color(0xFF22C55E)),
        SizedBox(height: 16.h),
        Text(
          'Message sent',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.inkDeep,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Your message has been forwarded to responders.',
          style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
        ),
        SizedBox(height: 28.h),
        _DoneButton(onTap: onClose),
      ],
    );
  }
}

// ── Situation Sheet ────────────────────────────────────────────────────────────

class _Situation {
  const _Situation({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
}

const _kSituations = [
  _Situation(
    icon: Icons.person_off_rounded,
    label: 'Robbery /\nMugging',
    color: Color(0xFFB91C1C),
  ),
  _Situation(
    icon: Icons.warning_rounded,
    label: 'Sexual\nAssault',
    color: Color(0xFFD97706),
  ),
  _Situation(
    icon: Icons.local_fire_department_rounded,
    label: 'Fire\nOutbreak',
    color: Color(0xFFEA580C),
  ),
  _Situation(
    icon: Icons.medical_services_rounded,
    label: 'Medical\nEmergency',
    color: Color(0xFF059669),
  ),
  _Situation(
    icon: Icons.home_rounded,
    label: 'Domestic\nViolence',
    color: Color(0xFF7C3AED),
  ),
  _Situation(
    icon: Icons.lock_rounded,
    label: 'Kidnapping',
    color: Color(0xFF6B21A8),
  ),
  _Situation(
    icon: Icons.directions_car_rounded,
    label: 'Road\nAccident',
    color: Color(0xFF1D4ED8),
  ),
  _Situation(
    icon: Icons.waves,
    label: 'Natural\nDisaster',
    color: Color(0xFF0369A1),
  ),
  _Situation(
    icon: Icons.more_horiz_rounded,
    label: 'Other',
    color: Color(0xFF64748B),
  ),
];

class _SituationSheet extends StatefulWidget {
  const _SituationSheet();

  @override
  State<_SituationSheet> createState() => _SituationSheetState();
}

class _SituationSheetState extends State<_SituationSheet> {
  final Set<int> _selected = {};
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 36.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          SizedBox(height: 20.h),
          if (!_confirmed) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose from situations',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.inkDeep,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select all that apply to your situation.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.0,
              children: List.generate(_kSituations.length, (i) {
                final s = _kSituations[i];
                final selected = _selected.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    selected ? _selected.remove(i) : _selected.add(i);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected ? s.color : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: selected ? s.color : AppColors.fieldBorder,
                        width: selected ? 2 : 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: s.color.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          s.icon,
                          size: 24.r,
                          color: selected ? Colors.white : s.color,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.inkDeep,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () => setState(() => _confirmed = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.fieldBorder,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  _selected.isEmpty
                      ? 'Select a situation'
                      : 'Confirm situation${_selected.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: _selected.isEmpty ? AppColors.placeholder : Colors.white,
                  ),
                ),
              ),
            ),
          ] else ...[
            Icon(
              Icons.check_circle_rounded,
              size: 56.r,
              color: const Color(0xFF22C55E),
            ),
            SizedBox(height: 16.h),
            Text(
              'Situation reported',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.inkDeep,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Responders are now aware of your situation.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
            ),
            SizedBox(height: 28.h),
            _DoneButton(onTap: () => Navigator.of(context).pop()),
          ],
        ],
      ),
    );
  }
}

// ── Shared Helpers ─────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.fieldBorder,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.fieldBorder.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          'Done',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
