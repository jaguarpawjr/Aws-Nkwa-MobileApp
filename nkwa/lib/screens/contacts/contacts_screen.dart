import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/contacts_store.dart';
import '../first_aid/first_aid_screen.dart';
import '../settings/settings_screen.dart';
import 'add_contact_screen.dart';


class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  List<ContactEntry> get _contacts => ContactsStore.contacts;
  List<ContactEntry> get _filteredContacts {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _contacts;
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(q) ||
          contact.relation.toLowerCase().contains(q) ||
          contact.phone.toLowerCase().contains(q) ||
          contact.email.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _addContact() {
    showAddContactSheet(context, onAdded: () {
      if (mounted) setState(() {});
    });
  }

  void _editContact(ContactEntry c) => _notifyComingSoon('Edit ${c.name}');

  Future<void> _deleteContact(ContactEntry c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Remove contact?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.inkDeep,
          ),
        ),
        content: Text(
          '${c.name} will no longer receive SOS alerts from you.',
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
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            ),
            child: Text(
              'Remove',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => ContactsStore.remove(c));
    }
  }

  Future<void> _onTabTap(int index) async {
    if (index == 2) return;
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
    if (index == 3) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
        (route) => route.isFirst,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleContacts = _filteredContacts;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _ContactsHeader(count: _contacts.length),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
                  // SizedBox(height: 14.h),
                  // _AlertBanner(count: _contacts.length),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      const Expanded(child: _SectionLabel('Your emergency circle')),
                      GestureDetector(
                        onTap: _addContact,
                        child: Container(
                          height: 30.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 14.r, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (visibleContacts.isEmpty)
                    _EmptyContactsSearch(query: _query)
                  else
                    ...visibleContacts.map(
                      (c) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ContactCard(
                          contact: c,
                          onEdit: () => _editContact(c),
                          onDelete: () => _deleteContact(c),
                          onNotifyChanged: (v) => setState(() => c.notify = v),
                        ),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      _query.trim().isEmpty
                          ? '${_contacts.length} contact${_contacts.length == 1 ? '' : 's'} in your circle'
                          : '${visibleContacts.length} match${visibleContacts.length == 1 ? '' : 'es'} found',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.placeholder,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 12.h),
            child: _BottomNavBar(onTabTap: _onTabTap),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _ContactsHeader extends StatelessWidget {
  const _ContactsHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A18C0), Color(0xFF6B2FE8), Color(0xFFA655F7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55.h,
            right: -55.w,
            child: Container(
              width: 170.w,
              height: 170.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EMERGENCY NETWORK',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Contacts',
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$count contacts',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Alerted instantly when you press SOS',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.72),
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
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8E2FA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 19.r, color: AppColors.placeholder),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 13.sp, color: AppColors.inkDeep),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.placeholder),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 18.r, color: AppColors.placeholder),
            ),
        ],
      ),
    );
  }
}

class _EmptyContactsSearch extends StatelessWidget {
  const _EmptyContactsSearch({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEDE8FB), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.redSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 24.r, color: AppColors.red),
          ),
          SizedBox(height: 12.h),
          Text(
            'No contacts found',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkDeep,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'No one matches "$query".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOS ALERT BANNER
// ─────────────────────────────────────────────────────────────────────────────

// class _AlertBanner extends StatelessWidget {
//   const _AlertBanner({required this.count});
//   final int count;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18.r),
//         border: Border.all(
//           color: AppColors.red.withValues(alpha: 0.15),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.red.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40.w,
//             height: 40.w,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.red, AppColors.redDeep],
//               ),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Icon(Icons.campaign_outlined, color: Colors.white, size: 20.r),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'All $count contacts will receive SOS alerts',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.inkDeep,
//                   ),
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   'High-priority ring + your live location, in order',
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.textMuted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
        
//         ],
//       ),
//     );
//   }
// }

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.placeholder,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTACT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onNotifyChanged,
  });

  final ContactEntry contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onNotifyChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEDE8FB), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            contact.avatarGradientA.withValues(alpha: 0.28),
                            contact.avatarGradientB.withValues(alpha: 0.18),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13.r),
                        border: Border.all(
                          color: contact.avatarGradientA.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        contact.initials,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: contact.avatarGradientA,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -3.h,
                      right: -3.w,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              contact.avatarGradientA,
                              contact.avatarGradientB,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '${contact.priority}',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkDeep,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.redSoft,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              contact.relation,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        contact.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconAction(
                      icon: Icons.edit_outlined,
                      bg: AppColors.redSoft,
                      color: AppColors.red,
                      onTap: onEdit,
                    ),
                    SizedBox(height: 4.h),
                    _IconAction(
                      icon: Icons.delete_outline,
                      bg: const Color(0xFFFEE2E2),
                      color: const Color(0xFFEF4444),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              border: const Border(
                top: BorderSide(color: Color(0xFFF2EEFB), width: 1),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.call_outlined, size: 14.r, color: AppColors.placeholder),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    contact.phone,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 18.h,
                  color: const Color(0xFFECE6FB),
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                ),
                Text(
                  'Notify',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.placeholder,
                  ),
                ),
                SizedBox(width: 6.w),
                Transform.scale(
                  scale: 0.82,
                  child: Switch.adaptive(
                    value: contact.notify,
                    onChanged: onNotifyChanged,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.red,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFDDD9EE),
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

// ─────────────────────────────────────────────────────────────────────────────
// ICON ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.bg,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color bg;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 15.r, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM NAV
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
  static const _activeIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == _activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                padding: EdgeInsets.symmetric(vertical: 5.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.red : Colors.transparent,
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
