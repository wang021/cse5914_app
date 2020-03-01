import 'dart:io' as io;
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cse5914_app/HttpHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import 'CameraWidget.dart';
Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final  cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar:AppBar(
          title:Text('Aoligei')
        ),
        body: GestureDetector(
          onVerticalDragStart:(details) async => await sendVQARequest(),
          child:Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                flex:1,
                child: 
                  Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Expanded(
                      flex: 1,
                      child: Container(
                        child: CameraWidget(camera: firstCamera),
                        decoration: BoxDecoration(
                          border:Border(
                            right:BorderSide(
                              color:Colors.lightBlue,
                              width:3.0
                            ),
                            bottom: BorderSide(
                              color:Colors.lightBlue,
                              width:3.0
                            )
                          )
                        ),
                      )
                      ,
                      
                    ),
                      Expanded(
                      flex:1,
                      child: 
                      Container(
                        child:QASectionWidget(),
                        decoration:BoxDecoration(
                            border: Border(
                              left:BorderSide(
                              color:Colors.lightBlue,
                              width:3.0
                            ),
                            bottom: BorderSide(
                              color:Colors.lightBlue,
                              width:3.0
                            )
                            )
                         )
                      )
                      
                    )
                    ],
                  )
              ),
              Expanded(flex:3,
              child:ButtonSectionWidget())
            ],
          )
        )
      ),
    ),
  );
}
Future<void> sendVQARequest() async{
  print("drag!!");
  if(Data.audioPath!=null&&Data.imagePath!=null){
    print("Sending http request...");
    await Data.handler.get_answer(Data.audioPath, Data.imagePath);
  }
}

class Data{
  static String imagePath;
  static String audioPath;
  static HttpHandler handler = HttpHandler();
}

class QASectionWidget extends StatefulWidget{
  @override
  QASectionState createState() => QASectionState();
}
class QASectionState extends State<QASectionWidget>{
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      child:Center(
        child:Text('Your Questions:')
      )
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
  Widget build(BuildContext context){
    
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
          Icon(Icons.trip_origin
          ,color:Theme.of(context).primaryColor,
          size:80),
          Text(text)
        ],
      )
      )
      )
        
    );
  }
  @override
  Future<void> initState() async{
    super.initState();
    Future.microtask(() {
      _prepare();
    });
    
    FlutterTts tts = FlutterTts();
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    tts.speak("Welcome to the application! tap the bottom section to start. ");
    
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
      Data.audioPath = _recording.path;
    }
    

    
}