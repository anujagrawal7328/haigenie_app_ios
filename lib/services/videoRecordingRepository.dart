import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../model/score.dart';

class RecordingsRepository {
  static const String baseUrl = 'https://haigeniemwprod.eastus.cloudapp.azure.com:4443'; // Replace with your API URL
  static const String baseUrl2 = 'https://haigeniemwprod.eastus.cloudapp.azure.com:443';

  Future<List<Score>?> lastScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final decode = JWT.decode(token!);
    print("decoded:${decode.payload['secret']}");
    final url = Uri.parse('$baseUrl/getFeedbackRecordsUser');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({'secret_id': decode.payload['secret']});

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<Score> scoreList = [];

      for (int i = 0; i < responseData.length; i++) {
        int score=0;
        final result = responseData[i]['results'];
        if (result['step_2']['feedback'] == 1) score++;
        if (result['step_3']['feedback'] == 1) score++;
        if (result['step_4']['feedback'] == 1) score++;
        if (result['step_5']['feedback'] == 1) score++;
        if (result['step_6']['feedback'] == 1) score++;
        if (result['step_7']['feedback'] == 1) score++;
        final updatedAt = DateTime.parse(responseData[i]['updatedAt']);
        final formattedDateTime =
        DateFormat('EEE, MMM d, yyyy, hh:mm a').format(updatedAt);
        final data = Score(score1:double.parse(result['step_2']['feedback'].toString()),
            score2:double.parse(result['step_3']['feedback'].toString()),
            score3:double.parse(result['step_4']['feedback'].toString()),
            score4:double.parse(result['step_5']['feedback'].toString()),
            score5:double.parse( result['step_6']['feedback'].toString()),
            score6:double.parse( result['step_7']['feedback'].toString()),
            totalScore: double.parse(score.toString()), date: formattedDateTime);
        scoreList.add(data);
      }
      return scoreList;
    } else {
      print(response.body);
      return [];
    }
  }

  Future<List<Score>?> uploadVideo(user,videoPath,videoWidth,videoHeight) async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final decode = JWT.decode(token!);
    print("decoded:${decode.payload['secret']}");
    final url = Uri.parse('$baseUrl2/upload_video');

    late String deviceName,deviceModel,browserName,deviceWidth,deviceHeight;
    if(kIsWeb){
      final build= await deviceInfoPlugin.webBrowserInfo;
    }else{
     if(defaultTargetPlatform==TargetPlatform.android){
      final build= await deviceInfoPlugin.androidInfo;
      deviceModel=build.model;
      deviceName=build.device;
      deviceWidth=build.displayMetrics.widthPx.toString();
      deviceHeight=build.displayMetrics.heightPx.toString();
      browserName=build.product;
     }
     if(defaultTargetPlatform==TargetPlatform.iOS){
       final build= await deviceInfoPlugin.iosInfo;
       deviceModel=build.model;
       deviceName=build.name;
       deviceWidth=WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width.toString();
       deviceHeight=WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height.toString();
       browserName=build.utsname.machine;
     }
    }
    final current =DateTime.now();
    int hour = current.hour;
    int minute = current.minute;
    int second = current.second;
    final time=hour.toString()+minute.toString()+second.toString();
    var videoName = '${user.email! + '_' + deviceModel}_appv0.1_${DateTime(current.year, current.month, current.day)}_${time}_video$current.mp4';
    String videoNameWithoutSpaces = videoName.replaceAll(RegExp(r'\s+'), '');
    final gifTime ={"step_2": {"gif_start_time": 5, "gif_end_time": 9, "visited": true},
    "step_3": {"gif_start_time": 9, "gif_end_time": 16, "visited": true},
    "step_4": {"gif_start_time": 16, "gif_end_time": 20, "visited": true},
    "step_5": {"gif_start_time": 20, "gif_end_time":27, "visited": true},
    "step_6": {"gif_start_time": 27, "gif_end_time": 34, "visited": true},
    "step_7": {"gif_start_time": 34, "gif_end_time": 41, "visited": true}
     };
    final request = http.MultipartRequest('POST',url);
    request.files.add(await http.MultipartFile.fromPath('file',videoPath ));
    request.fields['fileName'] = videoNameWithoutSpaces;
    request.fields['user_id'] = user.email;
    request.fields['device_name'] = deviceName;
    request.fields['device_model'] = deviceModel;
    request.fields['device_resolution'] = "${deviceWidth}X$deviceHeight";
    request.fields['browser_name'] = browserName;
    request.fields['timestamp'] = DateTime.now().toString();
    request.fields['app_version'] = '_appv0.1_';
    request.fields['secret_id'] = decode.payload['secret'];
    request.fields['videoid'] = videoNameWithoutSpaces;
    request.fields['protocol_name'] = 'WHO 6 step';
    request.fields['box_coordinates'] = json.encode([videoWidth,videoHeight]);
    request.fields['gif_time'] = json.encode(gifTime);
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final responseData = jsonDecode(responseBody);
      final List<Score> scoreList = [];
      final result = responseData['results']['results'];
      int score=0;
      if (result['step_2']['feedback'] == 1) score++;
      if (result['step_3']['feedback'] == 1) score++;
      if (result['step_4']['feedback'] == 1) score++;
      if (result['step_5']['feedback'] == 1) score++;
      if (result['step_6']['feedback'] == 1) score++;
      if (result['step_7']['feedback'] == 1) score++;
      final updatedAt = DateTime.now();
      final formattedDateTime =
      DateFormat('EEE, MMM d, yyyy, hh:mm a').format(updatedAt);
      final data = Score(score1:double.parse(result['step_2']['feedback'].toString()),
          score2:double.parse(result['step_3']['feedback'].toString()),
          score3:double.parse(result['step_4']['feedback'].toString()),
          score4:double.parse(result['step_5']['feedback'].toString()),
          score5:double.parse( result['step_6']['feedback'].toString()),
          score6:double.parse( result['step_7']['feedback'].toString()),
          totalScore: double.parse(score.toString()), date: formattedDateTime);
      scoreList.add(data);
      return scoreList;
    } else {
      print(responseBody);
      return [];
    }
  }
}
