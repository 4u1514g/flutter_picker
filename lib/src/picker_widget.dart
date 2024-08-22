import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/src/album_selector.dart';
import 'package:flutter_picker/src/conversion.dart';
import 'package:flutter_picker/src/header.dart';
import 'package:flutter_picker/src/media_list.dart';
import 'package:flutter_picker/src/media_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'enums.dart';

class PickerWidget extends StatefulWidget {
  const PickerWidget({
    super.key,
    required this.onPicked,
    this.mediaCount = MediaCount.single,
    this.mediaType = MediaType.image,
  });

  ///CallBack on image pick is done
  final ValueChanged<List<MediaModel>> onPicked;

  ///make picker to select multiple or single media file
  final MediaCount mediaCount;

  ///Make picker to select specific type of media, video or image
  final MediaType mediaType;

  @override
  State<PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  AssetPathEntity? _selectedAlbum;
  final _albumController = PanelController();
  final _headerController = GlobalKey<HeaderState>();

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
      return Future.error(Exception('permission denied'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xffF8F9FB),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: FutureBuilder(
        future: _fetchAlbums(),
        builder: _builder,
      ),
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot<List<AssetPathEntity>> snapshot) {
    if (snapshot.hasData) {
      final albums = snapshot.data!;
      final defaultSelectedAlbum = albums.firstOrNull ?? AssetPathEntity(id: '', name: 'Recent');
      Widget header = Header(
          key: _headerController,
          onBack: handleBackPress,
          onDone: (data) async {
            var result = await Conversion.toMediaList(data);
            widget.onPicked(result);
          },
          mediaCount: widget.mediaCount,
          albumController: _albumController,
          selectedAlbum: _selectedAlbum ?? defaultSelectedAlbum);
      return Column(
        children: [
          header,
          Expanded(
              child: Stack(
            children: [
              Positioned.fill(
                child: MediaList(
                  album: _selectedAlbum ?? defaultSelectedAlbum,
                  onMediaTilePressed: _onMediaTilePressed,
                  mediaCount: widget.mediaCount,
                  mediaType: widget.mediaType,
                  onDone: (data) async {
                    widget.onPicked(data);
                    Navigator.pop(context);
                  },
                ),
              ),
              AlbumSelector(
                panelController: _albumController,
                albums: albums,
                onSelect: _onAlbumSelected,
              )
            ],
          ))
        ],
      );
    }

    if (snapshot.hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(image: AssetImage('packages/flutter_picker/assets/photo.png'), height: 60),
          const SizedBox(height: 10),
          const Text('Không có quyền truy cập vào album',
              style: TextStyle(fontSize: 15, color: Color(0xff777777))),
          const SizedBox(height: 10, width: double.infinity),
          TextButton(
              onPressed: () => PhotoManager.openSetting().then((value) => Navigator.pop(context)),
              child: const Text('Cài đặt', style: TextStyle(fontSize: 15, color: Colors.blue))),
          const SizedBox(height: 30),
        ],
      );
    }
    return const Center(child: CupertinoActivityIndicator());
  }

  void handleBackPress() {
    if (_albumController.isPanelOpen) {
      _albumController.close();
    } else {
      Navigator.pop(context);
    }
  }

  void _onAlbumSelected(AssetPathEntity album) {
    _headerController.currentState?.closeAlbumDrawer();
    setState(() => _selectedAlbum = album);
  }

  Future _onMediaTilePressed(List<AssetEntity> selectedMedias) async {
    _headerController.currentState?.updateSelection(selectedMedias);
  }
}
