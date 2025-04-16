import 'package:flutter/material.dart';
import 'package:proje/routes/login.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
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
                  'assets/WhatsApp Image 2025-04-16 at 22.06.53.jpeg',
                  fit: BoxFit.contain,
                )
              ),
              SizedBox(height: 40),
              Text('getFit', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('Everybody Can Train', style: TextStyle(fontSize: 18)),
              SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Get Started'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
