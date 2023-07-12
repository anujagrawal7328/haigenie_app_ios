import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:haigenie/l10n/l10n.dart';
import 'package:haigenie/screens/widgets/hands_painter.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:scidart/numdart.dart';
import 'package:video_player/video_player.dart';
import '../model/score.dart';
import '../model/user.dart';
import '../services/VideoRecordingRepository.dart';
import '../services/model_inference_service.dart';
import '../services/service_locator.dart';
import '../utils/isolate_utils.dart';

class VideoRecordingScreen extends StatefulWidget {
  final User user;
  final List<Score>? score;
  final bool guide;
  const VideoRecordingScreen(
      {Key? key, required this.user, required this.score, required this.guide})
      : super(key: key);

  @override
  State createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with WidgetsBindingObserver {
  final RecordingsRepository recordingsRepository = RecordingsRepository();
  late VideoPlayerController _controller;
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isLoading = true;
  late PausableTimer _timer;
  late Timer timer2;
  final int _durationInSeconds = 10;
  bool palmFound = false;
  int palmFoundCount = 0;
  bool _canProcess = false;
  String? _text;
  bool _isRecording = false;
  CustomPaint? _customPaint;
  late XFile videoFile = XFile('');
  bool _isComputing = false;
  bool _predicting = false;
  bool _draw = false;
  late CameraDescription _cameraDescription;
  late IsolateUtils _isolateUtils;
  late ModelInferenceService _modelInferenceService;
  late Locale _selectedLocale = const Locale('en');
  bool volumeUp = true;
  int _currentIndex = 0;
  bool pause = false;
  late Duration _duration;
  late String _remainingTime;
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<String> _imageUrlsEN = [
    'assets/Images/Screensaver/Screensaver_English/screensaver_6.png',
    'assets/Images/Screensaver/Screensaver_English/screensaver_7.png',
    'assets/Images/Screensaver/Screensaver_English/screensaver_8.png',
    'assets/Images/Screensaver/Screensaver_English/screensaver_9.png',
  ];
  final List<String> _imageUrlsHI = [
    'assets/Images/Screensaver/Screensaver_Hindi/screensaver_2.png',
    'assets/Images/Screensaver/Screensaver_Hindi/screensaver_6.png',
    'assets/Images/Screensaver/Screensaver_Hindi/screensaver_7.png',
    'assets/Images/Screensaver/Screensaver_Hindi/screensaver_8.png',
    'assets/Images/Screensaver/Screensaver_Hindi/screensaver_9.png',
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentLocale = Localizations.localeOf(context);
      setState(() {
        _selectedLocale = currentLocale;
      });
      _controller = _selectedLocale == const Locale('en')
          ? VideoPlayerController.asset('assets/videos/guide.mp4')
          : VideoPlayerController.asset('assets/videos/newGuideHindi.mp4');
      _controller.initialize().then((_) {
        setState(() {});
      });
      print('Current Locale: $currentLocale');
    });
    _modelInferenceService = locator<ModelInferenceService>();
    _initStateAsync();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex = _selectedLocale == const Locale('en')
            ? (_currentIndex + 1) % _imageUrlsEN.length
            : (_currentIndex + 1) % _imageUrlsHI.length;
      });
    });
    _timer = PausableTimer(const Duration(seconds: 0), () {
      // Timer callback
      print('Timer complete!');
    });
    _duration = const Duration(seconds: 41);
    _remainingTime = formatDuration(_duration);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigitSeconds;
  }

  void _initStateAsync() async {
    _isolateUtils = IsolateUtils();
    await _isolateUtils.initIsolate();
    await _initializeCamera();
    _predicting = false;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _cameraController?.dispose();
    _cameraController = null;
    _isolateUtils.dispose();
    _modelInferenceService.inferenceResults = null;
    _controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void startTimer() {
    timer2 = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration = _duration - const Duration(seconds: 1);
          _remainingTime = formatDuration(_duration);
        } else {
          timer2.cancel();
        }
      });
    });
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    /* final externalCamera = await getExternalCamera(); */
    final cameraDescription = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
          );

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _cameraController!.addListener(() {
      if (mounted) setState(() {});
      if (_cameraController!.value.hasError) {
        _showInSnackBar(
            'Camera error ${_cameraController!.value.errorDescription}');
      }
    });

    try {
      await _cameraController!.initialize().then((value) {
        if (!mounted) return;
      });
    } on CameraException catch (e) {
      _showInSnackBar('Error: ${e.code}\n${e.description}');
    }

    if (mounted) {
      setState(() {});
    }
    setState(() {
      _draw = !_draw;
    });
    _cameraController!.startImageStream((CameraImage cameraImage) async {
      // await _inference(cameraImage: cameraImage);
    });

    /*  try {
      await _cameraController.startImageStream((CameraImage image) {
      */ /*  final inputImage =
            _inputImageFromCameraImage(image, _cameraController.description);

        if (inputImage != null) {
          if (!palmFound) {
            processImage(inputImage).then((dynamic results) {
              for (var element in results) {
                //// you can use 'eyelash' for eye detection.
                if (element.label.toLowerCase() == 'hand' &&
                    element.confidence > 0.75) {
                  palmFoundCount = palmFoundCount + 1;
                  if (palmFoundCount == 50) {
                    palmFound = true;
                    if (palmFound) {
                      print("recording");
                      setState(() => _isLoading = false);*/ /*
                      _timer = Timer(
                        Duration(seconds: _durationInSeconds),
                        _recordVideo,
                      );
                  */ /*  }
                  }
                }
              }
            });
          }
        }*/ /*
      });
    } catch (e) {
      print("error:$e");
    }*/
  }

  Future<void> _inference({required CameraImage cameraImage}) async {
    if (!mounted) return;

    if (_modelInferenceService.model.interpreter != null) {
      if (_predicting || !_draw) {
        return;
      }

      setState(() {
        _predicting = true;
      });

      if (_draw) {
        await _modelInferenceService.inference(
          isolateUtils: _isolateUtils,
          cameraImage: cameraImage,
        );
      }

      setState(() {
        _predicting = false;
      });
    }
  }

  void _showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _submitRecordedVideo(String videoPath) async {
    final file = File(videoPath);
    if (file.existsSync()) {
      final result = await recordingsRepository.uploadVideo(
          widget.user,
          videoPath,
          _cameraController?.value.previewSize?.width,
          _cameraController?.value.previewSize?.height);
      if (result != []) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/score', (Route<dynamic> route) => false,
            arguments: [result, widget.user, videoPath]);
        _isComputing = false;
      } else {
        print('Video upload Failed');
      }
    } else {
      print('Video file not found');
    }
  }

  /* Future<UsbDevice?> getExternalCamera() async {
    final devices = await UsbSerial.listDevices();

    for (final device in devices) {
      if (device.productName?.contains('Camera') ?? false) {
        return device;
      }
    }

    return null;
  } */

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if(_isComputing)audioPlayer.play(AssetSource('audios/Music_3.mp3'));
    if(!_isComputing)audioPlayer.stop();
    return OrientationBuilder(builder: (context, orientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Image.asset("assets/Images/logo.png", width: 50, height: 50),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/dashboard',
                  arguments: [widget.user, widget.score]);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            if (_isRecording)
              IconButton(
                  onPressed: () {
                    if (volumeUp) {
                      volumeUp = false;
                      _controller.setVolume(0.0);
                      setState(() {});
                    } else {
                      volumeUp = true;
                      _controller.setVolume(50.0);
                      setState(() {});
                    }
                    print(volumeUp);
                  },
                  icon: volumeUp
                      ? const Icon(Icons.volume_up)
                      : const Icon(Icons.volume_off)),
            if (_isRecording)
              IconButton(
                  onPressed: () {
                    if (pause == true) {
                      pause = false;
                      _controller.play();
                      _cameraController!.resumeVideoRecording();
                      _timer.start();
                      startTimer();
                      setState(() {});
                    } else {
                      pause = true;
                      _controller.pause();
                      _cameraController!.pauseVideoRecording();
                      _timer.pause();
                      timer2.cancel();
                      setState(() {});
                    }
                    print(volumeUp);
                  },
                  icon: pause == true
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause)),
          ],
        ),
        body: !_isComputing
            ? Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(
                          1.0), // Adjust the margin as needed
                      child: _isLoading
                          ? _buildLoadingIndicator()
                          : _buildCameraPreview(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(
                          1.0), // Adjust the margin as needed
                      child: widget.guide == true
                          ? _buildVideoPlayer()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildGenieImage(),
                                const SizedBox(width: 20.0),
                                Column(children: [
                                  _buildTimer(),
                                  const SizedBox(height: 20.0),
                                  _buildStepsBox()
                                ]),
                              ],
                            ),
                    ),
                  ),
                ],
              )
            : Stack(children: [
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Lets find out your HAIgenie score!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: 60,
                    left: 10,
                    right: 10,
                    child: SizedBox(
                        width: 200,
                        height: 200,
                        child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: Image.asset(
                              _selectedLocale == const Locale('en')
                                  ? _imageUrlsEN[_currentIndex]
                                  : _imageUrlsHI[_currentIndex]),
                        ))),
                Positioned(
                    bottom: 0,
                    left: 10,
                    right: 10,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 25,
                      color: Colors.black,
                      child: const Center(
                          child: Text(
                        'Please Wait ... Good things take time',
                        style: TextStyle(color: Colors.white),
                      )),
                    )),
              ]),
        /* bottomNavigationBar: !_isComputing
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.user.userType != 'multiuser'
                  ? ElevatedButton(
                      onPressed: () {
                        if (widget.user.availableAttempts! > 0 ||
                            widget.user.paid == true) {
                          final file = File(videoFile.path);
                          if (_isRecording) {
                            _showInSnackBar("Still recording please wait.. ");
                          } else if (!file.existsSync()) {
                            _showInSnackBar("Please record a video first! ");
                          } else {
                            _isComputing = true;
                            _submitRecordedVideo(videoFile.path);
                          }
                        } else {
                          _showInSnackBar("You have 0 attempts left!");
                        }
                      },
                      child: const Text('Know Your HAIgenie Score'))
                  : null,
            )
          : null,*/
      );
    });
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _remainingTime != ""
          ? Text(
              '00:00:$_remainingTime',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : const Text(
              '00:00:00',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildStepsBox() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black),
      ),
      child: Column(children: [
        const Text(
          'Current Step Index',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        int.parse(_remainingTime) >= 37
            ? const Text(
                '',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            : int.parse(_remainingTime) > 32
                ? const Text(
                    'step1',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                : int.parse(_remainingTime) > 25
                    ? const Text(
                        'Step2',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    : int.parse(_remainingTime) > 21
                        ? const Text(
                            'Step3',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : int.parse(_remainingTime) > 14
                            ? const Text(
                                'Step4',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                            : int.parse(_remainingTime) > 6
                                ? const Text(
                                    'Step5',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                : int.parse(_remainingTime) > 0
                                    ? const Text(
                                        'Step6',
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        'Ended',
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
      ]),
    );
  }

  Widget _buildGenieImage() {
    // Replace this with your actual genie image widget
    return Image.asset("assets/Images/Genie.jpeg", width: 200, height: 200);
  }

  Widget _buildVideoPlayer() {
    // Replace this with your actual video player widget
    return Stack(children: [
      Positioned(
          top: 20,
          left: 40,
          right: 20,
          bottom: 20,
          child: AspectRatio(
            aspectRatio: 1.33,
            child: VideoPlayer(_controller),
          ))
    ]);
  }

  Widget _buildCameraPreview() {
    late final double ratio;
    final Map<String, dynamic>? inferenceResults =
        locator<ModelInferenceService>().inferenceResults;
    final screenSize = MediaQuery.of(context).size;
    ratio = (screenSize.width / _cameraController!.value.previewSize!.height);

    // Replace this with your actual camera preview widget
    return GestureDetector(
      onTapDown: (_) async {
        if (_isRecording) {
          return;
        } else {
          setState(() {
            _duration = const Duration(seconds: 41);
            _remainingTime = formatDuration(_duration);
            pause = false;
            _isRecording = true;
          });
          await _controller.seekTo(Duration.zero);
          await _controller.play();
          await _cameraController?.prepareForVideoRecording();
          await _cameraController?.startVideoRecording();
          _timer = PausableTimer(const Duration(seconds: 41), () async {
            setState(() {
              _isRecording = false;
              _timer.cancel();
            });
            videoFile = (await _cameraController?.stopVideoRecording())!;
            await _controller.pause();
            if (widget.user.availableAttempts! > 0 ||
                widget.user.paid == true) {
              _isComputing = true;
              setState(() {});
              _submitRecordedVideo(videoFile.path);
            } else {
              _showInSnackBar('you have 0 attempts left');
            }
          });
          _timer.start();
          startTimer();
        }
      },
      child: Stack(
        children: [
          _isRecording
              ? Positioned(
                  top: 20,
                  left: 40,
                  right: 10,
                  bottom: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      border: Border.all(color: Colors.green, width: 5),
                    ),
                    child: AspectRatio(
                        aspectRatio: 1.33,
                        child: CameraPreview(_cameraController!)),
                  ),
                )
              : Positioned(
                  top: 20,
                  left: 40,
                  right: 10,
                  bottom: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(color: Colors.red, width: 5),
                    ),
                    child: AspectRatio(
                        aspectRatio: 1.33,
                        child: CameraPreview(_cameraController!)),
                  ),
                ),

          /* Visibility(
            visible: _draw,
            child: IndexedStack(
              index: 0,
              children: [
                _drawHands(_ratio, inferenceResults),
              ],
            ),
          ),*/
          if (_isRecording)
            Positioned(
              top: 30,
              left: 60,
              right: 40,
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    'Please mimic the motion at the right',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          if (!_isRecording)
            Positioned(
                top: 30,
                left: 60,
                right: 40,
                child: Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Put mobile on a flat surace\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: 'facing cieling and then\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: 'tap here',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _drawHands(ratio, inferenceResults) {
    return _ModelPainter(
      customPainter: HandsPainter(
        points: inferenceResults?['point'] ?? [],
        ratio: ratio,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ModelPainter extends StatelessWidget {
  const _ModelPainter({
    required this.customPainter,
    Key? key,
  }) : super(key: key);

  final CustomPainter customPainter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: customPainter,
    );
  }
}
