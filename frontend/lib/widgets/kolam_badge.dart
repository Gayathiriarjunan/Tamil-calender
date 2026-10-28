import 'package:flutter/material.dart';
import '../app/theme.dart';

class KolamBadge extends StatelessWidget {
  const KolamBadge({super.key, this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.88, end: 1),
    duration: const Duration(milliseconds: 1100),
    curve: Curves.easeInOut,
    builder: (context, value, child) => Transform.scale(
      scale: value,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: softGold.withValues(alpha: .7)),
          gradient: const LinearGradient(colors: [deepPurple, royalPurple]),
          boxShadow: [BoxShadow(color: royalPurple.withValues(alpha: .28), blurRadius: 16)],
        ),
        child: Icon(Icons.spa_rounded, color: softGold, size: size * .52),
      ),
    ),
  );
}
