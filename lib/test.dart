import 'dart:io';
import 'package:cameraapp/components/ReusableCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'components/bottom_button.dart';
import 'components/ButtonGroup.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String firstButtonText = 'Take photo';
  String secondButtonText = 'Record video';
  double textSize = 20;
  String albumName = 'Media';
  int index = 0;

  File _image = null;
  File _video = null;

  //VideoPlayerController _videoPlayerController;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF0A0E21),
          scaffoldBackgroundColor: Color(0xFF0A0E21),
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Camera+GPS "),
          ),
          body: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                ReusableCard(text: firstButtonText + " " + secondButtonText),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ButtonGroup(
                      titles: ["Photo", "Video"],
                      current: index,
                      color: Colors.blue,
                      secondaryColor: Colors.white,
                      onTab: (selected) {
                        setState(() {
                          index = selected;
                        });
                        print("$index");
                      },
                    ),
                    RaisedButton(
                        child: Text("Capture"),
                        onPressed: () {
                          print("Button Pressed");
                          _capture();
                        }),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        if (_image != null && index == 0)
                          Image.file(
                            _image,
                            fit: BoxFit.contain,
                          )
//                        else if (_video != null && index == 1)
//                          _videoPlayerController.value.initialized
//                              ? AspectRatio(
//                                  aspectRatio:
//                                      _videoPlayerController.value.aspectRatio,
//                                  child: VideoPlayer(_videoPlayerController),
//                                )
//                              : Container()
                        else
                          Text(
                            "Click on capture to get started.",
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.blueGrey),
                          ),
                      ],
                    ),
                  ),
                ),
                BottomButton(onTap: null, buttonTitle: "Upload"),
              ],
            ),
          ),
        ));
  }

  void _capture() {
    if (index == 0) {
      _takePhoto();
    }
    if (index == 1) {
      _recordVideo();
    }
  }

  void _takePhoto() async {
    await _picker
        .getImage(source: ImageSource.camera)
        .then((PickedFile pickedFile) async {
      if (pickedFile != null && pickedFile.path != null) {
        setState(() {
          firstButtonText = 'saving in progress...';
        });
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//        List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
//        Placemark place = placemark[0];
        print(pickedFile.path);
        String dir = (await getApplicationDocumentsDirectory()).path;
        String newPath = path.join(
            dir,
            position.toString() +
                ',' +
                DateTime.now().toString() +
                path.extension(pickedFile.path));
        File f = await File(pickedFile.path).copy(newPath);
        setState(() {
          _image = f;
        });
        print(f.path);

        GallerySaver.saveImage(
          f.path,
          albumName: albumName,
        ).then((bool success) {
          print("${f.path}");
          setState(() {
            firstButtonText = 'image saved!';
          });
        });
      }
    });
  }

  void _recordVideo() async {
    await _picker
        .getVideo(source: ImageSource.camera)
        .then((PickedFile pickedFile) async {
      if (pickedFile != null && pickedFile.path != null) {
        setState(() {
          secondButtonText = 'saving in progress...';
        });
        Position position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        //        List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
        //        Placemark place = placemark[0];
        print(pickedFile.path);
        String dir = (await getApplicationDocumentsDirectory()).path;
        String newPath = path.join(
            dir,
            position.toString() +
                ',' +
                DateTime.now().toString() +
                path.extension(pickedFile.path));
        File f = await File(pickedFile.path).copy(newPath);
        setState(() {
          _video = f;
        });

//        _videoPlayerController = VideoPlayerController.file(_video)
//          ..initialize().then((_) {
//            setState(() {});
//            _videoPlayerController.play();
//          });

        print(f.path);

        GallerySaver.saveVideo(
          f.path,
          albumName: albumName,
        ).then((bool success) {
          print("${f.path}");
          setState(() {
            secondButtonText = 'Video saved!';
          });
        });
      }
    });
  }
}
