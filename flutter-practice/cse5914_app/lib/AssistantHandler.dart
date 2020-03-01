import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'package:flutter_tts/flutter_tts.dart';
class AssistantHandler{
  String assistant_url = "";
  String assistant_api = "";

  Future<bool> needToRetake(String text) async{
    Response response;
      try{
        response = await Dio().post(
        assistant_url,
        data: {'input': "{text:$text}"},
        options: Options( responseType: ResponseType.bytes, headers: {'authorization': "Basic YXBpa2V5OnU5V0xYak5rM2JjUGtYV3RWUFRpSW9rRENkVmtWclktUjFTQl9mUEJ0R2RF",'content-type':'application/json',
        'Content-Type':"application/json"})
    );
    }catch(err){
      print(err);
    }
    return response.data;
  }
  Future<bool> needToContinue(String text) async{
      Response response;
      try{
        response = await Dio().post(
        assistant_url,
        data: {'input': "{text:$text}"},
        options: Options( responseType: ResponseType.bytes, headers: {'authorization': "Basic YXBpa2V5OnU5V0xYak5rM2JjUGtYV3RWUFRpSW9rRENkVmtWclktUjFTQl9mUEJ0R2RF",'content-type':'application/json',
        'Content-Type':"application/json"})
    );
    }catch(err){
      print(err);
    }
    return response.data;
  }
  Future<void> playPhotoConfirmationAudio() async{
    AudioPlayer player = AudioPlayer();
    await player.play("audio/photo_confirmation.wav", isLocal: true);
  }
  Future<void> playAudioConfirmationAudio() async{
    AudioPlayer player = AudioPlayer();
    await player.play("audio/audio_confirmation.wav", isLocal: true);
  }
  Future<void> playAudioPrompt() async{
    AudioPlayer player = AudioPlayer();
    await player.play("audio/audio_begin.wav", isLocal: true);
  }
  Future<void> playPhotoPrompt() async{
    AudioPlayer player = AudioPlayer();
    await player.play("audio/photo_begin.wav", isLocal: true);
  }

}