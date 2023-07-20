import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:haigenie/screens/widgets/locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale) changeLocale;
  User user;
  SettingsPage({super.key, required this.changeLocale, required this.user});
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
        _selectedLocale = currentLocale;
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
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(children: [
        /* Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Text(
              widget.user.name!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              widget.user.department!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),*/
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text(
            'Full Name',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(widget.user.name!),
        ),
        ListTile(
          leading: Icon(Icons.email),
          title: const Text(
            'Email',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(widget.user.email!),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: const Text(
            'Phone',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(widget.user.whatsappNo!),
        ),
        ListTile(
          leading: Icon(Icons.work),
          title: const Text(
            'Department',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(widget.user.department!),
        ),
        ListTile(
          leading: Icon(Icons.workspaces),
          title: const Text(
            'Organisation',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(widget.user.department!),
        ),
        ListTile(
          leading: Icon(Icons.subscriptions),
          title: const Text(
            'Subscription',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(widget.user.userType!),
        ),
        ListTile(
          leading: Icon(Icons.task),
          title: const Text(
            'Available Attempts',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text('${widget.user.availableAttempts!}'),
        ),
        ListTile(
          leading: Icon(Icons.language),
          title: const Text(
            'Language',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: LocaleDropdown(
              selectedLocale: _selectedLocale,
              onLocaleChanged: _changeLocale,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.manage_accounts_sharp),
          title: const Text(
            'Account Deletion',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/account_deletion');
              },
              style: ElevatedButton.styleFrom(
                  elevation:
                      8.0, // Adjust the value to change the button shape
                  shadowColor: Colors.black
                      .withOpacity(0.4), // Adjust the shadow color and opacity
                  splashFactory: InkRipple.splashFactory,
                  backgroundColor: Colors.blue),
              child: const Center(
                  child: Text(
                    "Request Account Deletion",
                    style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ),
          ),
        ),
      ]),
    );
  }
}
