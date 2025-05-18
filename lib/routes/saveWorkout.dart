import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'addExercise.dart';

class SaveWorkoutScreen extends StatefulWidget {
  const SaveWorkoutScreen({super.key});
  @override
  State<SaveWorkoutScreen> createState() => _SaveWorkoutScreenState();
}

class _SaveWorkoutScreenState extends State<SaveWorkoutScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _workouts = [];
  final Map<String, bool> _expanded = {};           // workoutId -> expanded?
  final Map<String, Map<int, bool>> _progress = {}; // workoutId -> {exerciseIndex:done}

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workoutPrograms')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _workouts = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      for (var w in _workouts) {
        _expanded[w['id']] = false;
        _progress[w['id']] =
        {for (int i = 0; i < w['exercises'].length; i++) i: false};
      }
    });
  }

  void _toggleExpand(String id) =>
      setState(() => _expanded[id] = !_expanded[id]!);

  void _toggleExercise(String id, int idx) =>
      setState(() => _progress[id]![idx] = !_progress[id]![idx]!);

  bool _allDone(String id) =>
      _progress[id]!.values.every((element) => element);

  Future<void> _finishWorkout(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workoutPrograms')
        .doc(id)
        .update({'completed': true});
    _fetchWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Programs'),
        actions: [
          IconButton(
              onPressed: () async {
                final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddExerciseScreen()));
                if (res == true) _fetchWorkouts();
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: _workouts.isEmpty
          ? const Center(child: Text('No workouts yet'))
          : ListView.builder(
          itemCount: _workouts.length,
          itemBuilder: (_, i) {
            final w = _workouts[i];
            final wid = w['id'];
            final completed = w['completed'] as bool;
            final isOpen = _expanded[wid]!;
            return Card(
              margin: const EdgeInsets.all(8),
              child: Column(children: [
                ListTile(
                  title: Text(w['workoutName']),
                  subtitle: Text(completed ? 'Completed' : 'In progress'),
                  trailing: Icon(
                    completed
                        ? Icons.check_circle
                        : isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: completed ? Colors.green : Colors.blue,
                  ),
                  onTap: completed ? null : () => _toggleExpand(wid),
                ),
                if (isOpen && !completed)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 12),
                    child: Column(
                      children: [
                        ...List.generate(w['exercises'].length, (idx) {
                          final ex = w['exercises'][idx];
                          final done = _progress[wid]![idx]!;
                          return CheckboxListTile(
                            value: done,
                            title: Text(ex['name']),
                            subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  ...List.generate(ex['sets'].length, (j) {
                                    final s = ex['sets'][j];
                                    return Text(
                                        'Set ${j + 1}: ${s['repetitions']} reps ${s['weight']}');
                                  }),
                                  if (ex['comments'] != null &&
                                      (ex['comments'] as String)
                                          .isNotEmpty)
                                    Text('Comments: ${ex['comments']}',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic))
                                ]),
                            onChanged: (_) => _toggleExercise(wid, idx),
                          );
                        }),
                        const SizedBox(height: 8),
                        ElevatedButton(
                            onPressed: _allDone(wid)
                                ? () => _finishWorkout(wid)
                                : null,
                            child: const Text('Finish Workout'))
                      ],
                    ),
                  )
              ]),
            );
          }),
    );
  }
}