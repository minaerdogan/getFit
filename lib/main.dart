import 'package:flutter/material.dart';
import 'package:untitled3/pages/abs_page.dart';
import '../pages/full_body_page.dart'; // Diğerleri: lower_body_page.dart, abs_page.dart

void main() => runApp(const GetFitApp());

class GetFitApp extends StatelessWidget {
  const GetFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetFit',
      debugShowCheckedModeBanner: false,
      home: const AbsPage(),
    );
  }
}