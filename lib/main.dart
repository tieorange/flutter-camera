import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/display.dart';
import 'package:camera_app/utils/PhotosManager.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audio_cache.dart';

import 'utils/Constants.dart';

// TODO add sounds: http://soundbible.com/tags-cat-meow.html

Future<void> main() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first; // TODO handle both cams

  runApp(
    MaterialApp(
      theme: ThemeData(primarySwatch: Colors.pink),
      home: Camera(
        camera: firstCamera,
      ),
    ),
  );
}

class Camera extends StatefulWidget {
  final CameraDescription camera;

  const Camera({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  AudioCache player = new AudioCache(prefix: "audio/");

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
    );

    onCameraSelected(widget.camera);
  }

  Future playSound() async {
    await player.play(Constants.sounds.first); // todo mock
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a Picture2')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Row(
              children: <Widget>[
                AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller))
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          await onFabClick(context);
        },
      ),
    );
  }

  Future onFabClick(BuildContext context) async {
    await playSound();

    try {
      await _initializeControllerFuture;

      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      await _controller.takePicture(path);

      PhotosManager.savePictureToGallery(path);
//      goToNextScreen(context, path);
    } catch (e) {
      print(e);
    }
  }

  void goToNextScreen(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPicture(imagePath: path),
      ),
    );
  }

  void onCameraSelected(CameraDescription camera) {
    _initializeControllerFuture = _controller.initialize().then((value) {
      print("INIT Initialized camera");
      setState(() {});
    });
  }

  MaterialButton buildMaterialButton() {
    return MaterialButton(
      child: Text("take pic"),
      onPressed: () => print("clicked"),
    );
  }
}
