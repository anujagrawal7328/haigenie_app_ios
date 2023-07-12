import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class GuidingVideoScreen extends StatefulWidget {
  const GuidingVideoScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GuidingVideoScreenState();
}

class _GuidingVideoScreenState extends State<GuidingVideoScreen> {
  late VideoPlayerController _controller;

  late Locale _selectedLocale = const Locale('en');


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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Video '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : Container(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              },
              child: Icon(
                _controller.value.isPlaying==true? Icons.pause : Icons.play_arrow,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}