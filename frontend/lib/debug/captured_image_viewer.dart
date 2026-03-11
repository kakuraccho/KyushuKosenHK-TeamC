// デバッグ用: 撮影画像の確認UI
// 本番リリース前に削除すること
import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DebugCapturedImageStrip extends StatelessWidget {
  const DebugCapturedImageStrip({super.key, required this.imagePaths});

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bg,
      child: SizedBox(
        height: 72,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            final path = imagePaths[index];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DebugFullScreenImageViewer(
                    imagePaths: imagePaths,
                    initialIndex: index,
                  ),
                ),
              ),
              child: Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondaryContainer,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DebugFullScreenImageViewer extends StatelessWidget {
  const DebugFullScreenImageViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  final List<String> imagePaths;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${initialIndex + 1} / ${imagePaths.length}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.file(File(imagePaths[index])),
            ),
          );
        },
      ),
    );
  }
}
