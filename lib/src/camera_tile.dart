import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:image_picker/image_picker.dart';

class CameraTile extends StatefulWidget {
  const CameraTile({
    super.key,
    required this.mediaType,
    required this.onDone,
  });

  final MediaType mediaType;
  final ValueChanged<List<MediaModel>> onDone;

  @override
  State<CameraTile> createState() => _CameraTileState();
}

class _CameraTileState extends State<CameraTile> {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openCamera,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child:
            const Image(image: AssetImage('packages/flutter_picker/assets/camera.png'), height: 34),
      ),
    );
  }

  void openCamera() {
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
