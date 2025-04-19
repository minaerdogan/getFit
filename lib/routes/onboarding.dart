import 'package:flutter/material.dart';
import 'package:proje/routes/login.dart';
import '../utils/textstyles.dart';
import '../utils/colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 300,
                child: Image.asset(
                  'assets/WhatsApp Image 2025-04-16 at 22.06.53.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Text('getFit', style: AppTextStyles.header),
              Text('Everybody Can Train', style: AppTextStyles.regular),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.classicButtonColor,
                ),
                child: Text('Get Started', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
