import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import '../utils/exercise_images.dart'; // Asset map import

class WorkoutDetails2Screen extends StatefulWidget {
  final String exerciseName;

  const WorkoutDetails2Screen({
    super.key,
    required this.exerciseName,
  });

  @override
  State<WorkoutDetails2Screen> createState() => _WorkoutDetails2ScreenState();
}

class _WorkoutDetails2ScreenState extends State<WorkoutDetails2Screen> {
  String _exerciseDescription = 'Loading description...';
  bool _isLoadingDetails = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchExerciseDetails();
  }

  Future<void> _fetchExerciseDetails() async {
    try {
      final querySnapshot = await _firestore
          .collection('workouts')
          .where('workout_name', isEqualTo: widget.exerciseName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _exerciseDescription = data['description'] as String? ?? 'No description available.';
          _isLoadingDetails = false;
        });
      } else {
        setState(() {
          _exerciseDescription = 'Exercise details not found.';
          _isLoadingDetails = false;
        });
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Exercise details not found.'),
                backgroundColor: Colors.orange,
              ),
            );
          });
        }
      }
    } catch (e) {
      setState(() {
        _exerciseDescription = 'Error loading details.';
        _isLoadingDetails = false;
      });
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading details: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = exerciseImageMap[widget.exerciseName]; // Map'ten asset yolu al

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _isLoadingDetails
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          // Görsel bölümü
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: imagePath != null
                ? Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(
                    'assets/placeholder_exercise.png',
                    fit: BoxFit.cover,
                  ),
            )
                : Image.asset(
              'assets/placeholder_exercise.png',
              fit: BoxFit.cover,
            ),
          ),

          // Açıklama bölümü
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _exerciseDescription,
                          style: const TextStyle(fontSize: 16, height: 1.5),
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
    );
  }
}
