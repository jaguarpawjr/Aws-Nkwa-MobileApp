import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/contacts_store.dart';

void showAddContactSheet(BuildContext context, {VoidCallback? onAdded}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddContactSheet(onAdded: onAdded),
  );
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

enum _Stage { form, success }

class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet({this.onAdded});
  final VoidCallback? onAdded;

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  _Stage _stage = _Stage.form;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _addedName = '';
  String _addedInitials = '';
  Color _addedColorA = AppColors.violet;
  Color _addedColorB = AppColors.violetDeep;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final name = _nameCtrl.text.trim();
    final words = name.split(RegExp(r'\s+'));
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();
    final idx = ContactsStore.contacts.length % _kColors.length;

    ContactsStore.add(
      name: name,
      relation: _relationCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    widget.onAdded?.call();

    setState(() {
      _addedName = name;
      _addedInitials = initials;
      _addedColorA = _kColors[idx][0];
      _addedColorB = _kColors[idx][1];
      _stage = _Stage.success;
    });
  }

  void _addAnother() {
    _nameCtrl.clear();
    _relationCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    setState(() => _stage = _Stage.form);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: keyboardPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle + title row
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 8.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // handle centred above row
                    
                      Align( alignment: Alignment.topCenter,
                        child: Text(
                          _stage == _Stage.form ? 'Add contact' : 'Contact added',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkDeep,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Align(alignment: Alignment.topCenter,
                        child: Text(
                          _stage == _Stage.form
                              ? 'They\'ll receive your SOS alert instantly.'
                              : 'Now part of your emergency circle.',
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    width: 32.w,
                    height: 32.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.violetSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16.r, color: AppColors.violet),
                  ),
                ),
              ],
            ),
          ),

          // content switches between form and success
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _stage == _Stage.form
                ? _FormContent(
                    key: const ValueKey('form'),
                    formKey: _formKey,
                    nameCtrl: _nameCtrl,
                    relationCtrl: _relationCtrl,
                    phoneCtrl: _phoneCtrl,
                    emailCtrl: _emailCtrl,
                    onSubmit: _submit,
                  )
                : _SuccessContent(
                    key: const ValueKey('success'),
                    name: _addedName,
                    initials: _addedInitials,
                    colorA: _addedColorA,
                    colorB: _addedColorB,
                    onAddAnother: _addAnother,
                    onDone: () => Navigator.of(context).pop(),
                  ),
          ),
        ],
      ),
    );
  }
}

const _kColors = [
  [Color(0xFF7B32E8), Color(0xFFC77DFF)],
  [Color(0xFF1D9E75), Color(0xFF4DD0C4)],
  [Color(0xFF378ADD), Color(0xFF185FA5)],
  [Color(0xFF059669), Color(0xFF34D399)],
  [Color(0xFFD97706), Color(0xFFFBBF24)],
  [Color(0xFFE11D48), Color(0xFFFF6B6B)],
  [Color(0xFF6D28D9), Color(0xFFA78BFA)],
  [Color(0xFF0891B2), Color(0xFF4DD0E1)],
];

// ── Form content ──────────────────────────────────────────────────────────────

class _FormContent extends StatelessWidget {
  const _FormContent({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.relationCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController relationCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Field(
              controller: nameCtrl,
              label: 'Full name',
              hint: 'e.g. Kofi Mensah',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: 12.h),
            _Field(
              controller: relationCtrl,
              label: 'Relationship',
              hint: 'e.g. Father, Sister, Friend',
              icon: Icons.people_outline,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Relationship is required' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 12.h),
            _Field(
              controller: phoneCtrl,
              label: 'Phone number',
              hint: '+233 24 000 0000',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone number is required';
                if (v.trim().length < 7) return 'Enter a valid phone number';
                return null;
              },
            ),
            SizedBox(height: 12.h),
            _Field(
              controller: emailCtrl,
              label: 'Email (optional)',
              hint: 'name@example.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_outlined, size: 17.r),
                    SizedBox(width: 8.w),
                    Text(
                      'Add to my circle',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.inkDeep,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          textCapitalization: textCapitalization,
          style: TextStyle(fontSize: 13.sp, color: AppColors.inkDeep),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.placeholder),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 10.w),
              child: Icon(icon, size: 18.r, color: AppColors.placeholder),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 44.w),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide: BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide: BorderSide(color: AppColors.fieldBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide: BorderSide(color: AppColors.violet, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.r),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Success content ───────────────────────────────────────────────────────────
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    super.key,
    required this.name,
    required this.initials,
    required this.colorA,
    required this.colorB,
    required this.onAddAnother,
    required this.onDone,
  });

  final String name;
  final String initials;
  final Color colorA;
  final Color colorB;
  final VoidCallback onAddAnother;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
        
          // Stacked avatar + checkmark badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar circle with gradient + initials
              Container(
                // width: 80.w,
                // height: 80.w,
                
                alignment: Alignment.center,
                child:   Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.violet,
                    size: 65.r,
                  ),
              ),

              // Checkmark badge
            ],
          ),

          SizedBox(height: 5.h),

          // Success label pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'Added to circle',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.violet,
                letterSpacing: 0.4,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.inkDeep,
            ),
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'is now in your emergency circle.\nThey\'ll be alerted the moment you press SOS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),

          SizedBox(height: 32.h),

          // Add another button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: onAddAnother,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: AppColors.violet.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined, size: 17.r),
                  SizedBox(width: 8.w),
                  Text(
                    'Add another person',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Done button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: TextButton(
              onPressed: onDone,
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
          ),
        ],
      ),
    );
  }
}