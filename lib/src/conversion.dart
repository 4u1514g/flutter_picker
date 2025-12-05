import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_picker/src/media_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'enums.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p show extension, join;

class Conversion {
  static Future<MediaModel> toMediaModel(AssetEntity entity) async {
    var mediaType = MediaType.all;
    if (entity.type == AssetType.video) mediaType = MediaType.video;
    if (entity.type == AssetType.image) mediaType = MediaType.image;

    File? file = await entity.file;
    File? compress = await compressImage(file!);

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

  static Future<File?> compressImage(File file) async {
    final fileSize = await file.length(); // byte
    final sizeMB = fileSize / (1024 * 1024);

    if (sizeMB <= 2) return file;

    final tempDir = await getTemporaryDirectory();
    final ext = p.extension(file.path).toLowerCase();

    late CompressFormat format;
    late String targetExt;

    switch (ext) {
      case '.jpg':
      case '.jpeg':
        format = CompressFormat.jpeg;
        targetExt = '.jpg';
        break;
      case '.png':
        format = CompressFormat.png;
        targetExt = '.png';
        break;
      case '.webp':
        format = CompressFormat.webp;
        targetExt = '.webp';
        break;
      case '.heic':
      case '.heif':
        format = CompressFormat.heic;
        targetExt = '.heic';
        break;
      default:
        format = CompressFormat.jpeg;
        targetExt = '.jpg';
    }

    int quality;
    int maxSizePx = 1024;

    if (sizeMB <= 18) {
      const double minSize = 2;
      const double maxSize = 18;
      const int maxQuality = 80;
      const int minQuality = 10;

      final t = ((sizeMB - minSize) / (maxSize - minSize)).clamp(0.0, 1.0);
      quality = (maxQuality - t * (maxQuality - minQuality)).toInt();
    } else {
      quality = 10;

    }

    final targetPath = p.join(
      tempDir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}$targetExt',
    );

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: quality,
      minWidth: maxSizePx,
      minHeight: maxSizePx,
      format: format,
    );

    return File(compressed!.path);
  }
}
