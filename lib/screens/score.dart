import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:haigenie/l10n/l10n.dart';
import 'package:video_player/video_player.dart';

import '../model/score.dart';
import '../model/user.dart';
import '../services/VideoRecordingRepository.dart';

class ScoreView extends StatefulWidget {
  final User user;
  final bool guide;
  final String totalScore;
  final Duration totalTime;
  final List<StepResult> stepResults;
  final String video;
  const ScoreView(
      {super.key,
      required this.totalScore,
      required this.totalTime,
      required this.stepResults,
      required this.user,
      required this.video,
      required this.guide});
  @override
  State<StatefulWidget> createState() => _ScoreViewState();
}

class _ScoreViewState extends State<ScoreView> {
  final RecordingsRepository recordingsRepository = RecordingsRepository();
  late List<Score> score;
  late VideoPlayerController _controller;
  late VideoPlayerController _controller2;
  late Locale _selectedLocale = const Locale('en');
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<String> gifUrls = [
    'assets/Images/Feedback/palm_to_palm.gif',
    'assets/Images/Feedback/dorsum.gif',
    'assets/Images/Feedback/fingers_interlaced.gif',
    'assets/Images/Feedback/fingers_interlocked.gif',
    'assets/Images/Feedback/thumb.gif',
    'assets/Images/Feedback/palm_to_clap.gif',
  ];
  bool volumeUp = true;
  late Duration _duration;
  late String _remainingTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentLocale = Localizations.localeOf(context);
      setState(() {
        _selectedLocale = currentLocale;
      });
      _controller = _selectedLocale == const Locale('en')
          ? VideoPlayerController.asset('assets/videos/guide.mp4',
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
          : VideoPlayerController.asset('assets/videos/newGuideHindi.mp4',
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
      _controller.initialize().then((_) {
        setState(() {});
      });
      _selectedLocale == const Locale('en')
          ? int.parse(widget.totalScore) == 6
              ? audioPlayer.play(AssetSource(
                  "audios/Score-5-6 excellent teach others too.mp3"))
              : int.parse(widget.totalScore) > 2
                  ? audioPlayer.play(AssetSource("audios/Well_done.m4a"))
                  : audioPlayer.play(AssetSource("audios/Can_do_better.m4a"))
          : int.parse(widget.totalScore) == 6
              ? audioPlayer.play(AssetSource("audios/Score_5-6.mp3"))
              : int.parse(widget.totalScore) > 2
                  ? audioPlayer
                      .play(AssetSource("audios/Score_3-4_bahut_acha.mp3"))
                  : audioPlayer.play(
                      AssetSource("audios/Score-1-2behtar_karsakte_hai.mp3"));
      print('Current Locale: $currentLocale');
    });
    _controller2 = VideoPlayerController.file(File(widget.video),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _controller2.initialize().then((_) {
      _controller.addListener(() {
        if (_controller.value.position == Duration.zero) {
          setState(() {
            _duration = const Duration(seconds: 41);
            _remainingTime = formatDuration(_duration); // Reset the timer
          });
        }
      });
      setState(() {});
    });
    updateScoreList();
    _duration = const Duration(seconds: 41);
    _remainingTime = formatDuration(_duration);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return twoDigitSeconds;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration = _duration - const Duration(seconds: 1);
          _remainingTime = formatDuration(_duration);
          print(_remainingTime);
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
        /* appBar: AppBar(
          backgroundColor: Colors.white,
          // leading:
          //     Image.asset("assets/Images/app_icon.png", width: 50, height: 50),
          centerTitle: true,
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: int.parse(widget.totalScore) > 4
                    ? "${l10n.comments_excellent}\n"
                    : int.parse(widget.totalScore) > 2
                        ? "${l10n.comments_well_done}\n"
                        : "${l10n.comments_do_better}\n",
                style: TextStyle(
                    color: int.parse(widget.totalScore) > 4
                        ? const Color(0xFF3a6d70)
                        : int.parse(widget.totalScore) > 2
                            ? const Color(0xFFf6d797)
                            : const Color(0xFF98463b),
                    fontSize: 21,
                    fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        ),*/
        body: SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
                child: Center(
                    child: RichText(
                  // textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: int.parse(widget.totalScore) > 4
                          ? "${l10n.comments_excellent}\n"
                          : int.parse(widget.totalScore) > 2
                              ? "${l10n.comments_well_done}\n"
                              : "${l10n.comments_do_better}\n",
                      style: TextStyle(
                          color: int.parse(widget.totalScore) > 4
                              ? const Color(0xFF3a6d70)
                              : int.parse(widget.totalScore) > 2
                                  ? const Color(0xFFf6d797)
                                  : const Color(0xFF98463b),
                          fontSize: 21,
                          fontWeight: FontWeight.bold),
                    ),
                  ]),
                ))),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              height: MediaQuery.of(context).size.height * 0.60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(
                        5.0), // Adjust the margin as needed
                    child: _buildVideoPlayer2(),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(
                          1.0), // Adjust the margin as needed
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Column(
                          children: [
                            Image.asset("assets/Images/app_icon.png",
                                width: MediaQuery.of(context).size.width * 0.06),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                               TextSpan(
                                  text: 'HAIgenie Score \n',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: MediaQuery.of(context).size.width * 0.02,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${widget.totalScore}/6',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(context).size.width * 0.02,
                                  ),
                                ),
                              ]),
                            ),
                            IconButton(
                              onPressed: () async {
                                if (_controller.value.isPlaying &&
                                    _controller2.value.isPlaying) {
                                  _controller.pause();
                                  _controller2.pause();
                                  timer.cancel();
                                } else {
                                  _controller2.play();
                                  _controller.play();
                                  startTimer();
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                (_controller.value.isPlaying &&
                                        _controller2.value.isPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: MediaQuery.of(context).size.width * 0.05,
                              ),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (widget.guide == true) {
                                          widget.user.availableAttempts =
                                              widget.user.availableAttempts! -
                                                  1;
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  '/dashboard',
                                                  arguments: [
                                                widget.user,
                                                score
                                              ]);
                                        } else {
                                          widget.user.certificationAttempts =
                                              widget.user
                                                      .certificationAttempts! -
                                                  1;
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  '/dashboard',
                                                  arguments: [
                                                widget.user,
                                                score
                                              ]);
                                        }
                                      },
                                      icon:  Icon(
                                        Icons.home,
                                        size: MediaQuery.of(context).size.width * 0.04,
                                      )),
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
                                      },
                                      icon: volumeUp
                                          ? Icon(
                                              Icons.volume_up,
                                              size: MediaQuery.of(context).size.width * 0.04,
                                            )
                                          : Icon(
                                              Icons.volume_off,
                                              size: MediaQuery.of(context).size.width * 0.04,
                                            )),
                                ])
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(
                        5.0), // Adjust the margin as needed
                    child: _buildVideoPlayer(),
                  ),
                ],
              ),
            ),
            /*    int.parse(_remainingTime) < 41 &&
                      int.parse(_remainingTime) != 00 &&
                      int.parse(_remainingTime) != 41
                  ? Expanded(
                      flex: 1,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gifUrls.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, // Number of columns
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 50,
                        ),
                        itemBuilder: (context, index) {
                          bool isStepActive = false;
                          if (index == 0 &&
                              int.parse(_remainingTime) > 32 &&
                              int.parse(_remainingTime) <= 36)
                            isStepActive = true;
                          if (index == 1 &&
                              int.parse(_remainingTime) > 25 &&
                              int.parse(_remainingTime) <= 32)
                            isStepActive = true;
                          if (index == 2 &&
                              int.parse(_remainingTime) > 21 &&
                              int.parse(_remainingTime) <= 25)
                            isStepActive = true;
                          if (index == 3 &&
                              int.parse(_remainingTime) > 14 &&
                              int.parse(_remainingTime) <= 21)
                            isStepActive = true;
                          if (index == 4 &&
                              int.parse(_remainingTime) > 6 &&
                              int.parse(_remainingTime) <= 14)
                            isStepActive = true;
                          if (index == 5 &&
                              int.parse(_remainingTime) > 0 &&
                              int.parse(_remainingTime) <= 6) isStepActive = true;
                          return Stack(
                            children: [
                              Image.asset(
                                gifUrls[index],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              isStepActive
                                  ? Positioned(
                                      top: 30,
                                      bottom: 30,
                                      right: 30,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child:
                                            widget.stepResults[index].isVerified
                                                ? Image.asset(
                                                    'assets/Images/Feedback/greentick.png',
                                                    width: 20,
                                                    height: 20,
                                                  )
                                                : Image.asset(
                                                    'assets/Images/Feedback/redcross.png',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          );
                        },
                      ))
                  :*/
            Container(
              height: MediaQuery.of(context).size.height * 0.23,
              padding: const EdgeInsets.fromLTRB(10, 0, 10,0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gifUrls.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // Number of columns
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.asset(
                        gifUrls[index]
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.13,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                            child: widget.stepResults[index].isVerified
                              ? Image.asset(
                                  'assets/Images/Feedback/greentick.png',
                                )
                              : Image.asset(
                                  'assets/Images/Feedback/redcross.png',)
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildVideoPlayer() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.30,
        // height: 210,
        child: AspectRatio(
          aspectRatio: 1.33,
          child: VideoPlayer(_controller),
        ));
  }

  Widget _buildVideoPlayer2() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.30,
        child: AspectRatio(
          aspectRatio: 1.33,
          child: VideoPlayer(_controller2),
        ));
  }

  Future<void> updateScoreList() async {
    score = (await recordingsRepository.lastScore())!;
  }
}

class StepResult {
  final int stepNumber;
  final String stepType;
  final String gifPath;
  final bool isVerified;

  StepResult({
    required this.stepNumber,
    required this.stepType,
    required this.gifPath,
    required this.isVerified,
  });
}
