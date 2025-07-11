import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_word_app/models/word.dart';
import 'package:flutter_word_app/services/isar_service.dart';
import 'package:image_picker/image_picker.dart';
class AddWordScreen extends StatefulWidget {
  final IsarService isarService;
  final VoidCallback onSave;
    final Word? wordToEdit;
  const AddWordScreen({super.key, required this.isarService,required this.onSave,this.wordToEdit});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey=GlobalKey<FormState>();
  final _englishController=TextEditingController();
  final _turkishController =TextEditingController();
  final _storyController=TextEditingController();

  String _selectedWordType="Noun";
  bool _isLearned=false;
  final ImagePicker _picker=ImagePicker();
  File? _imageFile;
  final List<String> _wordTypes=[
    'Noun','Adjective','Verb','Adverb','Phrasal Verb','Idiom'
  ];

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.wordToEdit!=null){
      var updateWord=widget.wordToEdit;
      _englishController.text=updateWord!.englishWord;
      _turkishController.text=updateWord.turkishWord;
      _storyController.text=updateWord.story!;
      _isLearned=updateWord.isLearned;

    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
        super.dispose();
        _englishController.dispose();
        _turkishController.dispose();
        _storyController.dispose();
  }
  Future <void> _pickPhoto() async{
   final image=await  _picker.pickImage(source:ImageSource.gallery );
   if(image!=null){
      setState(() {
        _imageFile=File(image.path);
      });
   }
  }
  Future <void> _saveWord() async{
    if(_formKey.currentState!.validate()){

    
    var englishWord=_englishController.text;
    var turkishWord=_turkishController.text;
    var story=_storyController.text;
    Word word=Word(englishWord: englishWord, turkishWord: turkishWord, wordType: _selectedWordType,story: story,imageByte: _imageFile!=null ? await _imageFile!.readAsBytes():null,
    
    
    );
    if(widget.wordToEdit==null){
      word.imageByte=_imageFile!=null? await _imageFile!.readAsBytes():null;
      await widget.isarService.saveWord(word);
    }
    else{
      word.id=widget.wordToEdit!.id;
      word.imageByte=_imageFile!=null? await _imageFile!.readAsBytes():widget.wordToEdit?.imageByte;
      await widget.isarService.updateWord(word);
    }
    widget.onSave();
    
    
    
    }

  }

  
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16),
    child:Form(key:_formKey,child: 
    ListView(
      children: [
          TextFormField(controller: _englishController,validator: (value) {
            if(value!.isEmpty){
              return "Lütfen Kelime Giriniz";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'İngilizce Kelime',border:OutlineInputBorder()
          ),),
          SizedBox(height: 16,),
          TextFormField(validator: (value) {
            if(value!.isEmpty){
              return "Lütfen Kelime Giriniz";
            }
            return null;
          },controller: _turkishController,decoration: InputDecoration(
            labelText: 'Türkçe Kelime',border:OutlineInputBorder()
          ),),
          SizedBox(height: 16,),
          DropdownButtonFormField(value:_selectedWordType,decoration: InputDecoration(
            border: OutlineInputBorder(),label: Text('Kelime Türü')
          ),items: _wordTypes.map((e) {
            return DropdownMenuItem(value: e,child: Text(e),);
          },).toList(), onChanged: (value) {
            setState(() {
              _selectedWordType=value!;
            });
          },),
          SizedBox(height: 16,),
          TextFormField(maxLines: 3,controller: _storyController,decoration: InputDecoration(
            labelText: 'Kelime Açıklaması ',border:OutlineInputBorder()
          ),),
          Row(
            children: [
              Text('Öğrenildi'),
              Switch(value: _isLearned, onChanged: (value){
                setState(() {
                  _isLearned=!_isLearned;
                });
              })
            ],
          ),
          SizedBox(height: 8,),
          ElevatedButton.icon(onPressed: _pickPhoto, label: Text("Resim Ekle"),icon: Icon(Icons.image),),
          SizedBox(height: 8,),
          if(widget.wordToEdit?.imageByte != null||_imageFile!=null)...[
            if(_imageFile!=null)
              Image.file(_imageFile!,height: 250,fit: BoxFit.cover,)
            else if(widget.wordToEdit?.imageByte != null)
              Image.memory(Uint8List.fromList(widget.wordToEdit!.imageByte!),height: 150,fit: BoxFit.cover,),
          ]
          ,
          
          SizedBox(height: 8,),
          ElevatedButton(onPressed: _saveWord, child: widget.wordToEdit!=null ?Text("Güncelle"):Text("Ekle"))

          

      ],
    )
    ) ,
    );
  }

  

  
}