import 'package:flutter/material.dart';
import '../screens/workout_details_page.dart';
import '../data/lower_body_exercises.dart';

class LowerBodyPage extends StatelessWidget {
  const LowerBodyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutDetailsPage(
      workoutTitle: 'Lower Body',
      exercises: lowerBodyExercises,
    );
  }
}
