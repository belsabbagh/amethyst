import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/core/settings/settings_controller.dart';
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
  String? _selectedDirectory; // Make selected directory nullable

  Future<void> _pickDirectory(BuildContext context) async {
    String? newDirectory = await FilePicker.platform.getDirectoryPath();

    setState(() {
      _selectedDirectory = newDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedDirectory != null) {
      body = DummyPage(directoryPath: _selectedDirectory!);
    } else {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: () => _pickDirectory(context)
            , child: const Text('Pick Directory')),
          ],
        ),
      );
    }

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
          title: const Text('Select Folder'),
        ),
        body: body,
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String directoryPath;
  late final IndexService indexService = IndexService(vault: Vault(path: directoryPath));
  DummyPage({Key? key, required this.directoryPath}) : super(key: key) {
    indexService.index();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Selected Directory: $directoryPath. Count: ${indexService.countNotes()}. Tags: ${indexService.tags.length}'),
    );
  }
}
