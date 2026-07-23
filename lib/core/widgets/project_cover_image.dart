import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that renders a beautiful, deterministic cover image for a project.
///
/// - If [imageUrl] is a real uploaded image (not the placeholder), it displays it.
/// - Otherwise it generates a unique gradient + icon visual keyed by [title] + [category].
class ProjectCoverImage extends StatelessWidget {
  const ProjectCoverImage({
    super.key,
    required this.title,
    required this.category,
    this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String title;
  final String category;
  final String? imageUrl;
  final BoxFit fit;

  // ── Palette bank ──────────────────────────────────────────────────────────
  // 12 visually-distinct, on-brand gradient pairs (start → end)
  static const List<List<Color>> _palettes = [
    [Color(0xFF031636), Color(0xFF1565C0)], // deep navy → vivid blue
    [Color(0xFF0D4F3C), Color(0xFF00897B)], // forest → teal
    [Color(0xFF4A0072), Color(0xFF7B1FA2)], // deep purple → medium purple
    [Color(0xFF1A237E), Color(0xFF283593)], // indigo dark → indigo
    [Color(0xFF1B5E20), Color(0xFF388E3C)], // dark green → green
    [Color(0xFFBF360C), Color(0xFFE64A19)], // deep orange-red
    [Color(0xFF004D40), Color(0xFF00695C)], // deep teal
    [Color(0xFF880E4F), Color(0xFFC2185B)], // dark pink → pink
    [Color(0xFF212121), Color(0xFF424242)], // near-black tones
    [Color(0xFF0277BD), Color(0xFF039BE5)], // dark sky → sky blue
    [Color(0xFF37474F), Color(0xFF546E7A)], // blue-grey
    [Color(0xFF4E342E), Color(0xFF795548)], // dark brown → brown
  ];

  // ── Category → icon mapping ───────────────────────────────────────────────
  static IconData _iconForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('network') || cat.contains('communication')) {
      return Icons.hub_rounded;
    } else if (cat.contains('cyber') || cat.contains('security')) {
      return Icons.security_rounded;
    } else if (cat.contains('software') || cat.contains('application')) {
      return Icons.code_rounded;
    } else if (cat.contains('computer science') || cat.contains('cs')) {
      return Icons.computer_rounded;
    } else if (cat.contains('data') || cat.contains('database')) {
      return Icons.storage_rounded;
    } else if (cat.contains('ai') || cat.contains('machine') || cat.contains('learn')) {
      return Icons.psychology_rounded;
    } else if (cat.contains('mobile') || cat.contains('android') || cat.contains('ios')) {
      return Icons.smartphone_rounded;
    } else if (cat.contains('web') || cat.contains('internet')) {
      return Icons.language_rounded;
    } else if (cat.contains('cloud')) {
      return Icons.cloud_rounded;
    } else if (cat.contains('iot') || cat.contains('embedded')) {
      return Icons.developer_board_rounded;
    } else if (cat.contains('health') || cat.contains('medical')) {
      return Icons.health_and_safety_rounded;
    }
    return Icons.science_rounded;
  }

  // ── Keyword → accent colour hints ─────────────────────────────────────────
  static int _paletteIndex(String title, String category) {
    // Simple but stable hash: sum of char codes, spread across palette count.
    final seed = (title + category)
        .codeUnits
        .fold<int>(0, (prev, c) => (prev * 31 + c) & 0x7FFFFFFF);
    return seed % _palettes.length;
  }

  // ── Detect "real" uploaded image vs generic placeholder ───────────────────
  static bool _isPlaceholder(String? url) {
    if (url == null || url.isEmpty) return true;
    // Common placeholder patterns used in this project
    if (url.contains('placeholder') ||
        url.contains('default') ||
        url.contains('via.placeholder') ||
        url.contains('picsum')) return true;
    // If the URL ends with a known generic name
    final uri = Uri.tryParse(url);
    final path = uri?.path.toLowerCase() ?? '';
    if (path.endsWith('cover_placeholder.png') ||
        path.endsWith('default_cover.jpg') ||
        path.endsWith('no_image.png')) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Try real network image first — fall back to generated visual on error.
    if (imageUrl != null && imageUrl!.isNotEmpty && !_isPlaceholder(imageUrl)) {
      return Image.network(
        imageUrl!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildGeneratedCover(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildGeneratedCover(); // show art immediately while loading
        },
      );
    }
    return _buildGeneratedCover();
  }

  Widget _buildGeneratedCover() {
    final idx = _paletteIndex(title, category);
    final palette = _palettes[idx];
    final icon = _iconForCategory(category);

    return CustomPaint(
      painter: _CoverPainter(
        colorA: palette[0],
        colorB: palette[1],
        seed: idx,
      ),
      child: Center(
        child: _CoverContent(title: title, icon: icon, colorB: palette[1]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter: gradient + subtle geometric circles
// ─────────────────────────────────────────────────────────────────────────────
class _CoverPainter extends CustomPainter {
  const _CoverPainter({
    required this.colorA,
    required this.colorB,
    required this.seed,
  });

  final Color colorA;
  final Color colorB;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final rect = Offset.zero & size;
    final grad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colorA, colorB],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = grad);

    // Decorative circles (deterministic positions from seed)
    final rand = math.Random(seed);
    final circlePaint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final r = 20 + rand.nextDouble() * (size.width * 0.45);
      canvas.drawCircle(Offset(cx, cy), r, circlePaint);
    }

    // Thin ring accents
    final ringPaint = Paint()
      ..color = Colors.white.withAlpha(28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 3; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final r = 30 + rand.nextDouble() * (size.width * 0.35);
      canvas.drawCircle(Offset(cx, cy), r, ringPaint);
    }
  }

  @override
  bool shouldRepaint(_CoverPainter old) =>
      old.colorA != colorA || old.colorB != colorB || old.seed != seed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Centered icon + abbreviated title initials
// ─────────────────────────────────────────────────────────────────────────────
class _CoverContent extends StatelessWidget {
  const _CoverContent({
    required this.title,
    required this.icon,
    required this.colorB,
  });

  final String title;
  final IconData icon;
  final Color colorB;

  String get _initials {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0].substring(0, math.min(2, words[0].length)).toUpperCase();
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Frosted circle with icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(60), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        // Initials badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(22),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _initials,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
