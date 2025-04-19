import 'package:flutter/material.dart';
import 'exercise_done.dart';
import 'workout_details2_screen.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final String workoutTitle;
  final List<Map<String, dynamic>> exercises;

  const WorkoutDetailsPage({
    super.key,
    required this.workoutTitle,
    required this.exercises,
  });

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  bool started = false;

  void _handleBackButton(BuildContext context) {
    final bool allCompleted = widget.exercises.every((e) => e['completed'] == true);

    if (!allCompleted && started) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Are you sure you want to exit? You have not finished your workout.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Don't exit
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit
                child: const Text('Exit'),
              ),
            ],
          );
        },
      ).then((shouldPop) {
        if (shouldPop == true) {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context); // If workout is finished or not started, just pop
    }
  }

  void _resetAll() {
    setState(() {
      started = false;
      for (var ex in widget.exercises) {
        ex['completed'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 260,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A7BD5), Color(0xFF00d2ff)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Image.network(
                      'https://assets.roguefitness.com/f_auto,q_auto,c_limit,w_1536,b_rgb:f8f8f8/catalog/Conditioning/Strength%20Equipment/Dumbbells/XX7125/XX7125-WEB3_rglczm.png',
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.fitHeight,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                      },
                    )

                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
                      onPressed: () {
                        _handleBackButton(context); // Call a new function
                      },
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -3))],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.workoutTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Exercise List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.exercises.length,
                          itemBuilder: (context, i) {
                            final ex = widget.exercises[i];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(ex['assetPath']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ex['name'],
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye_outlined, size: 22, color: Colors.grey),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WorkoutDetails2Screen(
                                          exerciseName: ex['name'],
                                          exerciseImage: ex['assetPath'],
                                          exerciseDescription: ex['description'],
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: ex['completed']
                                        ? const Icon(Icons.check_circle, size: 24, color: Colors.green)
                                        : const Icon(Icons.check_circle_outline, size: 24, color: Colors.grey),
                                    onPressed: started
                                        ? () {
                                      setState(() => ex['completed'] = !ex['completed']);
                                      if (widget.exercises.every((e) => e['completed'] == true)) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const ExerciseDoneScreen()),
                                        ).then((_) => _resetAll());
                                      }
                                    }
                                        : null,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Start Workout Butonu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A7BD5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: started ? null : () => setState(() => started = true),
                            child: Text(
                              started ? 'Workout Started' : 'Start Workout',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
