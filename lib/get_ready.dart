import 'package:flutter/material.dart';

class GetReadyScreen extends StatelessWidget {
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
                  'assets/get_ready_graphic.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40),
              Text('Welcome, Stefani', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text('You are all set now, let’s reach your goals together with us',
                  textAlign: TextAlign.center),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                child: Text('Go To Home'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
