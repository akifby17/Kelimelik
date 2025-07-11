import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_word_app/models/word.dart';
import 'package:flutter_word_app/services/isar_service.dart';

class WordListScreen extends StatefulWidget {
  final IsarService isarService;
  final Function(Word) onEditWord;
  const WordListScreen({super.key, required this.isarService,required this.onEditWord});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  late Future<List<Word>> _getAllWords;
  List<Word> _currentWords = [];
  List<Word> _filteredWords = [];
  final List<String> _wordTypes = [
    'All',
    'Noun',
    'Adjective',
    'Verb',
    'Adverb',
    'Phrasal Verb',
    'Idiom',
  ];
  String _selectedWordType = 'All';
  bool _showLearned = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllWords = _getWordsFromDb();
  }

  Future<List<Word>> _getWordsFromDb() async {
    var wordFromDBdata=await widget.isarService.getAllWords();
    _currentWords = wordFromDBdata;
    return wordFromDBdata;
  }

  void _refreshWords() {
    setState(() {
      _getAllWords = _getWordsFromDb();
    });
  }

  void _changeToggle(Word word) async {
    await widget.isarService.toggleWord(word.id);
    final index = _currentWords.indexWhere((element) => element.id == word.id);
    var changedWord = _currentWords[index];
    changedWord.isLearned = !changedWord.isLearned;
    _currentWords[index] = changedWord;
    setState(() {});
  }
  _applyFilter(){
    _filteredWords=List.from(_currentWords);

    if(_selectedWordType!='All'){
      _filteredWords=_filteredWords.where((element) => element.wordType.toLowerCase()==_selectedWordType.toLowerCase(),).toList();
    }
    if(_showLearned){
       _filteredWords=_filteredWords.where((element) => element.isLearned!=_showLearned).toList();
    }

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterCard(),
        Card(),
        Expanded(
          child: FutureBuilder<List<Word>>(
            future: _getAllWords,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Center(child: Text("Hata!!!"));
              }
              if (snapshot.hasData) {
                return snapshot.data!.isEmpty
                    ? Center(child: Text("Lütfen Kelime Ekleyiniz"))
                    : _buildListView(snapshot.data);
              } else {
                return Text("Text");
              }
            },
          ),
        ),
      ],
    );
  }

  ListView _buildListView(List<Word>? data) {
    
    _applyFilter();
    return ListView.builder(
      itemBuilder: (context, index) {
        var currentWord = _filteredWords[index];
        return Dismissible(
          background: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          ),
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) => _deleteWord(currentWord),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Kelime Sil"),
                  content: Text(
                    '${currentWord.englishWord} Kelimesini Silmek İstediğinize Emin Misiniz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text("Vazgeç"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("Sil"),
                    ),
                  ],
                );
              },
            );
          },
          child: GestureDetector(
            onTap:()=> widget.onEditWord(currentWord),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(currentWord.englishWord),
                      subtitle: Text(currentWord.turkishWord),
                      leading: Chip(label: Text(currentWord.wordType)),
                      trailing:  Switch(
                        value: currentWord.isLearned,
                                                onChanged: (value) async {
                          _changeToggle(currentWord);
                        },
                      ),
                    ),
                    if (currentWord.story != null &&
                        currentWord.story!.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer.withOpacity(0.6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb),
                                SizedBox(width: 8),
                                Text("Hatırlatıcı Not"),
                              ],
                            ),
                            SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                currentWord.story ?? '',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (currentWord.imageByte != null)
                      Image.memory(
                        Uint8List.fromList(currentWord.imageByte!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      itemCount: _filteredWords.length,
    );
  }

  void _deleteWord(Word currentWord) async {
    await widget.isarService.deleteWord(currentWord.id);
    _currentWords.removeWhere((element) => element.id == currentWord.id);
  }

  Widget _buildFilterCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_rounded),
                SizedBox(width: 4),
                Text("Filtrele"),
                SizedBox(width: 4),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Kelime Türü',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedWordType,
                    items: _wordTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWordType = value!;
                        _applyFilter();
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Öğrendiklerimi Gizle'),
                Switch(
                  value: _showLearned,
                  onChanged: (value) {
                    setState(() {
                      _showLearned = !_showLearned;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
