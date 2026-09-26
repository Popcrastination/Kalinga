import 'package:flutter/material.dart';

/// One tappable row in Daily Log (Breakfast/Lunch/Dinner/Drinks). Shows a
/// "+" until [isLogged] is true, then swaps to a check — the row itself
/// doesn't know *how* an entry gets logged (Gemini validation, Supabase
/// insert); it just reports the tap and displays the state it's given.
class AddEntryRow extends StatelessWidget {
  const AddEntryRow({
    super.key,
    required this.label,
    required this.isLogged,
    required this.onTap,
  });

  final String label;
  final bool isLogged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEFEFEF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isLogged ? scheme.secondary : null,
                    fontWeight: isLogged ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLogged ? scheme.secondary : Colors.transparent,
                border: Border.all(
                  color: isLogged ? scheme.secondary : scheme.secondary,
                  width: 1.5,
                ),
              ),
              child: Icon(
                isLogged ? Icons.check : Icons.add,
                size: 14,
                color: isLogged ? Colors.white : scheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
