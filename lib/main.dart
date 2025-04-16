import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'get_ready.dart';
import 'exercise_done.dart';
import 'exercise_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'getFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'CustomFont', // only if defined in pubspec.yaml
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/getReady': (context) => GetReadyScreen(),
        '/exerciseDone': (context) => ExerciseDoneScreen(),
        '/exerciseInfo': (context) => ExerciseInfoScreen(),
      },
    );
  }
}
