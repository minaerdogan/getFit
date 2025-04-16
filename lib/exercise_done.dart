import 'package:flutter/material.dart';

class ExerciseDoneScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                  child: Image.asset(
                    'assets/exercise_done.png',
                    fit: BoxFit.contain,
                  )
              ),
              SizedBox(height: 40),
              Text('Congratulations!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text('You’ve completed your workout.', textAlign: TextAlign.center),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                child: Text('Back to Home'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
