import 'package:flutter/material.dart';
import '../../widgets/common/video_tile.dart';

class VideosView extends StatelessWidget {
  const VideosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: _VideoGrid(),
    );
  }
}

class _VideoGrid extends StatelessWidget {
  const _VideoGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 121 / 214,
      ),
      itemCount: 9,
      itemBuilder: (context, index) => const VideoTile(borderRadius: 28),
    );
  }
}
