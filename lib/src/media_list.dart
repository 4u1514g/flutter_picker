import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/src/enums.dart';
import 'package:flutter_picker/src/image_item_widget.dart';
import 'package:flutter_picker/src/media_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaList extends StatefulWidget {
  const MediaList({
    super.key,
    required this.album,
    this.scrollController,
    required this.onMediaTilePressed,
    required this.mediaCount,
    required this.mediaType,
    required this.onDone,
  });

  final AssetPathEntity album;
  final ScrollController? scrollController;
  final Function(List<AssetEntity> selectedMedias) onMediaTilePressed;
  final MediaCount mediaCount;
  final MediaType mediaType;
  final ValueChanged<List<MediaModel>> onDone;

  @override
  State<MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<AssetEntity> _mediaList = [];
  var _currentPage = 0;
  late AssetPathEntity _album = widget.album;
  List<AssetEntity> _selectedMedias = [];
  bool _isLoading = false;
  bool _hasMoreToLoad = true;
  bool _isLoadingMore = false;
  int _totalEntitiesCount = 0;

  @override
  void initState() {
    _selectedMedias = [];
    _fetchNewMedia();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MediaList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _album = widget.album;
    final isRefresh = oldWidget.album.id != _album.id;
    if (isRefresh ) {
      _fetchNewMedia();
    }

  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    bool z = MediaQuery.of(context).size.shortestSide < 400;
    return GridView.builder(
        controller: widget.scrollController,
        itemCount: _mediaList.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: z ? 3 : 4, crossAxisSpacing: 5, mainAxisSpacing: 5),
        itemBuilder: (_, index) {
          if (index == _mediaList.length - 8 && !_isLoadingMore && _hasMoreToLoad) {
            _loadMoreAsset();
          }
          if (index == 0) {
            return GestureDetector(
              onTap: onCamera,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Image(
                    image: AssetImage('packages/flutter_picker/assets/camera.png'), height: 34),
              ),
            );
          }

          final AssetEntity entity = _mediaList[index - 1];
          return ImageItemWidget(
            onTap: () {
              _onMediaTileSelected(_isPreviouslySelected(entity), entity);
            },
            key: ValueKey<int>(index - 1),
            entity: entity,
            option: const ThumbnailOption(size: ThumbnailSize.square(200)),
            index: _getSelectionIndex(entity),
            isSelected: _isPreviouslySelected(entity),
          );
        });
  }

  void _fetchNewMedia() async {
    setState(() {
      _currentPage = 0;
      _mediaList.clear();
      _isLoading = true;
    });

    final result = await PhotoManager.requestPermissionExtend();
    _totalEntitiesCount = await _album.assetCountAsync;
    if (result == PermissionState.authorized || result == PermissionState.limited) {
      final newAssets = await _album.getAssetListPaged(page: 0, size: 20);
      if (newAssets.isEmpty) {
        return;
      }
      setState(() {
        _mediaList = newAssets;
        _isLoading = false;
        _hasMoreToLoad = _mediaList.length < _totalEntitiesCount;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities =
        await _album.getAssetListPaged(page: _currentPage + 1, size: 20);
    if (!mounted) {
      return;
    }
    setState(() {
      _mediaList.addAll(entities);
      _currentPage++;
      _hasMoreToLoad = _mediaList.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  bool _isPreviouslySelected(AssetEntity entity) {
    return _selectedMedias.any((element) => element.id == entity.id);
  }

  int? _getSelectionIndex(AssetEntity entity) {
    var index = _selectedMedias.indexWhere((element) => element.id == entity.id);
    if (index == -1) return null;
    return index + 1;
  }

  void _onMediaTileSelected(bool isSelected, AssetEntity entity) {
    if (widget.mediaCount == MediaCount.single) {
      setState(() => _selectedMedias = [entity]);
    } else {
      if (isSelected) {
        setState(() => _selectedMedias.removeWhere((m) => entity.id == m.id));
      } else {
        setState(() => _selectedMedias.add(entity));
      }
    }
    widget.onMediaTilePressed(_selectedMedias);
  }

  final picker = ImagePicker();

  void onCamera() {
    if (widget.mediaType == MediaType.image) {
      picker.pickImage(source: ImageSource.camera).then((pickedFile) async {
        if (pickedFile != null) {
          final converted = MediaModel(
            id: UniqueKey().toString(),
            thumbnail: await pickedFile.readAsBytes(),
            creationTime: DateTime.now(),
            mediaByte: await pickedFile.readAsBytes(),
            title: 'capturedImage',
            file: File(pickedFile.path),
          );
          widget.onDone([converted]);
        }
      });
    } else {
      showModalBottomSheet(context: context, builder: (context) => _mediaFromCam());
    }
  }

  _mediaFromCam() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            picker.pickImage(source: ImageSource.camera).then((pickedFile) async {
              if (pickedFile != null) {
                Navigator.pop(context);
                final converted = MediaModel(
                  id: UniqueKey().toString(),
                  thumbnail: await pickedFile.readAsBytes(),
                  creationTime: DateTime.now(),
                  mediaByte: await pickedFile.readAsBytes(),
                  title: 'capturedImage',
                  file: File(pickedFile.path),
                );
                widget.onDone([converted]);
              }
            });
          },
          child: Container(
            height: 50,
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text('Chụp ảnh', style: TextStyle(fontSize: 14)),
          ),
        ),
        Container(height: 1, color: const Color(0xffF8F9FB)),
        GestureDetector(
          onTap: () {
            picker.pickVideo(source: ImageSource.camera).then((pickedFile) async {
              if (pickedFile != null) {
                Navigator.pop(context);
                final converted = MediaModel(
                  id: UniqueKey().toString(),
                  thumbnail: await pickedFile.readAsBytes(),
                  creationTime: DateTime.now(),
                  mediaByte: await pickedFile.readAsBytes(),
                  title: 'capturedImage',
                  file: File(pickedFile.path),
                );
                widget.onDone([converted]);
              }
            });
          },
          child: Container(
            height: 50,
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text('Quay video', style: TextStyle(fontSize: 14)),
          ),
        ),
        Container(height: 5, color: const Color(0xffF8F9FB)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 50,
            color: Colors.white,
            alignment: Alignment.center,
            child: const Text('Đóng', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
