import 'dart:io' as io;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar:AppBar(
          title:Text('Aoligei')
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: CameraWidget(camera: firstCamera),
            ),
            Expanded(flex:1,
            child: QASectionWidget()
            ),
            Expanded(flex:1,
            child:ButtonSectionWidget())
          ],
        )
      ),
    ),
  );
}

class CameraWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => CameraState();

  final CameraDescription camera;

  const CameraWidget({
    Key key,
    @required this.camera,
  }) : super(key: key);
  
}
class CameraState extends State<CameraWidget>{
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String image_path;
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
      image_path==null?
          Center(
            child:Icon(Icons.camera_alt,color:Theme.of(context).primaryColor,
            size:30))
            :Image.file(io.File(image_path))
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
            await _controller.takePicture(path).then((_)=> image_path = path).then((_)=> switchToImageDisplay());
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
        image_path==null?
            Center(
              child:Icon(Icons.camera_alt,color:Theme.of(context).primaryColor,
              size:30))
              :Image.file(io.File(image_path))
              );
          });
    }
}
class QASectionWidget extends StatefulWidget{
  @override
  QASectionState createState() => QASectionState();
}
class QASectionState extends State<QASectionWidget>{
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Text('Ask any Question about the picture :)')
    );
  }
}
class ButtonSectionWidget extends StatefulWidget{
  @override
  ButtionSectionState createState() => ButtionSectionState();
}
class ButtionSectionState extends State<ButtonSectionWidget> {
  bool _isRecored = false;
  String text = 'not recording';
  FlutterAudioRecorder _recorder;
  Recording _recording;
  String _alert;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:_opt,
      child:
      ConstrainedBox(constraints: BoxConstraints(minWidth: double.infinity),child: 
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent)
        ),
        child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Icon(Icons.keyboard_voice
          ,color:Theme.of(context).primaryColor,
          size:60),
          Text('$text')
        ],
      )
      )
      )
        
    );
  }
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _prepare();
    });
  }
    Future _init() async {
    String customPath = '/flutter_audio_recorder_';
    io.Directory appDocDirectory;
    if (io.Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }

    // can add extension like ".mp4" ".wav" ".m4a" ".aac"
    customPath = appDocDirectory.path +
        customPath +
        DateTime.now().millisecondsSinceEpoch.toString();

    // .wav <---> AudioFormat.WAV
    // .mp4 .m4a .aac <---> AudioFormat.AAC
    // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.

    _recorder = FlutterAudioRecorder(customPath,
        audioFormat: AudioFormat.WAV, sampleRate: 22050);
    await _recorder.initialized;
  }
  Future _prepare() async{
  var hasPermission = await FlutterAudioRecorder.hasPermissions;
      if (hasPermission) {
        await _init();
        var result = await _recorder.current();
        setState(() {
          _recording = result;
          _alert = "";
        });
      } else {
        setState(() {
          _alert = "Permission Required.";
        });
      }
  }
    void _opt() async {
    switch (_recording.status) {
      case RecordingStatus.Initialized:
        {
          text = 'recording';
          await _startRecording();
          break;
        }
      case RecordingStatus.Recording:
        {
          text = 'not recording';
          await _stopRecording();
          await _prepare();
          break;
        }
      default:
        break;
    }
    }
   Future _startRecording() async {
    await _recorder.start();
    var current = await _recorder.current();
    setState(() {
      _recording = current;
    });
   }
    Future _stopRecording() async {
      var result = await _recorder.stop();
      _play();
      setState(() {
        _recording = result;
      });
    }
    void _play() {
      AudioPlayer player = AudioPlayer();
      player.play(_recording.path, isLocal: true);
    }
    

    
}