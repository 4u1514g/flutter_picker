import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class MediaItemTile extends StatelessWidget {
  const MediaItemTile({
    super.key,
    required this.entity,
    required this.option,
    required this.isSelected,
    this.onTap,
    this.index,
  });

  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;
  final bool isSelected;
  final int? index;

  Widget buildContent(BuildContext context) {
    if (entity.type == AssetType.audio) {
      return const Center(child: Icon(Icons.audiotrack, size: 30));
    }
    return _buildImageWidget(context, entity, option);
  }

  Widget _buildImageWidget(BuildContext context, AssetEntity entity, ThumbnailOption option) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: AssetEntityImage(
            entity,
            isOriginal: false,
            thumbnailSize: option.size,
            thumbnailFormat: option.format,
            fit: BoxFit.cover,
          ),
        ),
        PositionedDirectional(
          bottom: 4,
          start: 0,
          end: 0,
          child: Row(
            children: [
              if (entity.isFavorite)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (entity.isLivePhoto)
                      Container(
                        margin: const EdgeInsetsDirectional.only(end: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                          color: Theme.of(context).cardColor,
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    Icon(() {
                      switch (entity.type) {
                        case AssetType.other:
                          return Icons.abc;
                        case AssetType.image:
                          return Icons.image;
                        case AssetType.video:
                          return Icons.video_file;
                        case AssetType.audio:
                          return Icons.audiotrack;
                      }
                    }(), color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Positioned(
              top: 3,
              right: 3,
              child: Container(
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                alignment: Alignment.center,
                height: 20,
                width: 20,
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, height: 1),
                ),
              ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: buildContent(context),
    );
  }
}
