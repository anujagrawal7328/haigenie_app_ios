import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:haigenie/l10n/l10n.dart';
import 'package:haigenie/screens/forgotPassword.dart';
import 'package:haigenie/screens/widgets/customTextField.dart';
import 'package:haigenie/screens/registration.dart';
import 'package:haigenie/screens/widgets/locale.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/VideoRecordingRepository.dart';
import '../services/authRepository.dart';

List<TextEditingController> createControllers(int count) {
  return List<TextEditingController>.generate(
      count, (_) => TextEditingController());
}

class LoginPage extends StatefulWidget {
  final Function(Locale) changeLocale;
  const LoginPage({super.key,required this.changeLocale});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late List<TextEditingController> controllers;
  final RecordingsRepository recordingsRepository = RecordingsRepository();
  final AuthRepository authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _formIsValid = false;
  bool _isLoggingIn = false;
  bool _privacyPolicyAccepted = true;
  late ScaffoldMessengerState _scaffoldMessenger;
  late NavigatorState navigator;
  late Locale _selectedLocale = const Locale('en');
  @override
  void initState() {
    controllers = createControllers(2);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentLocale = Localizations.localeOf(context);
      setState(() {
        _selectedLocale=currentLocale;
      });
      print('Current Locale: $currentLocale');
    });
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  _validateForm() {
    setState(() {
      _formIsValid = controllers[0].text.isNotEmpty &&
          controllers[1].text.isNotEmpty &&
          _privacyPolicyAccepted;
    });
  }

  Future<void> _login(ScaffoldMessengerState scaffoldMessenger,
      NavigatorState navigatorState) async {
    setState(() {
      _isLoggingIn = true;
    });
    String username = controllers[0].text;
    String password = controllers[1].text;
    final user = await authRepository.login(username, password);
    if (user != null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Succesfully Logged In!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      await recordingsRepository.lastScore().then((value) => navigatorState
          .pushReplacementNamed('/dashboard', arguments: [user, value]));
    } else {
      setState(() {
        _isLoggingIn = false;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid username or password',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeLocale(Locale? newLocale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('locale', newLocale!.languageCode);
      widget.changeLocale(newLocale);
      _selectedLocale = newLocale;
    });
  }
  @override
  Widget build(BuildContext context) {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    navigator = Navigator.of(context);
    final l10n = context.l10n;
    print('${l10n.policy}${Localizations.localeOf(context)}');
  return Scaffold(
        body: Builder(
            builder: (BuildContext context) {
      return Localizations.override(
          context: context,
          locale: _selectedLocale,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 120.0, 20.0, 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20.0),
                        Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/Images/logo.png'),
                              // Replace with your image path
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextField(
                          controller: controllers[0],
                          validation: _validateForm,
                          label: '${l10n.email}*',
                          icon: const Icon(Icons.person, color: Colors.blue),
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextField(
                          controller: controllers[1],
                          validation: _validateForm,
                          label: '${l10n.password}*',
                          icon: const Icon(Icons.lock, color: Colors.blue),
                          obscurePassword: _obscurePassword,
                          iconButton: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              activeColor: Colors.blue,
                              value: _privacyPolicyAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _privacyPolicyAccepted = value!;
                                  _validateForm();
                                });
                              },
                            ),
                            Text(
                              l10n.agree,
                              style: const TextStyle(color: Colors.black,fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: (){
                                launchUrl(Uri.parse("https://docs.google.com/document/d/1TU6SP4mLtb1uNDHEqunkOp_sI6X32qlXbDu1xXGkgT4/edit#heading=h.i78sxgh1hxdh"),mode:LaunchMode.externalNonBrowserApplication);
                              },
                                child:Text(" ${l10n.policy}",style: const TextStyle(color:Colors.blue,fontSize: 14),),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: _formIsValid
                              ? () => _login(_scaffoldMessenger, navigator)
                              : null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.grey; // Disabled button color
                                }
                                return Colors.blue; // Enabled button color
                              },
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 50.0,
                            alignment: Alignment.center,
                            child:   _isLoggingIn
                                ? const CircularProgressIndicator(color: Colors.white,) // Display a progress indicator when the button is clicked
                                : Text(
                              l10n.login,
                              style:const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                _showForgotPasswordPopUp(context);
                              },
                              child: Text(l10n.forgotPassword,style: const TextStyle(color: Colors.blue),),
                            ),
                            TextButton(
                              onPressed: () {
                                _showRegistrationPopup(context);
                               // launchUrl(Uri.parse("https://www.haigenie.datakalp.com/Register"),mode: LaunchMode.externalApplication);
                              },
                              child: Text(l10n.register,style: const TextStyle(color: Colors.blue),),
                            ),
                          ],
                        ),

                      ],
                    )),
              ),
              Positioned(
                top: 20.0,
                right: 20.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 10.0,
                    ),
                    child: LocaleDropdown(
                      selectedLocale: _selectedLocale,
                      onLocaleChanged: _changeLocale,
                    ),
                  ),
                ),
              ),
            ],
          ));
    }));
  }

  void _showRegistrationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const RegistrationPopup();
      },
    );
  }

  void _showForgotPasswordPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ForgotPasswordPopup();
      },
    );
  }
}
