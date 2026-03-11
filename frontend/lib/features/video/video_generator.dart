import 'dart:io';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VideoGenerator {
  /// 静止画リストからタイムラプスMP4を生成する。
  /// [imagePaths]: 時系列順の画像ファイルパスリスト
  /// [frameDuration]: 1フレームの表示秒数（デフォルト0.5秒 = 2fps）
  /// 戻り値: 生成された動画のパス。失敗時はnull。
  static Future<String?> generateFromImages(
    List<String> imagePaths, {
    double frameDuration = 0.5,
  }) async {
    if (imagePaths.isEmpty) return null;

    final tmpDir = await getTemporaryDirectory();
    final listFilePath = '${tmpDir.path}/framelist.txt';
    final outputPath =
        '${tmpDir.path}/timelapse_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // concat demuxer用リストファイルを生成
    final buffer = StringBuffer();
    for (final path in imagePaths) {
      buffer.writeln("file '$path'");
      buffer.writeln('duration $frameDuration');
    }
    // 最後のフレームを再度追加（FFmpegのconcatデモクサー要件）
    buffer.writeln("file '${imagePaths.last}'");
    await File(listFilePath).writeAsString(buffer.toString());

    final command =
        '-f concat -safe 0 -i "$listFilePath" -c:v libx264 -pix_fmt yuv420p -y "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }

    debugPrint('FFmpeg error: ${await session.getOutput()}');
    return null;
  }
}
