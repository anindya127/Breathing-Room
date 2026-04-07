import 'package:flutter/material.dart';

class AppBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final BadgeCategory category;

  const AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
  });
}

enum BadgeCategory {
  streak('Streaks'),
  reduction('Reduction'),
  money('Money'),
  milestone('Milestones');

  final String label;
  const BadgeCategory(this.label);
}

/// All available badges in the app.
const allBadges = <AppBadge>[
  // ── Streak badges ──
  AppBadge(
    id: 'under_budget_1',
    title: 'First Day Under Budget',
    description: 'Stayed under your daily limit for the first time.',
    icon: Icons.verified,
    color: Color(0xFF4CAF50),
    category: BadgeCategory.streak,
  ),
  AppBadge(
    id: 'streak_3',
    title: '3-Day Streak',
    description: 'Under your limit for 3 days in a row.',
    icon: Icons.local_fire_department,
    color: Color(0xFFFF9800),
    category: BadgeCategory.streak,
  ),
  AppBadge(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Under your limit for 7 days straight.',
    icon: Icons.military_tech,
    color: Color(0xFFE91E63),
    category: BadgeCategory.streak,
  ),
  AppBadge(
    id: 'streak_14',
    title: 'Two-Week Champion',
    description: '14 consecutive days under your limit.',
    icon: Icons.shield,
    color: Color(0xFF9C27B0),
    category: BadgeCategory.streak,
  ),
  AppBadge(
    id: 'streak_30',
    title: 'Monthly Master',
    description: '30 days under your limit. Incredible willpower!',
    icon: Icons.emoji_events,
    color: Color(0xFFFFD700),
    category: BadgeCategory.streak,
  ),

  // ── Reduction badges ──
  AppBadge(
    id: 'half_baseline',
    title: 'Halfway There',
    description: 'Your daily average dropped to half your baseline.',
    icon: Icons.trending_down,
    color: Color(0xFF2196F3),
    category: BadgeCategory.reduction,
  ),
  AppBadge(
    id: 'quarter_baseline',
    title: 'Almost Free',
    description: 'Daily average is 25% of your starting baseline.',
    icon: Icons.air,
    color: Color(0xFF00BCD4),
    category: BadgeCategory.reduction,
  ),
  AppBadge(
    id: 'zero_day',
    title: 'Smoke-Free Day',
    description: 'You went a full day without smoking!',
    icon: Icons.smoke_free,
    color: Color(0xFF4CAF50),
    category: BadgeCategory.reduction,
  ),
  AppBadge(
    id: 'avoided_100',
    title: '100 Smokes Avoided',
    description: 'You skipped 100 cigarettes compared to your baseline.',
    icon: Icons.block,
    color: Color(0xFF607D8B),
    category: BadgeCategory.reduction,
  ),
  AppBadge(
    id: 'avoided_500',
    title: '500 Smokes Avoided',
    description: 'Half a thousand cigarettes you didn\'t smoke.',
    icon: Icons.security,
    color: Color(0xFF795548),
    category: BadgeCategory.reduction,
  ),

  // ── Money badges ──
  AppBadge(
    id: 'saved_10',
    title: 'First Tenner',
    description: 'Saved your first \$10 by cutting back.',
    icon: Icons.savings,
    color: Color(0xFF8BC34A),
    category: BadgeCategory.money,
  ),
  AppBadge(
    id: 'saved_50',
    title: 'Fifty Saved',
    description: 'You\'ve saved \$50. That\'s real money!',
    icon: Icons.account_balance_wallet,
    color: Color(0xFF4CAF50),
    category: BadgeCategory.money,
  ),
  AppBadge(
    id: 'saved_100',
    title: 'Triple Digits',
    description: '\$100 saved. You could buy something nice.',
    icon: Icons.diamond,
    color: Color(0xFF00BCD4),
    category: BadgeCategory.money,
  ),
  AppBadge(
    id: 'saved_500',
    title: 'Half Grand',
    description: '\$500 saved from not smoking. Life-changing!',
    icon: Icons.rocket_launch,
    color: Color(0xFFFFD700),
    category: BadgeCategory.money,
  ),

  // ── Milestone badges ──
  AppBadge(
    id: 'first_log',
    title: 'Getting Started',
    description: 'You logged your very first cigarette. Awareness begins!',
    icon: Icons.flag,
    color: Color(0xFF9E9E9E),
    category: BadgeCategory.milestone,
  ),
  AppBadge(
    id: 'week_1',
    title: 'One Week In',
    description: 'You\'ve been tracking for a full week.',
    icon: Icons.calendar_today,
    color: Color(0xFF3F51B5),
    category: BadgeCategory.milestone,
  ),
  AppBadge(
    id: 'month_1',
    title: 'One Month Strong',
    description: '30 days of tracking. Commitment is key.',
    icon: Icons.calendar_month,
    color: Color(0xFF673AB7),
    category: BadgeCategory.milestone,
  ),
];
