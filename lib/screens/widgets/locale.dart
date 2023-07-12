import 'package:flutter/material.dart';

class LocaleDropdown extends StatefulWidget {
  final Locale selectedLocale;
  final Function(Locale?) onLocaleChanged;

  const LocaleDropdown({super.key,
    required this.selectedLocale,
    required this.onLocaleChanged,
  });

  @override
  State<StatefulWidget> createState() => _LocaleDropdownState();
}

class _LocaleDropdownState extends State<LocaleDropdown> {
  @override
  Widget build(BuildContext context) {
    final languageOptions = [
      const Locale('en'),
      const Locale('hi'),
    ];
    print(widget.selectedLocale);
    return DropdownButton<Locale>(
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(fontSize: 18, color: Colors.black),
      underline: SizedBox.shrink(),
      value: widget.selectedLocale,
      onChanged: (value){
        widget.onLocaleChanged(value);
      },
      items: languageOptions.map((Locale locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Text(
            locale.languageCode == 'en' ? 'English' : 'हिंदी',
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        );
      }).toList(),
      // Remove the default underline
      icon: const Icon(
        Icons.language,
        color: Color(0xFF00a2d8),
      ),
    );
  }
}