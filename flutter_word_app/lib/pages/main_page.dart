import 'package:flutter/material.dart';
import 'package:flutter_word_app/models/word.dart';
import 'package:flutter_word_app/screens/add_word_screen.dart';
import 'package:flutter_word_app/screens/word_list_screen.dart';
import 'package:flutter_word_app/services/isar_service.dart';

class MainPage extends StatefulWidget {
  final IsarService isarService;
  const MainPage({super.key,required this.isarService});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedScreen=0;

  Word? _wordToEdit;
  void _editWord(Word updatedWord){
    setState(() {
      _selectedScreen=1;
      _wordToEdit=updatedWord;
    });
  }
  List<Widget> get _screens => [
    WordListScreen(isarService:widget.isarService,
    onEditWord:_editWord),
    AddWordScreen(isarService: widget.isarService,wordToEdit:_wordToEdit,onSave:(){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: 
        Text("Kelime Kaydedildi")));
      setState(() {
        _wordToEdit=null;
        _selectedScreen=0;
      });
    })
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelimelerim'),
      ),
      body: _screens[_selectedScreen],
      bottomNavigationBar: NavigationBar(selectedIndex: _selectedScreen,destinations: [
        const NavigationDestination(icon: Icon(Icons.list_alt), label: 'Kelimeler'),
         NavigationDestination(icon: Icon(Icons.add_circle_outline), label:_wordToEdit==null? 'Ekle':'Güncelle')
      ],onDestinationSelected: (value) {
        setState(() {
          _selectedScreen=value;
          if(_selectedScreen==0){
            _wordToEdit=null;
          }
        });
      },),
    );
  }
}