import 'package:flutter/material.dart';
import 'package:getFit/routes/register1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'getFit',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Register1(),
    );
  }
}

