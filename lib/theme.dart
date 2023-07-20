import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

final FlutterLocalization _localization = FlutterLocalization.instance;
final ThemeData lightTheme = ThemeData.light()
    .copyWith(
  colorScheme: ColorScheme.fromSeed(seedColor:Colors.blue),
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.blue)),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black.withOpacity(0.87),
      fontFamily: _localization.fontFamily
    ),
    bodySmall: TextStyle(
      color: Colors.black.withOpacity(0.87), fontFamily: _localization.fontFamily
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      // Set the button's text color
      textStyle: TextStyle( fontFamily: _localization.fontFamily,fontSize: 18.0, color: Colors.black), backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      // Set the button's text style
      padding: const EdgeInsets.symmetric(
          vertical: 16.0, horizontal: 32.0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(8.0), // Set the button's border radius
      ),
    ),
  ),
);
