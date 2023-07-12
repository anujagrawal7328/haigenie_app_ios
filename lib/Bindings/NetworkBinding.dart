import 'package:get/get.dart';

import 'NetworkManager.dart';


class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    ///  implement dependencies
    ///
    NetworkManager networkManager= Get.put(NetworkManager());
    //Get.lazyPut<NetworkManager>(() => NetworkManager());
  }
}
