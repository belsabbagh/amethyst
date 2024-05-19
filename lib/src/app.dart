import 'package:amethyst/src/core/settings/settings_controller.dart';
import 'package:amethyst/src/pages/vault.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';

class MyApp extends StatefulWidget {
  final SettingsController settingsController; // Declare the named parameter

  const MyApp({Key? key, required this.settingsController})
      : super(key: key); // Pass the settingsController parameter

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _pickDirectory(BuildContext context) async {
    String? newDirectory = "/home/belal/projects/nadapedia"; // await FilePicker.platform.getDirectoryPath();

    if (newDirectory == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaultPage(directoryPath: newDirectory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
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
          title: const Text('Select Folder'),
        ),
        body: Center(
          child: Builder(
            builder: (context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => _pickDirectory(context),
                    child: const Text('Pick Directory'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}