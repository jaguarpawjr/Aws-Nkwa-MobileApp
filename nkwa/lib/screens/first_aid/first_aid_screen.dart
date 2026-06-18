import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/app_colors.dart';
import '../../core/first_aid_entry.dart';
import '../contacts/contacts_screen.dart';
import '../settings/settings_screen.dart';
import 'first_aid_detail_screen.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  int _activeTab = 0;
  final _searchController = TextEditingController();

  List<FirstAidEntry> _guides = [];
  List<FirstAidEntry>? _searchResults;
  String _lastQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    final guides = await FirstAidRepository.loadGuides();
    if (mounted) {
      setState(() {
        _guides = guides;
        _isLoading = false;
      });
    }
  }

  void _runSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _lastQuery = '';
      });
      return;
    }
    final results = _guides.where((g) => g.matchesQuery(query)).take(2).toList();
    setState(() {
      _searchResults = results;
      _lastQuery = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = null;
      _lastQuery = '';
    });
  }

  void _openGuide(FirstAidEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FirstAidDetailScreen(entry: entry)),
    );
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

  Future<void> _onNavTap(int index) async {
    if (index == 1) return;
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == 2) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ContactsScreen()),
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _FirstAidHeader(
            activeTab: _activeTab,
            onTabChanged: (i) => setState(() => _activeTab = i),
          ),
          Expanded(
            child: _activeTab == 0
                ? _OfflineTab(
                    isLoading: _isLoading,
                    guides: _guides,
                    searchController: _searchController,
                    searchResults: _searchResults,
                    lastQuery: _lastQuery,
                    onSearch: _runSearch,
                    onClear: _clearSearch,
                    onGuideTab: _openGuide,
                    onSeeAll: () => _notifyComingSoon('See all guides'),
                  )
                : const _AiTab(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: _FirstAidBottomNav(onTabTap: _onNavTap),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _FirstAidHeader extends StatelessWidget {
  const _FirstAidHeader({
    required this.activeTab,
    required this.onTabChanged,
  });

  final int activeTab;
  final ValueChanged<int> onTabChanged;

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
              width: 150.w,
              height: 150.w,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EMERGENCY GUIDES',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.65),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'First Aid',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF34D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Offline ready',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TabChip(
                          label: 'Offline guides',
                          isActive: activeTab == 0,
                          onTap: () => onTabChanged(0),
                        ),
                        _TabChip(
                          label: 'AI assistance',
                          isActive: activeTab == 1,
                          onTap: () => onTabChanged(1),
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

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(19.r),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.violetDeep.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.violet : Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

// ── Offline tab ───────────────────────────────────────────────────────────────

class _OfflineTab extends StatelessWidget {
  const _OfflineTab({
    required this.isLoading,
    required this.guides,
    required this.searchController,
    required this.searchResults,
    required this.lastQuery,
    required this.onSearch,
    required this.onClear,
    required this.onGuideTab,
    required this.onSeeAll,
  });

  final bool isLoading;
  final List<FirstAidEntry> guides;
  final TextEditingController searchController;
  final List<FirstAidEntry>? searchResults;
  final String lastQuery;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<FirstAidEntry> onGuideTab;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.violet,
          strokeWidth: 2.5,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(
            controller: searchController,
            onSubmit: onSearch,
            onClear: onClear,
          ),
          SizedBox(height: 22.h),
          if (searchResults != null) ...[
            _SearchResultsSection(
              query: lastQuery,
              results: searchResults!,
              onGuideTab: onGuideTab,
            ),
            SizedBox(height: 28.h),
          ],
          _PopularGuidesSection(
            guides: guides,
            onGuideTab: onGuideTab,
            onSeeAll: onSeeAll,
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSubmit,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Icon(Icons.search_rounded, size: 20.r, color: AppColors.placeholder),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSubmit(),
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 14.sp, color: AppColors.inkDeep),
              decoration: InputDecoration(
                hintText: 'Search first aid guides...',
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.placeholder),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(6.w),
            child: GestureDetector(
              onTap: onSubmit,
              child: Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.violet,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.chevron_right, color: Colors.white, size: 20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({
    required this.query,
    required this.results,
    required this.onGuideTab,
  });

  final String query;
  final List<FirstAidEntry> results;
  final ValueChanged<FirstAidEntry> onGuideTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          results.isEmpty
              ? 'NO RESULTS FOR "${query.toUpperCase()}"'
              : '${results.length} RESULT${results.length == 1 ? '' : 'S'} FOR "${query.toUpperCase()}"',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.placeholder,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: 12.h),
        if (results.isEmpty)
          _EmptySearchState(query: query)
        else
          Column(
            children: [
              for (int i = 0; i < results.length; i++) ...[
                _GuideCard(guide: results[i], onTap: () => onGuideTab(results[i])),
                if (i < results.length - 1) SizedBox(height: 10.h),
              ],
            ],
          ),
      ],
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h),
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
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 26.r, color: AppColors.violet),
          ),
          SizedBox(height: 12.h),
          Text(
            'No guides found for "$query"',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Try searching for burns, CPR, bleeding…',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Popular guides ────────────────────────────────────────────────────────────

class _PopularGuidesSection extends StatelessWidget {
  const _PopularGuidesSection({
    required this.guides,
    required this.onGuideTab,
    required this.onSeeAll,
  });

  final List<FirstAidEntry> guides;
  final ValueChanged<FirstAidEntry> onGuideTab;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'POPULAR GUIDES',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.placeholder,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.violet,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Column(
          children: [
            for (int i = 0; i < guides.length; i++) ...[
              _GuideCard(guide: guides[i], onTap: () => onGuideTab(guides[i])),
              if (i < guides.length - 1) SizedBox(height: 10.h),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Guide card ────────────────────────────────────────────────────────────────

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide, required this.onTap});

  final FirstAidEntry guide;
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
              decoration: BoxDecoration(
                color: guide.iconBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(guide.icon, color: guide.iconColor, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    guide.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${guide.steps} steps  •  ${guide.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 30.w,
              height: 30.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: guide.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: guide.iconColor, size: 16.r),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI assistance tab ─────────────────────────────────────────────────────────

class _AiTab extends StatelessWidget {
  const _AiTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.violet, AppColors.violetDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32.r),
            ),
            SizedBox(height: 20.h),
            Text(
              'AI First Aid Assistant',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.inkDeep,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Get instant AI-powered guidance for any emergency — even when offline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: AppColors.violetSoft,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_rounded, size: 16.r, color: AppColors.violet),
                  SizedBox(width: 8.w),
                  Text(
                    'Coming soon',
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

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _FirstAidBottomNav extends StatelessWidget {
  const _FirstAidBottomNav({required this.onTabTap});
  final ValueChanged<int> onTabTap;

  static const _labels = ['Home', 'First Aid', 'Contacts', 'Settings'];
  static const _icons = [
    Icons.home_rounded,
    Icons.medical_services_outlined,
    Icons.people_alt_outlined,
    Icons.settings_outlined,
  ];
  static const _activeIndex = 1;

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
        children: List.generate(_labels.length, (index) {
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
                      _labels[index],
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
