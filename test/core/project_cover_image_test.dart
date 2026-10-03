import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp_expo_hub/core/widgets/project_cover_image.dart';

void main() {
  group('ProjectCoverImage.iconForCategory', () {
    test('matches whole words, not substrings', () {
      expect(ProjectCoverImage.iconForCategory('Physics'), Icons.science_rounded);
      expect(ProjectCoverImage.iconForCategory('Retail Analytics'), Icons.science_rounded);
      expect(ProjectCoverImage.iconForCategory('Statistics'), Icons.science_rounded);
    });

    test('still maps the real categories', () {
      expect(ProjectCoverImage.iconForCategory('Artificial Intelligence AI'), Icons.psychology_rounded);
      expect(ProjectCoverImage.iconForCategory('CS'), Icons.computer_rounded);
      expect(ProjectCoverImage.iconForCategory('Computer Science'), Icons.computer_rounded);
      expect(ProjectCoverImage.iconForCategory('Networking & Communication'), Icons.hub_rounded);
      expect(ProjectCoverImage.iconForCategory('Cybersecurity'), Icons.security_rounded);
      expect(ProjectCoverImage.iconForCategory('Mobile iOS'), Icons.smartphone_rounded);
      expect(ProjectCoverImage.iconForCategory('IoT'), Icons.developer_board_rounded);
    });
  });

  group('ProjectCoverImage.isPlaceholderUrl', () {
    test('real photos survive even if the URL contains "default"', () {
      expect(ProjectCoverImage.isPlaceholderUrl('https://cdn.example.com/default-theme/team-photo.jpg'), isFalse);
      expect(ProjectCoverImage.isPlaceholderUrl('https://x.supabase.co/storage/v1/object/public/covers/p1.png'), isFalse);
    });

    test('stock covers are still placeholders', () {
      expect(ProjectCoverImage.isPlaceholderUrl(null), isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl(''), isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl('https://placehold.co/400x250'), isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl('https://x.co/covers/default_cover.jpg'), isTrue);
      expect(ProjectCoverImage.isPlaceholderUrl('https://x.co/covers/default.png'), isTrue);
    });
  });
}
