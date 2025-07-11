
import 'package:flutter/widgets.dart';
import 'package:flutter_word_app/models/word.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
class IsarService {
  late Isar isar;
  Future <void> init()async{
    try{
      final directory=await getApplicationDocumentsDirectory();
      isar= await Isar.open([WordSchema], directory: directory.path);

    }
    catch(e){
        debugPrint('init fail');
    }
  }
  Future <void> saveWord(Word word) async {
    try{
        isar.writeTxn(()
        async{
            final id =await isar.words.put(word);
            
        });
    }
    catch(e){
        debugPrint("hata");
    }
  }

  Future <List<Word>> getAllWords() async{
      try{
        final words=await isar.words.where().findAll();
        return words;
      }
      catch(e){
        debugPrint('Hata getAllWords');
        return [];
      }
  }

   Future <void> deleteWord(int id ) async {
    try{
        isar.writeTxn(()
        async{
            final result =await isar.words.delete(id);
            
        });
    }
    catch(e){
        debugPrint("Hata");
    }
  }

  Future <void> updateWord(Word word ) async {
    try{
        isar.writeTxn(()
        async{
            final result =await isar.words.put(word);
            
        });
    }
    catch(e){
        debugPrint("hata");
    }
  }

  Future <void> toggleWord(int id)async{
    try{
       await isar.writeTxn(()async{
          final word= await isar.words.get(id);
          if(word!=null){
            word.isLearned=!word.isLearned;
            await isar.words.put(word);
          }
       });
    }
    catch(e){
        debugPrint("Hata");
    }
  }


}