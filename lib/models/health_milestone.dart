import 'package:flutter/material.dart';

class HealthMilestone {
  final String title;
  final String description;
  final Duration timeRequired;
  final IconData icon;
  final Color color;

  const HealthMilestone({
    required this.title,
    required this.description,
    required this.timeRequired,
    required this.icon,
    required this.color,
  });
}

/// Science-based health milestones after reducing/quitting smoking.
const healthMilestones = <HealthMilestone>[
  HealthMilestone(
    title: 'First Step',
    description: 'You started tracking. Awareness is the first step to change.',
    timeRequired: Duration.zero,
    icon: Icons.flag,
    color: Color(0xFF9E9E9E),
  ),
  HealthMilestone(
    title: 'Heart Rate Normalizing',
    description:
        'Within 20 minutes of not smoking, your heart rate begins to drop back to normal.',
    timeRequired: Duration(hours: 1),
    icon: Icons.favorite,
    color: Color(0xFFE91E63),
  ),
  HealthMilestone(
    title: 'Carbon Monoxide Clearing',
    description:
        'After 12 hours, the carbon monoxide level in your blood drops to normal.',
    timeRequired: Duration(hours: 12),
    icon: Icons.air,
    color: Color(0xFF2196F3),
  ),
  HealthMilestone(
    title: 'Circulation Improving',
    description:
        'After 1 day, your risk of heart attack begins to decrease as blood pressure drops.',
    timeRequired: Duration(days: 1),
    icon: Icons.bloodtype,
    color: Color(0xFFF44336),
  ),
  HealthMilestone(
    title: 'Nerve Endings Regrowing',
    description:
        'After 2 days, nerve endings begin to regrow. Taste and smell start to improve.',
    timeRequired: Duration(days: 2),
    icon: Icons.restaurant,
    color: Color(0xFFFF9800),
  ),
  HealthMilestone(
    title: 'Breathing Easier',
    description:
        'After 3 days, bronchial tubes relax, lung capacity starts increasing.',
    timeRequired: Duration(days: 3),
    icon: Icons.self_improvement,
    color: Color(0xFF4CAF50),
  ),
  HealthMilestone(
    title: 'Energy Boost',
    description:
        'After 1 week, your body\'s circulation has noticeably improved. Walking is easier.',
    timeRequired: Duration(days: 7),
    icon: Icons.bolt,
    color: Color(0xFFFFEB3B),
  ),
  HealthMilestone(
    title: 'Lung Recovery',
    description:
        'After 2 weeks, lung function begins to improve. Coughing and shortness of breath decrease.',
    timeRequired: Duration(days: 14),
    icon: Icons.healing,
    color: Color(0xFF00BCD4),
  ),
  HealthMilestone(
    title: 'Circulation Restored',
    description:
        'After 1 month, circulation has significantly improved. Physical activity feels easier.',
    timeRequired: Duration(days: 30),
    icon: Icons.directions_run,
    color: Color(0xFF8BC34A),
  ),
  HealthMilestone(
    title: 'Cilia Regrown',
    description:
        'After 1-3 months, the cilia in your lungs regrow, reducing infection risk.',
    timeRequired: Duration(days: 60),
    icon: Icons.shield,
    color: Color(0xFF3F51B5),
  ),
  HealthMilestone(
    title: 'Half-Year Milestone',
    description:
        'After 6 months, your airways are much less inflamed. Energy and breathing are noticeably better.',
    timeRequired: Duration(days: 180),
    icon: Icons.star,
    color: Color(0xFF9C27B0),
  ),
  HealthMilestone(
    title: 'One Year Free',
    description:
        'After 1 year, your risk of coronary heart disease is half that of a smoker.',
    timeRequired: Duration(days: 365),
    icon: Icons.emoji_events,
    color: Color(0xFFFFD700),
  ),
];
