import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AlbumSelector extends StatelessWidget {
  const AlbumSelector({
    super.key,
    required this.onSelect,
    required this.albums,
    required this.panelController,
  });

  final ValueChanged<AssetPathEntity> onSelect;
  final List<AssetPathEntity> albums;
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      final albumTiles = albums
          .map((album) => AlbumTile(album: album, onSelect: () => onSelect(album)))
          .toList(growable: false);

      return SlidingUpPanel(
        controller: panelController,
        minHeight: 0,
        color: const Color(0xfffafafa),
        maxHeight: constrains.maxHeight,
        boxShadow: [],
        panelBuilder: (sc) {
          return ListView.builder(
            controller: sc,
            itemBuilder: (_, index) => albumTiles[index],
            itemCount: albumTiles.length,
          );
        },
      );
    });
  }
}

class AlbumTile extends StatelessWidget {
  const AlbumTile({super.key, required this.album, required this.onSelect});

  final AssetPathEntity album;
  final VoidCallback onSelect;

  Future<Uint8List?> _getAlbumThumb(AssetPathEntity album) async {
    final media = await album.getAssetListPaged(page: 0, size: 1);

    if (media.isNotEmpty) {
      return media[0].thumbnailDataWithSize(const ThumbnailSize(80, 80));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: 80,
            height: 80,
            child: FutureBuilder(future: _getAlbumThumb(album), builder: _builder),
          ),
          const SizedBox(width: 10),
          Text(
            album.name,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          const SizedBox(width: 5),
          FutureBuilder(future: album.assetCountAsync, builder: _assetCountBuilder),
        ],
      ),
    );
  }

  Widget _assetCountBuilder(
    BuildContext context,
    AsyncSnapshot<int> snapshot,
  ) {
    return Text(
      '${snapshot.data ?? 0}',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _builder(
    BuildContext context,
    AsyncSnapshot<Uint8List?> snapshot,
  ) {
    if (snapshot.hasError) {
      return Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey.shade400,
          size: 40,
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.done) {
      final albumThumb = snapshot.data;

      if (albumThumb == null) {
        return Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.grey.shade400,
            size: 40,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            albumThumb,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      return const Center(child: CupertinoActivityIndicator());
    }
  }
}
