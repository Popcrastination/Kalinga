import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// One row in Dashboard's Quick Insight or Overview's Suggestion list.
/// [emoji] stands in for an icon (matches the mockup's use of emoji as
/// lightweight iconography) — swap for an IconData if that changes later.
/// [title] is optional: Dashboard's Quick Insight is a single line with
/// no separate heading, while Overview's suggestions have both.
class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.emoji,
    this.title,
    required this.description,
  });

  final String emoji;
  final String? title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: textTheme.titleMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  description,
                  style: textTheme.labelSmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
