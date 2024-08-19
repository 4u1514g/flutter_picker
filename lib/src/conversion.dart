import 'package:flutter_picker/src/media_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import 'enums.dart';

class Conversion {
  static Future<MediaModel> toMediaModel(AssetEntity entity) async {
    var mediaType = MediaType.all;
    if (entity.type == AssetType.video) mediaType = MediaType.video;
    if (entity.type == AssetType.image) mediaType = MediaType.image;

    return MediaModel(
      id: entity.id,
      title: entity.title,
      thumbnail: await entity.thumbnailData,
      size: entity.size,
      creationTime: entity.createDateTime,
      modifiedTime: entity.modifiedDateTime,
      latitude: entity.latitude,
      longitude: entity.longitude,
      file: await entity.file,
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

  static AssetEntity toAssetEntity(XFile file, String type) {
    return AssetEntity(
        id: '',
        height: 0,
        width: 0,
        typeInt: 0,
        relativePath: file.path,
        title: file.name,
        mimeType: file.mimeType);
  }
}
