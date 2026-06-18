import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Step model ────────────────────────────────────────────────────────────────

class FirstAidStep {
  const FirstAidStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final int number;
  final String title;
  final String description;

  factory FirstAidStep.fromJson(Map<String, dynamic> j) => FirstAidStep(
        number: j['number'] as int,
        title: j['title'] as String,
        description: j['description'] as String,
      );
}

// ── Entry model ───────────────────────────────────────────────────────────────

class FirstAidEntry {
  const FirstAidEntry({
    required this.id,
    required this.title,
    required this.steps,
    required this.category,
    required this.iconKey,
    required this.iconColorHex,
    required this.iconBgHex,
    required this.searchTerms,
    required this.hasDetail,
    this.overview,
    this.warning,
    required this.stepsDetail,
  });

  final String id;
  final String title;
  final int steps;
  final String category;
  final String iconKey;
  final String iconColorHex;
  final String iconBgHex;
  final List<String> searchTerms;
  final bool hasDetail;
  final String? overview;
  final String? warning;
  final List<FirstAidStep> stepsDetail;

  Color get iconColor => Color(int.parse('FF$iconColorHex', radix: 16));
  Color get iconBg => Color(int.parse('FF$iconBgHex', radix: 16));

  IconData get icon {
    switch (iconKey) {
      case 'person':
        return Icons.person_outline;
      case 'child_care':
        return Icons.child_care_outlined;
      case 'fire':
        return Icons.local_fire_department_outlined;
      case 'monitor_heart':
        return Icons.monitor_heart_outlined;
      case 'accessibility':
        return Icons.accessibility_new_outlined;
      case 'medical_info':
        return Icons.medical_information_outlined;
      case 'bloodtype':
        return Icons.bloodtype_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      default:
        return Icons.medical_services_outlined;
    }
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) return false;
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        searchTerms.any((t) => t.contains(q) || q.contains(t));
  }

  factory FirstAidEntry.fromJson(Map<String, dynamic> j) => FirstAidEntry(
        id: j['id'] as String,
        title: j['title'] as String,
        steps: j['steps'] as int,
        category: j['category'] as String,
        iconKey: j['iconKey'] as String,
        iconColorHex: j['iconColorHex'] as String,
        iconBgHex: j['iconBgHex'] as String,
        searchTerms: List<String>.from(j['searchTerms'] as List),
        hasDetail: j['hasDetail'] as bool,
        overview: j['overview'] as String?,
        warning: j['warning'] as String?,
        stepsDetail: (j['stepsDetail'] as List)
            .map((e) => FirstAidStep.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Repository ────────────────────────────────────────────────────────────────

class FirstAidRepository {
  static List<FirstAidEntry>? _cache;

  static Future<List<FirstAidEntry>> loadGuides() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/first_aid_data.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    _cache = (data['guides'] as List)
        .map((e) => FirstAidEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }
}
