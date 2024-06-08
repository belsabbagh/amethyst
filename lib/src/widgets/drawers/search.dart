import 'dart:math';

import 'package:amethyst/src/core/indexer.dart';
import 'package:amethyst/src/core/models/note.dart';
import 'package:flutter/material.dart';


class SearchView extends StatefulWidget {
  final IndexService indexService;
  final void Function(Note note) onNoteSelected;

  const SearchView(
      {super.key, required this.indexService, required this.onNoteSelected});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  List<Note> _results = [];

  void _performSearch(String query) async {
    query = query.toLowerCase();
    // await Future.delayed(const Duration(milliseconds: 300));

    // setState(() {
    //   _results = widget.indexService.id2Path.keys
    //       .map((id) {
    //         return widget.indexService.getNoteById(id);
    //       })
    //       .where((note) {
    //         if (note == null) return false;
    //         return note.body.toLowerCase().contains(query) ||
    //             note.tags.any((tag) => tag.toLowerCase().contains(query)) ||
    //             note.props.values.any(
    //                 (value) => value.toString().toLowerCase().contains(query));
    //       })
    //       .toList()
    //       .cast<Note>();
    // });
    List<Note> sqlResults = await widget.indexService.searchSql(query);
    setState((){
      _results = sqlResults;
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
                    String body = _results[index].body;
                    return ListTile(
                      title: Text(
                          widget.indexService.id2Path[_results[index].id] ??
                              'Untitled'),
                      subtitle: Text(
                          '${body.substring(0, min(body.length - 1, 30))}...'),
                      onTap: () {
                        widget.onNoteSelected(_results[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
