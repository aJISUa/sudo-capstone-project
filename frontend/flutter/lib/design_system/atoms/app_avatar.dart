import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.label,
    this.imageUrl,
    this.size = 40,
    super.key,
  });

  /// User-facing name. Initials are derived from this when [imageUrl]
  /// is null.
  final String label;
  final String? imageUrl;
  final double size;

  String get _initials => label
      .split(' ')
      .where((String s) => s.isNotEmpty)
      .map((String s) => s[0])
      .take(2)
      .join()
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = imageUrl;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null
          ? Text(
              _initials,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: size * 0.4,
              ),
            )
          : null,
    );
  }
}
