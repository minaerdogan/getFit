import 'package:flutter/material.dart';

class ExerciseInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Info')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Text(
                    'Exercise Image\n(placeholder)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text('Exercise Name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Description:\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  textAlign: TextAlign.left),
              SizedBox(height: 12),
              Text('How to do it:\n\n1. Step one\n2. Step two\n3. Step three',
                  textAlign: TextAlign.left),
            ],
          ),
        ),
      ),
    );
  }
}
