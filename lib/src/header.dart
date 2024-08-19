import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_picker/src/enums.dart';
import 'package:flutter_picker/src/jumping_button.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
    required this.selectedAlbum,
    required this.onBack,
    required this.onDone,
    required this.albumController,
    required this.mediaCount,
  });

  final AssetPathEntity selectedAlbum;
  final VoidCallback onBack;
  final PanelController albumController;
  final ValueChanged<List<AssetEntity>> onDone;
  final MediaCount mediaCount;

  @override
  HeaderState createState() => HeaderState();
}

class HeaderState extends State<Header> with TickerProviderStateMixin {
  static const _arrowDown = 0.0;
  static const _arrowUp = 1.0;
  late List<AssetEntity> _selectedMedia = [];
  late final _arrowAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final _arrowAnimation =
      Tween<double>(begin: _arrowDown, end: _arrowUp).animate(_arrowAnimController);

  void updateSelection(List<AssetEntity> selectedMediaList) {
    if (widget.mediaCount == MediaCount.multiple) {
      setState(() {
        _selectedMedia = selectedMediaList;
      });
    } else if (selectedMediaList.length == 1) {
      widget.onDone(selectedMediaList);
      Navigator.pop(context);
    }
  }

  void closeAlbumDrawer() {
    widget.albumController.close();
    _arrowAnimController.reverse();
  }

  void _onLabelPressed() {
    if (widget.albumController.isPanelOpen) {
      widget.albumController.close();
      _arrowAnimController.reverse();
    }
    if (widget.albumController.isPanelClosed) {
      widget.albumController.open();
      _arrowAnimController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget albumPicker = JumpingButton(
      onTap: _onLabelPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.selectedAlbum.name, key: ValueKey<String>(widget.selectedAlbum.id)),
          const SizedBox(width: 2),
          AnimatedBuilder(
            animation: _arrowAnimation,
            builder: (context, child) => Transform.rotate(
              angle: _arrowAnimation.value * pi,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );

    onSelectionDone() {
      widget.onDone(_selectedMedia);
      Navigator.pop(context);
    }

    onBack() {
      if (_arrowAnimation.value == _arrowUp) {
        _arrowAnimController.reverse();
      }
      widget.onBack();
    }

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: onBack),
          const Spacer(),
          albumPicker,
          const Spacer(),
          GestureDetector(
            onTap: onSelectionDone,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 30,
              alignment: Alignment.center,
              width: 56,
              child: const Text('Xong',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
            ),
          )
        ],
      ),
    );
  }
}
