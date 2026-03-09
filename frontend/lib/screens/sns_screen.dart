import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/common/app_bar.dart';

class SnsScreen extends StatefulWidget {
  const SnsScreen({super.key});

  @override
  State<SnsScreen> createState() => _SnsScreenState();
}

class _SnsScreenState extends State<SnsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FocusAppBar(title: 'SNS'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.thumbnailBg),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _ReelsOverlay(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ReelsOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          Expanded(child: _ReelsLeftBar()),
          SizedBox(width: 14),
          _ReelsRightBar(),
        ],
      ),
    );
  }
}

class _ReelsLeftBar extends StatelessWidget {
  const _ReelsLeftBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer,
              ),
              child: const Icon(Icons.person, size: 18, color: AppColors.onSurface),
            ),
            const SizedBox(width: 10),
            const Text(
              'your.name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Lorem metus porttitor purus enim. Non et mauris quam porttitor faucibus id.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            letterSpacing: -0.14,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_note, size: 10, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Lorem metus porttitor purus enim.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReelsRightBar extends StatelessWidget {
  const _ReelsRightBar();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ReelAction(icon: Icons.favorite_border, count: '5000'),
        const SizedBox(height: 23),
        const _ReelAction(icon: Icons.chat_bubble_outline, count: '6000'),
        const SizedBox(height: 23),
        const Icon(Icons.more_horiz, size: 15, color: Colors.white),
        const SizedBox(height: 28),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondaryContainer,
          ),
          child: const Icon(Icons.music_note, size: 14, color: Colors.white),
        ),
      ],
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String count;

  const _ReelAction({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 23, color: Colors.white),
        const SizedBox(height: 12),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.24,
          ),
        ),
      ],
    );
  }
}
