import 'package:flutter/material.dart';
import 'package:flutter_word_app/pages/main_page.dart';
import 'package:flutter_word_app/services/isar_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final IsarService isarService=IsarService();
  try{
    await isarService.init();
  }
  catch(e){
    debugPrint('hata');
  }
  runApp(MyApp(isarService: isarService));
}
class MyApp extends StatelessWidget {
  final IsarService isarService;
  const MyApp({super.key,required this.isarService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Word App',
      theme:ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true
      ),
      home:MainPage(isarService: isarService),

    );
  }
}