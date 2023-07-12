import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:haigenie/screens/auth.dart';
import 'package:haigenie/screens/dashboard.dart';
import 'package:haigenie/screens/guide.dart';
import 'package:haigenie/screens/recorder.dart';
import 'package:haigenie/screens/settings.dart';
import 'package:haigenie/screens/updatePassword.dart';
import 'package:haigenie/screens/score.dart';
import 'package:haigenie/services/VideoRecordingRepository.dart';
import 'package:haigenie/services/authRepository.dart';
import 'package:haigenie/services/service_locator.dart';
import 'package:haigenie/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:upgrader/upgrader.dart';
import 'Bindings/NetworkBinding.dart';
import 'model/score.dart';
import 'model/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
  setupLocator();

  runApp(const MyApp());
}

bool _initialUriIsHandled = false;

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final AuthRepository authRepository = AuthRepository();
  final RecordingsRepository recordingsRepository = RecordingsRepository();
  List<Score>? score = [];
  late bool isValidToken = false;
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;
  StreamSubscription? _sub;
  Locale? _currentLocale;

  String? storeVersion;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  @override
  void initState() {
    _handleIncomingLinks();
    _handleInitialUri();
    getLocale();
    _initPackageInfo();
    getStoreVersion('org.haigenie.com.haigenie');
    super.initState();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  Future<String?> getStoreVersion(String myAppBundleId) async {

    if (Platform.isAndroid) {
      PlayStoreSearchAPI playStoreSearchAPI = PlayStoreSearchAPI();
      final result = await playStoreSearchAPI.lookupById(myAppBundleId, country: 'US');
      if (result != null) storeVersion = PlayStoreResults.version(result);
      log('PlayStore version: $storeVersion}');
    } else if (Platform.isIOS) {
      ITunesSearchAPI iTunesSearchAPI = ITunesSearchAPI();
      Map<dynamic, dynamic>? result =
      await iTunesSearchAPI.lookupByBundleId(myAppBundleId, country: 'US');
      if (result != null) storeVersion = ITunesResults.version(result);
      log('AppStore version: $storeVersion}');
    } else {
      storeVersion = null;
    }
    return storeVersion;
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

Future<void> getLocale() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String locale= prefs.getString('locale') ?? 'en';
  _changeLocale(Locale(locale));
}

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got uri: $uri');
        }
        setState(() async {
          if (uri != null) {
            _latestUri = uri;
          }
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) return;
        if (kDebugMode) {
          print('got err: $err');
        }
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      try {
        _initialUriIsHandled = true;
        var uri = await getInitialUri();
        if (uri == null) {
          if (kDebugMode) {
            print('no initial uri');
          }
        } else {
          if (kDebugMode) {
            print('got initial uri: $uri');
          }
        }
        if (!mounted) return;

        final SharedPreferences prefs = await SharedPreferences.getInstance();

        setState(() {
          _initialUri = uri;
          prefs.setString('url', uri.toString());
        });
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        if (kDebugMode) {
          print('falied to get initial uri');
        }
      } on FormatException catch (err) {
        if (!mounted) return;
        if (kDebugMode) {
          print('malformed initial uri');
        }
        setState(() => _err = err);
      }
    }
  }
  void _changeLocale(Locale newLocale) {
    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: NetworkBinding(),
      title: 'HAIgenie',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _currentLocale,
      localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {

        // Return the current locale if it's not null
        if (_currentLocale != null) {
          return _currentLocale;
        }
        Locale defaultLocale = const Locale('en');
        if (supportedLocales.contains(defaultLocale)) {
          return defaultLocale;
        }
        return supportedLocales.first;
      },
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      routes: {
        '/auth': (_) =>LoginPage(changeLocale: _changeLocale),
        '/guide': (_) => const GuidingVideoScreen(),
        '/settings': (_) => SettingsPage(changeLocale:_changeLocale),
      },
      onGenerateRoute: (route) {
        if(route.name =='/score'){
          final List<dynamic> arguments = route.arguments as List<dynamic>;
          final List<Score> score = (route.arguments as List)[0] as List<Score>;
          final User user = (route.arguments as List)[1] as User;
          final String video = (route.arguments as List)[2] as String;
          return MaterialPageRoute(
            builder: (context) => ScoreView(
              video: video,
              user: user,
            totalScore: '${score[0].totalScore!.toInt()}',
            totalTime: const Duration(seconds: 41),
            stepResults: [
              StepResult(
                stepNumber: 1,
                stepType: 'Palm To Palm',
                gifPath: 'assets/Images/Feedback/palm_to_palm.gif',
                isVerified: score[0].score1!<=0?false:true,
              ),
              StepResult(
                stepNumber: 2,
                stepType: 'Dorsum',
                gifPath: 'assets/Images/Feedback/dorsum.gif',
                isVerified:score[0].score2!<=0?false:true,
              ),
              StepResult(
                stepNumber: 3,
                stepType: 'Fingers Interlaced',
                gifPath: 'assets/Images/Feedback/fingers_interlaced.gif',
                isVerified: score[0].score3!<=0?false:true,
              ),
              StepResult(
                stepNumber: 4,
                stepType: 'Fingers Interlocked',
                gifPath: 'assets/Images/Feedback/fingers_interlocked.gif',
                isVerified: score[0].score4!<=0?false:true,
              ),
              StepResult(
                stepNumber: 5,
                stepType: 'Thumb',
                gifPath: 'assets/Images/Feedback/thumb.gif',
                isVerified: score[0].score5!<=0?false:true,
              ),
              StepResult(
                stepNumber: 6,
                stepType: 'Palm To Clap',
                gifPath: 'assets/Images/Feedback/palm_to_clap.gif',
                isVerified: score[0].score6!<=0?false:true,
              ),
            ],
          ),
        );
        }
        if (route.name == "/recorder") {
          final List<dynamic> arguments = route.arguments as List<dynamic>;
          final User user = (route.arguments as List)[0] as User;
          final List<Score>? score = (route.arguments as List)[1] as List<Score>?;
          final bool guide=(route.arguments as List)[2] as bool;
          return MaterialPageRoute(
            builder: (context) => VideoRecordingScreen(user: user,score: score,guide: guide,),
          );
        }
        if (route.name == "/dashboard") {
          final List<dynamic> arguments = route.arguments as List<dynamic>;
          final User user = (route.arguments as List)[0] as User;
          final List<Score>? score = (route.arguments as List)[1] as List<Score>?;
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(user: user,score:score),
          );
        }
        if (route.name == "/update") {
          String email = _initialUri!.pathSegments[1];
          String token = _initialUri!.pathSegments[2];
          return MaterialPageRoute(
            builder: (context) => UpdatePassword(email: email,token:token),
          );
  }
      },
      home:  FutureBuilder<User?>(
            future: verifyToken(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {

              return const Scaffold(body:Center(child: CircularProgressIndicator(color: Color(0xFF00a2d8),)));
            } else if (snapshot.hasError) {

            } else if (snapshot.data != null) {
              return _packageInfo.version==storeVersion?snapshot.data?.userType=='multiuser'?VideoRecordingScreen(user: snapshot.data!,score: score,guide:true):DashboardScreen(user:snapshot.data!,score: score):
              UpgradeAlert(child: snapshot.data?.userType=='multiuser'?VideoRecordingScreen(user: snapshot.data!,score: score,guide:true):DashboardScreen(user:snapshot.data!,score: score),);
            } else if (_initialUri != null) {

              String email = _initialUri!.pathSegments[1];
              String token = _initialUri!.pathSegments[2];
              return UpdatePassword(email:email,token:token);
            } else {
              return _packageInfo.version==storeVersion?LoginPage(changeLocale: _changeLocale):UpgradeAlert(child: LoginPage(changeLocale: _changeLocale),);
            }
            return const Scaffold(body:Center(child: CircularProgressIndicator(color: Color(0xFF00a2d8),)));
          }),
           themeMode: ThemeMode.light,
    );

  }

  Future<User?> verifyToken() async {
    final user = await authRepository.verifyToken();
    if (user != null) {
      score = await recordingsRepository.lastScore();
      return user;
    } else {
      return null;
    }
  }
}
