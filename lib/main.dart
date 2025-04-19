import 'package:flutter/material.dart';
import 'package:proje/routes/login.dart'; // Import your screen files
import 'package:proje/routes/addExercise.dart'; // Import your screen files
import 'package:proje/routes/saveWorkout.dart'; // Import your screen files
import 'package:proje/routes/onboarding.dart'; // Import your screen files
import 'package:proje/routes/register1.dart';// Import the register screen file
import 'package:proje/routes/personal_info_page.dart';
import 'package:proje/routes/get_ready.dart';
import 'package:proje/routes/home_screen.dart';
import 'package:proje/routes/my_account.dart';
import 'package:proje/routes/exercise_done.dart';
import 'package:proje/routes/workout_details_page.dart';
import 'package:proje/routes/abs_page.dart';
import 'package:proje/routes/full_body_page.dart';
import 'package:proje/routes/lower_body_page.dart';


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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/onboarding', // Set the initial route
      routes: {
        '/onboarding': (context) => const OnboardingScreen(), // Define named routes
        '/login': (context) => const LoginScreen(),
        '/saveWorkout': (context) => const AddWorkoutScheduleScreen(),
        '/addExercise': (context) => const AddExerciseScreen(),
        '/register': (context) => const Register1(), // Define register route
        '/personal_info_page': (context) => const PersonalInfoPage(),
        '/get_ready': (context) => const GetReadyScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/my_account': (context) => const MyAccountPage(),
        '/exercise_done':(context) => const ExerciseDoneScreen(),
        '/workout_details_page':(context) => const WorkoutDetailsPage(workoutTitle: '', exercises: []),
        '/abs_page':(context) => const AbsPage(),
        '/full_body_page' :(context) => const FullBodyPage(),
        '/lower_body_page': (context) => const LowerBodyPage(),
      },
    );
  }
}
