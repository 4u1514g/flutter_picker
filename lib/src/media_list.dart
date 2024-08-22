import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/src/camera_tile.dart';
import 'package:flutter_picker/src/enums.dart';
import 'package:flutter_picker/src/media_item_tile.dart';
import 'package:flutter_picker/src/media_model.dart';
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
    if (isRefresh && _album.id.isEmpty) {
      _fetchNewMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _album.id.isNotEmpty) {
      return const Center(child: CupertinoActivityIndicator());
    }

    bool z = MediaQuery.of(context).size.shortestSide < 400;
    return Column(
      children: [
        Expanded(
            child: GridView.builder(
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
                    return CameraTile(mediaType: widget.mediaType, onDone: widget.onDone);
                  }

                  final AssetEntity entity = _mediaList[index - 1];
                  return MediaItemTile(
                    onTap: () {
                      _onMediaTileSelected(_isPreviouslySelected(entity), entity);
                    },
                    key: ValueKey<int>(index - 1),
                    entity: entity,
                    option: const ThumbnailOption(size: ThumbnailSize.square(200)),
                    index: _getSelectionIndex(entity),
                    isSelected: _isPreviouslySelected(entity),
                  );
                })),
        if( _album.id.isEmpty)
        Column(
          children: [
            const SizedBox(height: 50),
            const Image(
                image: AssetImage('packages/flutter_picker/assets/camera add.png'), height: 55),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Bạn có thể sử dụng camera để chụp ảnh\nhoặc quay video',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xff777777), height: 1.5)),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          ],
        )
      ],
    );
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
}
