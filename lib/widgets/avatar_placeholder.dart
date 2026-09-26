import 'package:flutter/material.dart';

/// Placeholder profile picture — used until image upload is built
/// (a stretch goal). Shows [imageUrl] when one is provided, otherwise a
/// generic person icon. This is the "placeholder for the Kalinga-brand
/// part" mentioned in the task — no real asset exists yet.
class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({super.key, this.radius = 28, this.imageUrl});

  final double radius;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (imageUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFFFF4E1),
      child: Icon(Icons.person, color: scheme.secondary, size: radius),
    );
  }
}
