// ──────────────────────────────────────────────────────────────
// lib/routes/add_exercise_screen.dart
// ──────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseSet {
  final int repetitions;
  final String? weight;
  ExerciseSet({required this.repetitions, this.weight});
  Map<String, dynamic> toMap() =>
      {'repetitions': repetitions, 'weight': weight ?? ''};
}

class _ExerciseEntry {
  final String name;
  final List<ExerciseSet> sets;
  final String comments;
  _ExerciseEntry(
      {required this.name, required this.sets, required this.comments});
  Map<String, dynamic> toMap() => {
    'name': name,
    'sets': sets.map((s) => s.toMap()).toList(),
    'comments': comments
  };
}

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});
  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  // ────────── Workout düzeyi ──────────
  final _workoutNameController = TextEditingController();
  final List<_ExerciseEntry> _workoutExercises = [];

  // ────────── Egzersiz düzeyi ─────────
  String? _selectedExercise;
  int _selectedSetCount = 1;
  final _repetitionsController = TextEditingController();
  final _weightController = TextEditingController();
  final _commentsController = TextEditingController();
  final List<ExerciseSet> _currentSets = [];

  // ────────── Firebase ──────────
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;   //  ← kırmızı çizgi sorunu giderildi
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Statik egzersiz havuzu
  final Map<String, String> _exerciseList = {
    'Plank': 'Keep your body in a straight line from shoulders to feet while resting on your forearms and toes.',
    'Sit Ups': 'Lie on your back with knees bent. Use your abdominal muscles to lift your upper body toward your knees.',
    'Russian Twists': 'Sit with your legs raised and torso leaned back. Twist your upper body to each side, touching the floor beside you.',
    'Bicycle Crunches': 'Lie on your back and alternate bringing opposite elbow and knee together, simulating a pedaling motion.',
    'Leg Raises': 'Lie on your back and lift both legs up toward the ceiling, then lower them back down without touching the ground.',
    'Mountain Climbers': 'In a plank position, drive your knees toward your chest one at a time as fast as you can.',
    'Jumping Jacks': 'Jump while spreading your legs and raising your arms overhead, then return to the starting position.',
    'Push Ups': 'Keep your body straight, lower yourself by bending your elbows, then push back up to the starting position.',
    'Squats': 'Stand with your feet shoulder-width apart, push your hips back and lower your body into a squat, then rise back up.',
    'Lunges': 'Step forward with one foot and lower your body until both knees are bent, then return to the starting position.',
    'High Knees': 'Jog in place while lifting your knees up toward your chest as high as you can.',
    'Burpees': 'Stand with your feet shoulder-width apart, squat down, jump back into plank, then jump forward and up.',
    'Deadlift': 'With feet shoulder-width apart, hinge at the hips to lower your torso, then stand back up by squeezing your glutes.',
    'Calf Raises': 'Stand tall and lift your heels to rise onto your toes, then lower back down slowly.',
    'Glute Bridge': 'Lie on your back with knees bent and lift your hips by squeezing your glutes, then lower down slowly.',
    'Pull Up': 'Strengthens your back and biceps.',
    'Overhead Press': 'Strengthens shoulders and triceps.',
    'Lat Pulldown': 'Targets your back and lats.',
    'Bicep Curl': 'Isolates the bicep muscle.',
    'Tricep Extension': 'Focuses on your triceps.',
    'Bench Press': 'Great for building chest strength.',
    'Romanian Deadlift': 'Focuses on hamstrings and glutes.',
    'Leg Extension': 'Builds quadriceps strength.',
    'Leg Curl': 'Strengthens hamstrings.',
    'Step Ups': 'Step onto a platform with one foot, push yourself up, then step back down and switch legs.',
    'Dips': 'Lower your body by bending your arms, then push back up to strengthen your triceps and chest.',
    'Jump Squats': 'Squat down and jump explosively, landing softly and repeating.',
    'Side Plank': 'Hold your body on one side, supporting your weight on one arm while keeping your body straight.',
    'Box Jump': 'Jump onto a sturdy platform, stand up straight, and then jump back down.',
    'Farmers Walk': 'Hold heavy weights in each hand and walk in a straight line, keeping your back straight.'
  };

  // ────────── Yardımcılar ──────────
  void _addSet() {
    final reps = int.tryParse(_repetitionsController.text);
    if (_selectedExercise == null) {
      _snack('Select an exercise'); return;
    }
    if (reps == null || reps <= 0) {
      _snack('Positive repetition count required'); return;
    }
    setState(() {
      for (int i = 0; i < _selectedSetCount; i++) {
        _currentSets.add(ExerciseSet(
            repetitions: reps,
            weight: _weightController.text.isNotEmpty
                ? _weightController.text
                : null));
      }
      _repetitionsController.clear();
      _weightController.clear();
    });
  }

  void _commitExercise() {
    if (_selectedExercise == null) { _snack('Select an exercise'); return; }
    if (_currentSets.isEmpty) { _snack('Add at least one set'); return; }

    setState(() {
      _workoutExercises.add(_ExerciseEntry(
        name: _selectedExercise!,
        sets: List.from(_currentSets),
        comments: _commentsController.text.trim(),
      ));
      _selectedExercise = null;
      _currentSets.clear();
      _commentsController.clear();
    });
  }

  Future<void> _saveWorkout() async {
    final name = _workoutNameController.text.trim();
    if (name.isEmpty) { _snack('Workout name required'); return; }
    if (_workoutExercises.isEmpty) { _snack('Add at least one exercise'); return; }

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workoutPrograms')
        .add({
      'workoutName': name,
      'exercises': _workoutExercises.map((e) => e.toMap()).toList(),
      'completed': false,
      'createdAt': DateTime.now(),
    });

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ────────── UI ──────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Workout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _workoutNameController,
            decoration: const InputDecoration(labelText: 'Workout Name'),
          ),
          const Divider(height: 32),
          DropdownButtonFormField<String>(
              value: _selectedExercise,
              hint: const Text('Select exercise'),
              items: _exerciseList.keys
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedExercise = v)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _repetitionsController,
            decoration: const InputDecoration(labelText: 'Repetitions'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
              value: _selectedSetCount,
              decoration: const InputDecoration(labelText: 'Set count'),
              items: List.generate(
                  15, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSetCount = v ?? 1)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Weight (kg, optional)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentsController,
            decoration: const InputDecoration(labelText: 'Comments (optional)'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set(s)')),
          ElevatedButton.icon(
              onPressed: _commitExercise,
              icon: const Icon(Icons.fitness_center),
              label: const Text('Add Exercise to Workout')),
          const SizedBox(height: 24),
          if (_workoutExercises.isNotEmpty) ...[
            const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._workoutExercises.map((e) => ListTile(
              title: Text(e.name),
              subtitle: Text('${e.sets.length} set(s) • '
                  '${e.comments.isEmpty ? 'No comment' : e.comments}'),
              trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(
                          () => _workoutExercises.removeWhere((ex) => ex == e))),
            ))
          ],
          const SizedBox(height: 24),
          Center(
              child: ElevatedButton(
                  onPressed: _saveWorkout, child: const Text('Save Workout')))
        ]),
      ),
    );
  }
}