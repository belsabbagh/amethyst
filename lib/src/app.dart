import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/tag.dart';
import 'package:amethyst/src/core/models/vault.dart';
import 'package:amethyst/src/core/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animated_tree_view/animated_tree_view.dart';

class MyApp extends StatefulWidget {
  final SettingsController settingsController; // Declare the named parameter

  const MyApp({Key? key, required this.settingsController})
      : super(key: key); // Pass the settingsController parameter

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _pickDirectory(BuildContext context) async {
    String? newDirectory = await FilePicker.platform.getDirectoryPath();

    if (newDirectory == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DummyPage(directoryPath: newDirectory),
      ),
    );
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

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  List<String> _results = [];

  void _performSearch(String query) {
    // Simulate a search by generating some dummy results
    setState(() {
      _results =
          List.generate(10, (index) => 'Result ${index + 1} for "$query"');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Enter search query',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _performSearch(_controller.text);
              },
            ),
          ),
          onChanged: (query) {
            _performSearch(query);
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _controller.text.isEmpty || _results.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_results[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TagView extends StatelessWidget {
  final IndexService indexService;

  const TagView({Key? key, required this.indexService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: indexService.tags.length,
      itemBuilder: (context, index) {
        String key = indexService.tags.keys.elementAt(index);
        return ListTile(
          title: Text(key),
          subtitle: Text("Count ${indexService.tags[key]!.length}"),
        );
      },
    );
  }
}

class LeftDrawer extends StatelessWidget {
  final IndexService indexService;
  const LeftDrawer({Key? key, required this.indexService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.folder), text: 'Files'),
                Tab(icon: Icon(Icons.search), text: 'Search'),
                Tab(icon: Icon(Icons.tag), text: 'Tags'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const Center(child: Text('Home Content')),
                  const Center(child: SearchView()),
                  Center(child: TagView(indexService: indexService)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String directoryPath;
  late final IndexService indexService =
      IndexService(vault: Vault(path: directoryPath));

  DummyPage({Key? key, required this.directoryPath}) : super(key: key) {
    indexService.index();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(directoryPath),
      ),
      drawer: LeftDrawer(indexService: indexService),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Count: ${indexService.countNotes()}'),
            Text('Tags: ${indexService.tags.length}'),
          ],
        ),
      ),
    );
  }
}
