import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

//@app.route("/speech2text"):
//@app.route("/getanswer"):
class HttpHandler{
  AudioPlayer player = AudioPlayer();

  String basicAuthorizationHeader(String apikey) {
    return 'Basic ' + base64Encode(utf8.encode('apikey:$apikey'));
  }

  String T2S_url = "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/1a9e6446-ef2f-492b-b8ac-1867bd1739c4/v1/synthesize";
  String T2S_key = "u9WLXjNk3bcPkXWtVPTiIokDCdVkVrY-R1SB_fPBtGdE";

 Future<void> text2audio(String text) async { 

    Response response = await Dio().request(
      T2S_url,
      data: {'text': text, 'accept': 'audio/flac'},
      options: Options(method: "POST", responseType: ResponseType.bytes, headers: {'Authorization': basicAuthorizationHeader(T2S_key)})
    );

    Directory tmpDir = await getTemporaryDirectory();
    File tmpFile = File('${tmpDir.path}/T2S.flac');

    await tmpFile.writeAsBytes(response.data, flush: true);
    player.play('${tmpDir.path}/T2S.flac', isLocal: true);
    
    String url_placeholder = "http://9e7e4777.ngrok.io/speech2text";
    var upload_file = MultipartFile.fromBytes(response.data);
    FormData formData = FormData.fromMap({
      "audio_file" : upload_file
    });
    Response re = await Dio().post(
      url_placeholder,
      data:formData
    );
    print(re);
  }
}