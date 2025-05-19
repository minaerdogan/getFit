import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding

class WorkoutDetails2Screen extends StatefulWidget {
  // Now only requires the exerciseName to fetch details from Firestore
  final String exerciseName;

  const WorkoutDetails2Screen({
    super.key,
    required this.exerciseName,
  });

  @override
  State<WorkoutDetails2Screen> createState() => _WorkoutDetails2ScreenState();
}

class _WorkoutDetails2ScreenState extends State<WorkoutDetails2Screen> {
  String _exerciseDescription = 'Loading description...'; // State variable for description
  String _exerciseImage = 'assets/placeholder_exercise.png'; // State variable for image path (using placeholder)
  bool _isLoadingDetails = true; // Loading state for fetching details
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchExerciseDetails(); // Fetch details when the screen initializes
  }

  // *** Function to fetch exercise details from the top-level 'workouts' collection ***
  Future<void> _fetchExerciseDetails() async {
    try {
      // Query the 'workouts' collection where workout_name matches the exerciseName
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('workout_name', isEqualTo: widget.exerciseName)
          .limit(1) // Assuming workout_name is unique or you only need one match
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          // Assuming 'description' field exists in your workouts collection
          _exerciseDescription = data['description'] as String? ?? 'No description available.';
          // Assuming 'assetPath' or similar field exists for image path (adjust field name if needed)
          // If your workouts collection doesn't store image paths, you'll need a different strategy
          _exerciseImage = data['assetPath'] as String? ?? 'assets/placeholder_exercise.png'; // Use fetched path or placeholder
          _isLoadingDetails = false; // Stop loading
        });
        print('Fetched details for exercise: ${widget.exerciseName}');

      } else {
        setState(() {
          _exerciseDescription = 'Exercise details not found.';
          _exerciseImage = 'assets/placeholder_exercise.png'; // Keep placeholder
          _isLoadingDetails = false; // Stop loading
        });
        print('Exercise "${widget.exerciseName}" not found in workouts collection.');
        if(mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exercise details not found.'), backgroundColor: Colors.orange),
            );
          });
        }
      }

    } catch (e) {
      print('Error fetching exercise details: $e');
      setState(() {
        _exerciseDescription = 'Error loading details.';
        _exerciseImage = 'assets/placeholder_exercise.png'; // Keep placeholder
        _isLoadingDetails = false; // Stop loading
      });
      if(mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading details: ${e.toString()}'), backgroundColor: Colors.red),
          );
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
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
      body: _isLoadingDetails // Show loading indicator while fetching
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          // Image section - use fetched image path
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            child: Image.asset( // Assuming image paths are local assets
              _exerciseImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset( // Fallback to placeholder on error
                  'assets/placeholder_exercise.png',
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Details section
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
                    // Display fetched exercise name (from argument)
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Display fetched exercise description
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
