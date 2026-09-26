import 'package:flutter/material.dart';

/// One pill in Dashboard's "Today's Progress" row (Sleep, Meals, Water,
/// Activity). Turns accent-colored once [completed] is true — the data
/// itself comes from wherever today's logs are loaded from, not from
/// this widget.
class ProgressChip extends StatelessWidget {
  const ProgressChip({
    super.key,
    required this.icon,
    required this.label,
    required this.completed,
  });

  final IconData icon;
  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: completed
            ? scheme.secondary.withOpacity(0.15)
            : const Color(0xFFFFF4E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: completed ? scheme.secondary : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
              color: completed ? scheme.secondary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
