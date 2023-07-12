import 'dart:isolate';
import 'package:camera/camera.dart';
import '../../utils/isolate_utils.dart';
import 'ai_model.dart';


import 'hands/hands_service.dart';
import 'service_locator.dart';

enum Models {
  Hands
}

class ModelInferenceService {
  late AiModel model;
  late Function handler;
  Map<String, dynamic>? inferenceResults;

  Future<Map<String, dynamic>?> inference({
    required IsolateUtils isolateUtils,
    required CameraImage cameraImage,
  }) async {
    final responsePort = ReceivePort();

    isolateUtils.sendMessage(
      handler: handler,
      params: {
        'cameraImage': cameraImage,
        'detectorAddress': model.getAddress,
      },
      sendPort: isolateUtils.sendPort,
      responsePort: responsePort,
    );

    inferenceResults = await responsePort.first;
    responsePort.close();
  }

  void setModelConfig() {
    switch (Models.values[0]) {
      case Models.Hands:
        model = locator<Hands>();
        handler = runHandDetector;
        break;
    }
  }
}
