import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/display.dart';
import 'package:camera_app/utils/PhotosManager.dart';
import 'package:camera_app/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lamp/lamp.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'utils/Constants.dart';

// TODO add sounds: http://soundbible.com/tags-cat-meow.html

Future<void> main() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first; // TODO handle both cams

  await Utils.initAppCenter();

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

  bool loading = false;
  String lastPicturePath = "";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    initCamera(widget.camera);
  }

  Future playSound() async {
    await player.play(Constants.sounds.elementAt(1)); // todo mock
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initCamera(CameraDescription camera) {
    _initializeControllerFuture = _controller.initialize().then((value) {
      print("INIT Initialized camera");
      setState(() {});
    });
  }

  Future onFabClick(BuildContext context) async {
    setState(() {
      loading = true;
    });

//    await _initializeControllerFuture;

    final path = join(
      (await getTemporaryDirectory()).path,
      '${DateTime.now()}.png',
    );

    await _controller.takePicture(path);

    PhotosManager.savePictureToGallery(path);
//      goToNextScreen(context, path);
    setState(() {
      loading = false;
      lastPicturePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Expanded(
                  child: Transform.scale(
                    scale: _controller.value.aspectRatio / deviceRatio,
                    child: Center(
                        child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: CameraPreview(_controller))),
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Opacity(
        opacity: 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.camera_alt),
              onPressed: () => onFabClick(context),
            ),
            FloatingActionButton(
              child: Icon(Icons.volume_up),
              onPressed: playSound,
            ),
            FloatingActionButton(
              child: Icon(Icons.flash_on),
              onPressed: blinkFlashlight,
            ),
            takenPhotoPreview()
          ],
        ),
      ),
    );
  }

  Widget takenPhotoPreview() {
    Widget image =
        FadeInImage.memoryNetwork(placeholder: null, image: lastPicturePath);

    if (loading) {
      image = RefreshProgressIndicator();
    }
    return FloatingActionButton(
      child: ClipRRect(borderRadius: BorderRadius.circular(40.0), child: image),
      onPressed: playSound,
    );
  }

  MaterialButton buildMaterialButton() {
    return MaterialButton(
      child: Text("take pic"),
      onPressed: () => print("clicked"),
    );
  }

  void goToNextScreen(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPicture(imagePath: path),
      ),
    );
  }

  Future blinkFlashlight() async {
    await Lamp.hasLamp;
    Lamp.turnOn(intensity: 0.1);
  }
}
