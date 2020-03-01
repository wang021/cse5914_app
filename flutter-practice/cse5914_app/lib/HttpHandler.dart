import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'package:flutter_tts/flutter_tts.dart';
class HttpHandler{
  AudioPlayer player = AudioPlayer();
  String basicAuthorizationHeader(String apikey) {
    return 'Basic ' + base64Encode(utf8.encode('apikey:$apikey'));
  }
  
  String txt2audio_url = "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/1a9e6446-ef2f-492b-b8ac-1867bd1739c4/v1/synthesize";
  String txt2audio_key = "u9WLXjNk3bcPkXWtVPTiIokDCdVkVrY-R1SB_fPBtGdE";
  
  String backend_url = "http://45cf59a3.ngrok.io";

  Future<void> text2audio(String text) async {
    print(text);
    String api_key = basicAuthorizationHeader(txt2audio_key);
    Response response;
    try{
     response = await Dio().post(
      txt2audio_url,
      data: {'text': "hello world hello world hello world hello world", 'accept': 'audio/flac'},
      options: Options( responseType: ResponseType.bytes, headers: {'authorization': "Basic YXBpa2V5OnU5V0xYak5rM2JjUGtYV3RWUFRpSW9rRENkVmtWclktUjFTQl9mUEJ0R2RF",'content-type':'application/json'})
    );
    }catch(err){
      print(err);
    }
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    Directory tmpDir = await getTemporaryDirectory();
    File tmpFile = File("${appDocDirectory.path}/T2S.flac");
    print(tmpFile.path);
    try{
      tmpFile.writeAsBytesSync(response.data, flush: true);
      print(tmpFile.lengthSync());
      await player.play("https://www.kozco.com/tech/LRMonoPhase4.wav", isLocal: false);
    }catch(err){
      print(err);
    }
   
  }

  Future<String> audio2text(audio_path) async {
  
    var audio_file = MultipartFile.fromFileSync(audio_path);
    FormData formData = FormData.fromMap({
      "audio_file" : audio_file
    });

    Response re = await Dio().post(
      backend_url+"/speech2text",
      data:formData,
      options: Options(responseType: ResponseType.plain)
    );
    
    String audio_text = re.data;
    
    return audio_text;
  }

  Future<void> get_answer(audio_path, image_path) async{
    
    var audio_file = MultipartFile.fromFileSync(audio_path);
    var image_file = MultipartFile.fromFileSync(image_path);

    FormData formData = FormData.fromMap({
      "audio_file" : audio_file,
      "image_file" : image_file
    });

    Response re = await Dio().post(
      backend_url+"/getanswer",
      data:formData,
      options: Options(responseType: ResponseType.plain)
    );
    
    String answer_text = re.data;
    print(answer_text);
    FlutterTts tts = FlutterTts();
    await tts.speak(answer_text);
  
  }
}