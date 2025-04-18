// --- add_exercise_screen.dart ---
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Model for the data returned by this screen
class AddedExerciseData {
  final String name;
  final List<ExerciseSet> sets;
  final String? weight; // Make weight nullable as it's optional
  final String comments;

  AddedExerciseData({
    required this.name,
    required this.sets,
    this.weight,
    required this.comments,
  });
}

// Keep the ExerciseSet class as before, but now it can hold weight
class ExerciseSet {
  final int repetitions;
  final String? weight; // Weight for this specific set (optional)

  ExerciseSet({required this.repetitions, this.weight});
}

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  String? _selectedExercise;
  final _repetitionsController = TextEditingController();
  final _weightController = TextEditingController();
  final _commentsController = TextEditingController();
  final List<ExerciseSet> _sets = [];
  final List<String> _exerciseList = [
    'Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Pull Ups',
    'Warm Up', 'Jumping Jack', 'Skipping', // Added examples from other screen
  ];

  void _addSet() {
    if (_selectedExercise == null || _selectedExercise!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an exercise first')),
      );
      return;
    }
    final reps = int.tryParse(_repetitionsController.text);
    final currentWeight = _weightController.text.trim();

    if (reps != null && reps > 0) {
      setState(() {
        _sets.add(ExerciseSet(repetitions: reps, weight: currentWeight.isNotEmpty ? currentWeight : null));
        _repetitionsController.clear();
        // Optionally clear the weight after adding to a set,
        // or keep it if the user is likely to use the same weight for the next set.
        // _weightController.clear();
      });
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid, positive repetitions')),
      );
    }
  }

  void _deleteSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  void _saveExercise() {
    final exercise = _selectedExercise;
    final globalWeightString = _weightController.text.trim();
    final comments = _commentsController.text.trim();

    if (exercise == null || exercise.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an exercise')),
      );
      return;
    }
    if (_sets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one set')),
      );
      return;
    }

    final resultData = AddedExerciseData(
      name: exercise,
      sets: List.from(_sets),
      weight: globalWeightString.isNotEmpty ? globalWeightString : null,
      comments: comments,
    );

    Navigator.pop(context, resultData);
  }

  @override
  void dispose() {
    _repetitionsController.dispose();
    _weightController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isExerciseDropdownEnabled = _sets.isEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Custom Exercise', style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding( // Removed SingleChildScrollView here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedExercise,
              hint: Text('Choose Exercise', style: TextStyle(color: isExerciseDropdownEnabled ? Colors.grey.shade700 : Colors.grey.shade400)),
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                fillColor: isExerciseDropdownEnabled ? Colors.white : Colors.grey.shade200,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              items: _exerciseList.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: isExerciseDropdownEnabled ? (String? newValue) => setState(() => _selectedExercise = newValue) : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _repetitionsController,
              decoration: InputDecoration(labelText: 'Enter repetitions', hintText: 'e.g., 12', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addSet,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), padding: const EdgeInsets.symmetric(vertical: 12.0)),
                child: const Text('Add a set'),
              ),
            ),
            const SizedBox(height: 25),
            Expanded( // Use Expanded to make the ListView take available vertical space
              child: ListView.builder(
                shrinkWrap: true, // Important for working inside Column & Expanded
                physics: const ClampingScrollPhysics(),
                itemCount: _sets.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Set ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${_sets[index].repetitions} repetition${_sets[index].repetitions == 1 ? '' : 's'}'),
                            if (_sets[index].weight != null && _sets[index].weight!.isNotEmpty)
                              Text('${_sets[index].weight} KG', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
                          onPressed: () => _deleteSet(index),
                          tooltip: 'Delete Set',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_sets.isNotEmpty) const Divider(height: 30, thickness: 1),
            const Text('Add your weight (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _weightController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(hintText: 'e.g., 20', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), contentPadding: const EdgeInsets.symmetric(vertical: 8.0)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]?\d{0,2})'))],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('KG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Your comments (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _commentsController,
              decoration: InputDecoration(hintText: 'e.g., Focus on form', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0)),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                child: const Text('Save Exercise', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}