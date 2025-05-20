import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:proje/routes/login.dart';
import 'package:proje/routes/addExercise.dart';
import 'package:proje/routes/saveWorkout.dart';
import 'package:proje/routes/onboarding.dart';
import 'package:proje/routes/register1.dart';
import 'package:proje/routes/personal_info_page.dart';
import 'package:proje/routes/get_ready.dart';
import 'package:proje/routes/home_screen.dart';
import 'package:proje/routes/my_account.dart';
import 'package:proje/routes/exercise_done.dart';
import 'package:proje/routes/workout_details_page.dart';


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Import the generated Firebase options file
import 'firebase_options.dart'; // Make sure this file exists

// ... other imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/saveWorkout': (context) => const AddWorkoutScheduleScreen(),
        '/addExercise': (context) => const AddExerciseScreen(),
        '/register': (context) => const Register1(),
        '/personal_info_page': (context) => const PersonalInfoPage(),
        '/get_ready': (context) => const GetReadyScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/my_account': (context) => const MyAccountPage(),
        '/exercise_done': (context) => const ExerciseDoneScreen(),
        '/workout_details_page': (context) => const WorkoutDetailsPage(),
      },
    );
  }
}