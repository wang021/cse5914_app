import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'main.dart';
class CameraWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => CameraState();

  final CameraDescription camera;
  
   CameraWidget({
    Key key,
    @required this.camera,
  }) : super(key: key);
}
class CameraState extends State<CameraWidget>{
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String imagePath;
  Widget toBeDisplayed;
  @override
  void initState()  {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    _initializeControllerFuture =  _controller.initialize();
    // Next, initialize the controller. This returns a Future.
    
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(toBeDisplayed == null){
       toBeDisplayed = GestureDetector(
            onTap: createPreview,
            child:
            ConstrainedBox(constraints: BoxConstraints(minWidth: double.infinity),
              child: Container(
                decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent)
              ),
                child: 
                imagePath==null?
                    Center(
                      child:Icon(Icons.camera_alt,color:Theme.of(context).primaryColor,
                      size:30))
                      :Image.file(io.File(imagePath))
                      ),
            )
        );
    }
    return toBeDisplayed;
  }
  createPreview() {
    setState(() {
      toBeDisplayed = GestureDetector(
        onTap: takePicture,
        child: CameraPreview(_controller),
      );
    });
  }
  takePicture() async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path).then((_)=> Data.imagePath = imagePath = path).then((_)=> switchToImageDisplay());
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        }
    switchToImageDisplay() async{
      setState(() {
          toBeDisplayed = GestureDetector(
          onTap: createPreview,
          child: 
        imagePath==null?
            Center(
              child:Icon(Icons.camera_alt,color:Theme.of(context).primaryColor,
              size:30))
              :Image.file(io.File(imagePath))
              );
          });
    }
}