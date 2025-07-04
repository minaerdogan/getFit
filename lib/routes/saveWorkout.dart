import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

// Assuming AddedExerciseData and ExerciseSet are defined in addExercise.dart
import 'package:proje/routes/addExercise.dart';

class AddWorkoutScheduleScreen extends StatefulWidget {
  const AddWorkoutScheduleScreen({super.key});

  @override
  State<AddWorkoutScheduleScreen> createState() => _AddWorkoutScheduleScreenState();
}

class _AddWorkoutScheduleScreenState extends State<AddWorkoutScheduleScreen> {
  final List<AddedExerciseData> _customExercises = [];
  final TextEditingController _workoutNameController = TextEditingController();

  bool _isSaving = false; // Loading state for saving
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  // Show details of a specific exercise
  void _showExerciseDetails(AddedExerciseData exercise) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(exercise.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  _formatSetInfo(exercise.sets),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                const Text('Sets:', style: TextStyle(fontWeight: FontWeight.w500)),
                if (exercise.sets.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: exercise.sets.map((set) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${set.repetitions} reps${set.weight != null && set.weight!.isNotEmpty ? ' at ${set.weight} KG' : ''}',
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Text('No sets added.'),
                const SizedBox(height: 10),
                const Text('Comments:', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(exercise.comments.isEmpty ? "None" : exercise.comments),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Delete a single exercise with confirmation
  void _deleteExercise(int index) {
    if (index < 0 || index >= _customExercises.length) return; // Bounds check
    final exerciseToDelete = _customExercises[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${exerciseToDelete.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _customExercises.removeAt(index); // Perform deletion
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${exerciseToDelete.name}" deleted.'), duration: const Duration(seconds: 2)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Confirm and delete all exercises
  void _confirmDeleteAll() {
    if (_customExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercises to delete.'), duration: Duration(seconds: 2)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete All'),
          content: const Text('Are you sure you want to delete all exercises in this schedule? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete All', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                setState(() {
                  _customExercises.clear(); // Clear the list
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All exercises deleted.'), duration: Duration(seconds: 2)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- Formatting ---
  String _formatSetInfo(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 'No sets added';
    return '${sets.length} Set${sets.length == 1 ? '' : 's'}';
  }

  // *** Function to save the workout schedule to Firestore ***
  Future<void> _saveWorkoutSchedule() async {
    if (_isSaving) return; // Prevent multiple saves

    final workoutName = _workoutNameController.text.trim();

    if (workoutName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the workout schedule.')),
      );
      return;
    }

    if (_customExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise to save the schedule.')),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No user logged in to save the workout.')),
      );
      print('Error: No user logged in.');
      return;
    }

    setState(() {
      _isSaving = true; // Start saving state
    });

    try {
      // Get the user's document reference
      DocumentReference userDocRef = _firestore.collection('users').doc(currentUser!.uid);

      // Create a new document in the 'workouts' subcollection
      // Firestore will auto-generate a unique ID for this workout document
      await userDocRef.collection('workoutPrograms').add({
        'workoutName': workoutName,
        'createdAt': FieldValue.serverTimestamp(), // Add a timestamp
        'exercises': _customExercises.map((exercise) {
          // Convert AddedExerciseData to a Map for Firestore
          return {
            'name': exercise.name,
            'weight': exercise.weight,
            'comments': exercise.comments,
            'sets': exercise.sets.map((set) {
              // Convert ExerciseSet to a Map
              return {
                'repetitions': set.repetitions,
                'weight': set.weight, // Weight per set
              };
            }).toList(),
          };
        }).toList(),
      });

      print('Workout schedule "$workoutName" saved to Firestore for user ${currentUser!.uid}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workout schedule "$workoutName" saved successfully!')),
        );
        // Optionally navigate back after saving
        Navigator.pop(context);
      }

    } catch (e) {
      print('Error saving workout schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout schedule: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // Stop saving state
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              print("Cannot pop, maybe implement exit or specific navigation");
            }
          },
        ),
        title: const Text(
          'Add Schedule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Only show the delete all button if there are exercises
          if (_customExercises.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              tooltip: 'More Options',
              onSelected: (String result) {
                switch (result) {
                  case 'deleteAll':
                    _confirmDeleteAll();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'deleteAll',
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                    title: Text('Delete All Exercises', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 48), // Keep spacing consistent
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text field for workout name
            const Text('Workout Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextField(
              controller: _workoutNameController,
              decoration: InputDecoration(
                hintText: 'Enter name for this workout schedule',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              ),
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 15),

            _buildDetailRow(
              icon: Icons.fitness_center,
              title: 'Add Custom Exercise',
              onTap: () {
                Navigator.of(context).pushNamed('/addExercise').then((result) {
                  if (result is AddedExerciseData) {
                    setState(() {
                      _customExercises.add(result);
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exercises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('${_customExercises.length} Exercise${_customExercises.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 15),

            // --- List of Added Custom Exercises ---
            Expanded(
              child: _customExercises.isEmpty
                  ? const Center(
                child: Text(
                  'No custom exercises added yet.\nTap "Add Custom Exercise" to add.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _customExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _customExercises[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: ListTile(
                      leading: const CircleAvatar(
                          backgroundColor: Colors.grey, child: Icon(Icons.image_outlined, color: Colors.white)),
                      title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(_formatSetInfo(exercise.sets)),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.8)),
                        tooltip: 'Delete ${exercise.name}',
                        onPressed: () => _deleteExercise(index),
                      ),
                      onTap: () => _showExerciseDetails(exercise),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Save Schedule Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveWorkoutSchedule, // Disable button when saving
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade300.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
                    : const Text('Save Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget (keep as before) - Used for "Add Custom Exercise" button
  Widget _buildDetailRow({ required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration( color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10.0)),
        child: Row( children: [
          Icon(icon, color: Colors.deepPurple.shade300),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right, color: Colors.grey), // Always show arrow for this row
        ],),
      ),
    );
  }
}
