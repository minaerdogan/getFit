import 'package:flutter/material.dart';
import 'package:proje/routes/login.dart'; // Import your screen files
import 'package:proje/routes/addExercise.dart'; // Import your screen files
import 'package:proje/routes/saveWorkout.dart'; // Import your screen files
import 'package:proje/routes/onboarding.dart'; // Import your screen files
// import 'package:proje/routes/register.dart'; // Import the register screen file


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
      initialRoute: '/onboarding', // Set the initial route
      routes: {
        '/onboarding': (context) => const OnboardingScreen(), // Define named routes
        '/login': (context) => const LoginScreen(),
        '/saveWorkout': (context) => const AddWorkoutScheduleScreen(),
        '/addExercise': (context) => const AddExerciseScreen(),
        // '/register': (context) => const RegisterScreen(), // Define register route
      },
    );
  }
}
