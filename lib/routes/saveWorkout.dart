import 'package:flutter/material.dart';
import 'package:proje/routes/addExercise.dart';

class AddWorkoutScheduleScreen extends StatefulWidget {
  const AddWorkoutScheduleScreen({super.key});

  @override
  State<AddWorkoutScheduleScreen> createState() => _AddWorkoutScheduleScreenState();
}

class _AddWorkoutScheduleScreenState extends State<AddWorkoutScheduleScreen> {
  final List<AddedExerciseData> _customExercises = [];



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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // --- Updated Leading Button ---
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          tooltip: 'Back to Home', // Added tooltip
          onPressed: () {
            // This should lead back to the home page IF this screen
            // was pushed from a home page.
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Handle case where it cannot pop (e.g., it's the first screen)
              // Maybe SystemNavigator.pop(); or navigate to a specific home route
              print("Cannot pop, maybe implement exit or specific navigation");
            }
          },
        ),
        title: const Text(
          'Add Schedule',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // --- Updated Actions Button (3 dots) ---
        actions: [
          // Only show the delete all button if there are exercises
          if (_customExercises.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54), // Vertical dots icon
              tooltip: 'More Options',
              onSelected: (String result) {
                switch (result) {
                  case 'deleteAll':
                    _confirmDeleteAll(); // Call the confirmation function
                    break;
                // Add other cases if more options are added later
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'deleteAll',
                  child: ListTile( // Use ListTile for icon + text
                    leading: Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
                    title: Text('Delete All Exercises', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
                // Add more PopupMenuItems here for other options if needed
              ],
            )
          else
            const SizedBox(width: 48), // Placeholder to keep spacing consistent when button is hidden

        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Details Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            _buildDetailRow(
              icon: Icons.list_alt, title: 'Choose Workout', subtitle: 'Upperbody Workout >',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Choose Workout: Not implemented yet')));
              },
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.fitness_center, title: 'Custom Workout',
              onTap: () {
                Navigator.of(context).pushNamed('/addExercise').then((result) {
                  if (result is AddedExerciseData) {
                    setState(() {
                      _customExercises.add(result);
                    });
                  }
                });
              }, // Navigates to add exercise screen
            ),
            const SizedBox(height: 30),
            Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Exercises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('${_customExercises.length} Exercise${_customExercises.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 14, color: Colors.grey)), // Updated label
            ],),
            const SizedBox(height: 15),

            // --- List of Added Custom Exercises (Updated) ---
            Expanded(
              child: _customExercises.isEmpty
                  ? const Center( child: Text( 'No custom exercises added yet.\nTap "Custom Workout" to add.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),)
                  : ListView.builder(
                itemCount: _customExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _customExercises[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                    child: ListTile(
                      leading: const CircleAvatar( backgroundColor: Colors.grey, child: Icon(Icons.image_outlined, color: Colors.white)),
                      title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(_formatSetInfo(exercise.sets)),
                      // --- Updated Trailing: Delete Button ---
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.8)),
                        tooltip: 'Delete ${exercise.name}',
                        onPressed: () => _deleteExercise(index), // Call delete function
                      ),
                      // --- Updated onTap: Show Details ---
                      onTap: () => _showExerciseDetails(exercise), // Call show details function
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Final Save Button (for the whole schedule) ---
            SizedBox( width: double.infinity, child: ElevatedButton(
              onPressed: () {
                print('Saving entire workout schedule...');
                print('Custom Exercises Added: ${_customExercises.length}');
                for (var ex in _customExercises) { print('  - ${ex.name} (${_formatSetInfo(ex.sets)}) Weight: ${ex.weight} Comments: ${ex.comments}'); } // Log more details
                ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Workout Schedule Save: Not fully implemented')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade300.withOpacity(0.8), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), elevation: 0),
              child: const Text('Save Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), // Updated Button Text
            ),),
          ],
        ),
      ),
    );
  }

  // Helper widget (keep as before)
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
          if (subtitle == null) const Icon(Icons.chevron_right, color: Colors.grey),
        ],),
      ),
    );
  }
}
