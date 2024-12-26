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
        if (entity.type == AssetType.video)
          Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                child: Text(_duration(entity.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              )),
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

  String _duration(int duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits((duration ~/ 60).remainder(60));
    String twoDigitSeconds = twoDigits(duration.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
