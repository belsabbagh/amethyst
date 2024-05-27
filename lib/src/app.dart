import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/core/settings/settings_controller.dart';
import 'package:amethyst/src/pages/vault.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class MyApp extends StatefulWidget {
  final SettingsController settingsController; // Declare the named parameter

  const MyApp({super.key, required this.settingsController}); // Pass the settingsController parameter

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _pickDirectory(BuildContext context) async {
    if (await _requestPermissions()) {
      String? newDirectory = await FilePicker.platform.getDirectoryPath();

      if (newDirectory == null) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
        
          builder: (context) => VaultPage(vault: Vault(path: newDirectory)),
        ),
      );
    } else {
      // Handle the case where permissions are not granted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to pick a directory'),
        ),
      );
    }
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) =>
          // AppLocalizations.of(context)!.appTitle,
          'Amethyst',
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