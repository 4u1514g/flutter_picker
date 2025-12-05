import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MediaModel> list = [];

  void _incrementCounter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PickerWidget(
          onPicked: (value) async {
            setState(() {
              list = value;
            });

            final length = await value.first.file!.length(); // tính theo byte
            print('Kích thước file: $length bytes');

            // Nếu muốn đổi sang KB hoặc MB
            final kb = length / 1024;
            final mb = kb / 1024;
            print('≈ ${kb.toStringAsFixed(2)} KB');
            print('≈ ${mb.toStringAsFixed(2)} MB');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          children: List.generate(
            list.length,
            (index) => Row(
              children: [
                Image.memory(list[index].thumbnail!, width: 150, height: 150),
                Image.file(list[index].file!, width: 150, height: 150),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
