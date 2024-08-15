import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import 'enums.dart';

class PickerWidget extends StatefulWidget {
  const PickerWidget({
    super.key,
    this.mediaCount = MediaCount.multiple,
    this.mediaType = MediaType.all,
  });

  ///make picker to select multiple or single media file
  final MediaCount mediaCount;

  ///Make picker to select specific type of media, video or image
  final MediaType mediaType;

  @override
  State<PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  AssetPathEntity? _selectedAlbum;

  Future<List<AssetPathEntity>> _fetchAlbums() async {
    var type = RequestType.common;
    if (widget.mediaType == MediaType.all) {
      type = RequestType.common;
    } else if (widget.mediaType == MediaType.video) {
      type = RequestType.video;
    } else if (widget.mediaType == MediaType.image) {
      type = RequestType.image;
    }

    final result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.authorized || (result == PermissionState.limited)) {
      return await PhotoManager.getAssetPathList(type: type);
    } else {
      PhotoManager.openSetting();
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FutureBuilder(
        future: _fetchAlbums(),
        builder: _builder,
      ),
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot<List<AssetPathEntity>> snapshot) {
    if (snapshot.hasData) {
      final albums = snapshot.data!;
      if (albums.isEmpty) {
        return const Opacity(
          opacity: 0.4,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_not_supported_outlined, size: 50),
                SizedBox(height: 20),
                Text(
                  'No Images Available',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        );
      }
    }

    return const Center(child: CupertinoActivityIndicator());
  }
}
