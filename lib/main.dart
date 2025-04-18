import 'package:flutter/material.dart';
import 'personal_info_page.dart';

void main() {
  runApp(const GetFitApp());
}

class GetFitApp extends StatelessWidget {
  const GetFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetFit',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF7C83FD),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const PersonalInfoPage(),
    );
  }
}
