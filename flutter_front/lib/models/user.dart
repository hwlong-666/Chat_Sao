import 'package:flutter/material.dart';

enum UserStatus {
  online,
  offline,
  away,
}

class User {
  final String id;
  final String name;
  final String handle;
  final IconData avatarIcon;
  final Color avatarColor;
  final bool isAi;
  final bool verified;
  final UserStatus status;
  final String? statusText;

  const User({
    required this.id,
    required this.name,
    this.handle = '',
    required this.avatarIcon,
    required this.avatarColor,
    this.isAi = false,
    this.verified = false,
    this.status = UserStatus.offline,
    this.statusText,
  });

  bool get isOnline => status == UserStatus.online;

  static const smith = User(
    id: 'u1',
    name: 'Smith',
    avatarIcon: Icons.person,
    avatarColor: Color(0xFF8B5CF6),
    verified: true,
    status: UserStatus.online,
  );

  static const designInspiration = User(
    id: 'u2',
    name: 'Design Inspiration',
    avatarIcon: Icons.palette,
    avatarColor: Color(0xFFF59E0B),
    status: UserStatus.online,
  );

  static const aiAssistant = User(
    id: 'u3',
    name: 'AI Assistant',
    avatarIcon: Icons.auto_awesome,
    avatarColor: Color(0xFF3B82F6),
    isAi: true,
    status: UserStatus.online,
    statusText: 'Ready to help',
  );

  static const emily = User(
    id: 'u4',
    name: 'Emily Johnson',
    avatarIcon: Icons.person_outline,
    avatarColor: Color(0xFFEC4899),
    status: UserStatus.offline,
  );

  static const projectTeam = User(
    id: 'u5',
    name: 'Project Team',
    avatarIcon: Icons.group,
    avatarColor: Color(0xFF10B981),
    status: UserStatus.offline,
  );

  static const mom = User(
    id: 'u6',
    name: 'Mom',
    avatarIcon: Icons.favorite,
    avatarColor: Color(0xFFEF4444),
    status: UserStatus.offline,
  );

  static const alex = User(
    id: 'u7',
    name: 'Alex Rivera',
    avatarIcon: Icons.person,
    avatarColor: Color(0xFF3B82F6),
    status: UserStatus.online,
    statusText: 'In a meeting',
  );

  static const chloe = User(
    id: 'u8',
    name: 'Chloe Chen',
    avatarIcon: Icons.palette,
    avatarColor: Color(0xFFEC4899),
    status: UserStatus.online,
    statusText: 'Exploring colors',
  );

  static const david = User(
    id: 'u9',
    name: 'David Miller',
    avatarIcon: Icons.person_outline,
    avatarColor: Color(0xFF6B7280),
    status: UserStatus.away,
    statusText: 'Away',
  );

  static const sarah = User(
    id: 'u10',
    name: 'Sarah Wilson',
    avatarIcon: Icons.brush,
    avatarColor: Color(0xFF8B5CF6),
    status: UserStatus.online,
    statusText: 'Designing...',
  );

  static const currentUser = User(
    id: 'me',
    name: 'James Henderson',
    handle: '@james_h540',
    avatarIcon: Icons.person,
    avatarColor: Color(0xFF2D2D2D),
  );
}
