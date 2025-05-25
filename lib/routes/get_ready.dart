import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- ADDED: Import Provider
import 'package:proje/utils/colors.dart'; // Assuming this is correctly set up

// <--- ADDED: Import your new UserProfileProvider --->
import '../providers/get_ready_provider.dart';

class GetReadyScreen extends StatelessWidget { // <--- IMPORTANT: CHANGED from StatefulWidget to StatelessWidget
  const GetReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // <--- ADDED: Use context.watch to listen to UserProfileProvider --->
    // This makes the widget rebuild automatically when the provider's data changes.
    final userProfileProvider = context.watch<UserProfileProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: userProfileProvider.isLoading // <--- Use isLoading from the provider --->
              ? const Center(child: CircularProgressIndicator()) // Show loading indicator
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Image.asset(
                  'assets/get_ready_graphic.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(height: 40),
              // <--- CHANGED: Display the user name from the provider --->
              Text(
                'Welcome, ${userProfileProvider.userName}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
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