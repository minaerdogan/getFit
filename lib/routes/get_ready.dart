import 'package:flutter/material.dart';
import 'package:proje/utils/colors.dart'; // Assuming your utils folder is in the root

class GetReadyScreen extends StatelessWidget {
  const GetReadyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Image.asset(
                  'assets/get_ready_graphic.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              const Text('Welcome, Stefani', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text(
                'You are all set now, let’s reach your goals together with us',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home_screen'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.classicButtonColor, // Using the color from your utils class
                  foregroundColor: Colors.white, // Optional: Set text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
                  ),
                ),
                child: const Text('Go To Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}