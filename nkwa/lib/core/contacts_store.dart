import 'package:flutter/material.dart';

class ContactEntry {
  ContactEntry({
    required this.initials,
    required this.name,
    required this.relation,
    required this.phone,
    this.email = '',
    required this.avatarGradientA,
    required this.avatarGradientB,
    required this.priority,
    this.notify = true,
  });

  final String initials;
  final String name;
  final String relation;
  final String phone;
  final String email;
  final Color avatarGradientA;
  final Color avatarGradientB;
  final int priority;
  bool notify;
}

class ContactsStore {
  static final List<ContactEntry> contacts = [
    ContactEntry(
      initials: 'KB',
      name: 'Kofi Boateng',
      relation: 'Father',
      email: 'kofi.boateng@gmail.com',
      phone: '+233 24 111 2222',
      avatarGradientA: const Color(0xFF7B32E8),
      avatarGradientB: const Color(0xFFC77DFF),
      priority: 1,
    ),
    ContactEntry(
      initials: 'EA',
      name: 'Esi Asante',
      relation: 'Sister',
      email: 'esi.asante@outlook.com',
      phone: '+233 20 333 4444',
      avatarGradientA: const Color(0xFF1D9E75),
      avatarGradientB: const Color(0xFF4DD0C4),
      priority: 2,
    ),
    ContactEntry(
      initials: 'YM',
      name: 'Yaw Mensah',
      relation: 'Close friend',
      email: 'yaw.mensah@yahoo.com',
      phone: '+233 26 555 6666',
      avatarGradientA: const Color(0xFFFAC775),
      avatarGradientB: const Color(0xFFBA7517),
      priority: 3,
    ),
    ContactEntry(
      initials: 'AB',
      name: 'Akosua Brew',
      relation: 'Colleague',
      email: 'akosua.brew@work.com',
      phone: '+233 30 777 8888',
      avatarGradientA: const Color(0xFFFF6B6B),
      avatarGradientB: const Color(0xFFE63946),
      priority: 4,
      notify: false,
    ),
    ContactEntry(
      initials: 'NK',
      name: 'Nana Kwame',
      relation: 'Neighbour',
      email: 'nana.k@icloud.com',
      phone: '+233 27 999 0011',
      avatarGradientA: const Color(0xFF378ADD),
      avatarGradientB: const Color(0xFF185FA5),
      priority: 5,
    ),
  ];

  static const _gradients = [
    [Color(0xFF7B32E8), Color(0xFFC77DFF)],
    [Color(0xFF1D9E75), Color(0xFF4DD0C4)],
    [Color(0xFF378ADD), Color(0xFF185FA5)],
    [Color(0xFF059669), Color(0xFF34D399)],
    [Color(0xFFD97706), Color(0xFFFBBF24)],
    [Color(0xFFE11D48), Color(0xFFFF6B6B)],
    [Color(0xFF6D28D9), Color(0xFFA78BFA)],
    [Color(0xFF0891B2), Color(0xFF4DD0E1)],
  ];

  static void add({
    required String name,
    required String relation,
    required String phone,
    String email = '',
  }) {
    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();
    final idx = contacts.length % _gradients.length;
    contacts.add(ContactEntry(
      initials: initials,
      name: name.trim(),
      relation: relation.trim(),
      phone: phone.trim(),
      email: email.trim(),
      avatarGradientA: _gradients[idx][0],
      avatarGradientB: _gradients[idx][1],
      priority: contacts.length + 1,
    ));
  }

  static void remove(ContactEntry c) => contacts.remove(c);
}
