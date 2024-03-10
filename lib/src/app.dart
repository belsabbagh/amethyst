import 'package:amethyst/src/core/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class MyApp extends StatefulWidget {
  final SettingsController settingsController; // Declare the named parameter

  const MyApp({Key? key, required this.settingsController})
      : super(key: key); // Pass the settingsController parameter

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedDirectory = './';

  Future<void> _pickDirectory(BuildContext context) async {
    String? newDirectory = await FilePicker.platform.getDirectoryPath();

    setState(() {
      _selectedDirectory = newDirectory ?? _selectedDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Select Folder'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  // Open folder picker
                  await _pickDirectory(context);
                },
                child: Text('Open Folder Picker'),
              ),
              SizedBox(height: 20),
              _selectedDirectory != null
                  ? Text(
                      'Selected folder: $_selectedDirectory',
                      style: TextStyle(fontSize: 16),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
