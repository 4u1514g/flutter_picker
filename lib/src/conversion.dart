import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_picker/src/media_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'enums.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Conversion {
  static Future<MediaModel> toMediaModel(AssetEntity entity) async {
    var mediaType = MediaType.all;
    if (entity.type == AssetType.video) mediaType = MediaType.video;
    if (entity.type == AssetType.image) mediaType = MediaType.image;

    File? file = await entity.file;
    File? compress = await compressImageSmart(file!);

    return MediaModel(
      id: entity.id,
      title: entity.title,
      thumbnail: await entity.thumbnailData,
      size: entity.size,
      creationTime: entity.createDateTime,
      modifiedTime: entity.modifiedDateTime,
      latitude: entity.latitude,
      longitude: entity.longitude,
      file: compress,
      mediaByte: await entity.originBytes,
      mediaType: mediaType,
      videoDuration: entity.videoDuration,
    );
  }

  static Future<List<MediaModel>> toMediaList(List<AssetEntity> data) async {
    var conversionTasks = <Future<MediaModel>>[];
    for (int i = 0; i < data.length; i++) {
      conversionTasks.add(toMediaModel(data[i]));
    }
    var results = await Future.wait(conversionTasks);
    return results;
  }

  static Future<File?> compressImageSmart(File file,
      {int maxSizeInBytes = 1024 * 1024}) async {
    final tempDir = await getTemporaryDirectory();

    int quality = 90;
    int minWidth = 1920;
    int minHeight = 1920;

    File result = file;
    List<File> tempFiles = [];

    while (true) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = p.join(
        tempDir.path,
        'compressed_${timestamp}_${p.basename(file.path)}',
      );

      final compressed = await FlutterImageCompress.compressAndGetFile(
        result.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (compressed == null) {
        _cleanupTempFiles(tempFiles);
        return result;
      }

      tempFiles.add(File(compressed.path));

      final size = await compressed.length();

      if (size <= maxSizeInBytes || quality <= 30) {
        tempFiles.removeLast();
        _cleanupTempFiles(tempFiles);
        return File(compressed.path);
      }

      quality -= 10;
      minWidth = (minWidth * 0.9).toInt();
      minHeight = (minHeight * 0.9).toInt();
      result = File(compressed.path);
    }
  }

  static void _cleanupTempFiles(List<File> files) {
    for (final file in files) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
