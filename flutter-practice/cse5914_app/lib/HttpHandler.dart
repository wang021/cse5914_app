import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';


class HttpHandler{
  AudioPlayer player = AudioPlayer();
  String basicAuthorizationHeader(String apikey) {
    return 'Basic ' + base64Encode(utf8.encode('apikey:$apikey'));
  }
  
  String txt2audio_url = "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/1a9e6446-ef2f-492b-b8ac-1867bd1739c4/v1/synthesize";
  String txt2audio_key = "u9WLXjNk3bcPkXWtVPTiIokDCdVkVrY-R1SB_fPBtGdE";
  
  String backend_url = "http://df1d2df3.ngrok.io";

  Future<void> text2audio(String text) async {
    Response response = await Dio().request(
      txt2audio_url,
      data: {'text': text, 'accept': 'audio/flac'},
      options: Options(method: "POST", responseType: ResponseType.bytes, headers: {'Authorization': basicAuthorizationHeader(txt2audio_key)})
    );
    
    Directory tmpDir = await getTemporaryDirectory();
    File tmpFile = File('${tmpDir.path}/T2S.flac');
    await tmpFile.writeAsBytes(response.data, flush: true);
    player.play('${tmpDir.path}/T2S.flac', isLocal: true);
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
    
    text2audio(answer_text);
  
  }
}