import 'package:get_it/get_it.dart';
import 'hands/hands_service.dart';
import 'model_inference_service.dart';


final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<Hands>(Hands());
  locator.registerLazySingleton<ModelInferenceService>(
      () => ModelInferenceService());
}
