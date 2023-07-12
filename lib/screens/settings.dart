import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:haigenie/screens/widgets/locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale) changeLocale;
  const SettingsPage({super.key,required this.changeLocale});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = 'English';
  List<String> languages = ['English', 'Spanish', 'French', 'German'];
  late Locale _selectedLocale = const Locale('en');

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final currentLocale = Localizations.localeOf(context);
      setState(() {
        _selectedLocale=currentLocale;
      });
      print('Current Locale: $currentLocale');
    });
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child:LocaleDropdown(
                selectedLocale: _selectedLocale,
                onLocaleChanged: _changeLocale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}