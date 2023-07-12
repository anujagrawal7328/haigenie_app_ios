import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class NetworkManager extends GetxController {
  //this variable 0 = No Internet, 1 = connected to WIFI ,2 = connected to Mobile Data.
  var connectionType = 1;

  //Instance of Flutter Connectivity
  final Connectivity _connectivity = Connectivity();
 int count=0;
  //Stream to keep listening to network change state
  StreamSubscription? _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    GetConnectionType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
  }

  // a method to get which connection result, if you we connected to internet or no if yes then which network
  Future<void> GetConnectionType() async {
    var connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      print(e);
    }
    return _updateState(connectivityResult);
  }

  // state update, of network, if you are connected to WIFI connectionType will get set to 1,
  // and update the state to the consumer of that variable.
  _updateState(ConnectivityResult result) {
    if (kDebugMode) {
      print('text$result');
    }
    switch (result) {
      case ConnectivityResult.wifi:
        connectionType = 1;
        refresh();
        showNetworkSnackbar();
        break;
      case ConnectivityResult.mobile:
        connectionType = 2;
        refresh();
        showNetworkSnackbar();
        if (kDebugMode) {
          print('connectionType $connectionType');
        }
        break;
      case ConnectivityResult.none:
        connectionType = 0;
        refresh();
        showNetworkSnackbar();
        if (kDebugMode) {
          print('connectionType $connectionType');
        }
        break;
      default:
        Get.snackbar('Network Error', 'Failed to get Network Status');
        break;
    }
  }
  void showNetworkSnackbar() {
    if (connectionType == 0) {
      Get.snackbar(
        'Network Status',
        'You are not connected to the internet!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
    if(connectionType!=0 && count>0){
      Get.snackbar(
          'Network Status',
          'Connected to the ${connectionType!=1?"wifi":"metered connection"}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

    }

  }
  @override
  void onClose() {
    //stop listening to network state when app is closed
    _streamSubscription!.cancel();
  }
}
