import 'package:flutter/material.dart';
import '../routes/workout_details_page.dart';
import '../data/full_body_exercises.dart';

class FullBodyPage extends StatelessWidget {
  const FullBodyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutDetailsPage(
      workoutTitle: 'Full Body',
      exercises: fullBodyExercises,
    );
  }
}
