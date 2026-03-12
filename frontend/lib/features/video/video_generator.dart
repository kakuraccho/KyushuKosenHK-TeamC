import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VideoGenerator {
  VideoGenerator._();

  /// 画像パスのリストからタイムラプスMP4を生成して返す。
  /// 失敗時は null を返す。
  static Future<String?> generateFromImages(
    List<String> imagePaths, {
    double frameDuration = 0.5,
  }) async {
    if (imagePaths.isEmpty) return null;

    try {
      final tmpDir = await getTemporaryDirectory();
      final listFile = File('${tmpDir.path}/timelapse_list.txt');
      final outputPath =
          '${tmpDir.path}/timelapse_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // concat demuxer 用リストファイルを生成
      final buffer = StringBuffer();
      for (final path in imagePaths) {
        buffer.writeln("file '$path'");
        buffer.writeln('duration $frameDuration');
      }
      // 最後のフレームを再追加（concat demuxer の末尾バグ回避）
      buffer.writeln("file '${imagePaths.last}'");
      await listFile.writeAsString(buffer.toString());

      final cmd =
          '-f concat -safe 0 -i "${listFile.path}" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v mpeg4 -pix_fmt yuv420p "$outputPath"';

      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('VideoGenerator: success -> $outputPath');
        return outputPath;
      } else {
        final logs = await session.getLogsAsString();
        debugPrint('VideoGenerator: failed\n$logs');
        return null;
      }
    } catch (e) {
      debugPrint('VideoGenerator exception: $e');
      return null;
    }
  }
}
