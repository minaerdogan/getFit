import 'package:flutter/material.dart';
import '../routes/workout_details_page.dart';
import '../data/abs_exercises.dart';

class AbsPage extends StatelessWidget {
  const AbsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkoutDetailsPage(
      workoutTitle: 'Abs',
      exercises: absExercises,
    );
  }
}
