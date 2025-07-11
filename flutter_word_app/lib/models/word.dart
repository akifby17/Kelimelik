
import 'package:isar/isar.dart';

part 'word.g.dart';
@collection
class Word {
  Id id=Isar.autoIncrement;
  late String englishWord;
  late String turkishWord;
  late String wordType;
  String? story;
  List<int>? imageByte;
  bool isLearned=false;
  DateTime createdAt=DateTime.now();

  Word({
    required this.englishWord,
    required this.turkishWord,
    required this.wordType,
    this.story,
    this.imageByte,
  });
}
