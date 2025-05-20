import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

// Import the Workout model from home_screen.dart if needed for type checking,
// but we'll primarily use the ID and name passed as arguments.
// import 'package:proje/routes/home_screen.dart';

import 'exercise_done.dart';
import 'workout_details2_screen.dart'; // Assuming this screen exists and accepts exercise details

// Define local data structures to manage the state of exercises and sets
// These mirror the structure saved in Firestore for a workout program
class DisplayExercise {
  final String name;
  final String? weight; // Global weight for the exercise (optional)
  final String comments; // Comments for the exercise (optional)
  final List<DisplaySet> sets;
  // Now calories are fetched from the top-level 'workouts' collection
  final double caloriesPerExercise; // Calories burned for completing ALL sets of this exercise

  // You might need exercise details like description and assetPath later
  // For now, we'll use placeholders or assume they are available elsewhere
  String? assetPath; // Placeholder for exercise image
  String? description; // Placeholder for exercise description

  DisplayExercise({
    required this.name,
    this.weight,
    required this.comments,
    required this.sets,
    required this.caloriesPerExercise, // Added calories
    this.assetPath,
    this.description,
  });
}

class DisplaySet {
  final int repetitions;
  final String? weight; // Weight for this specific set (optional)
  bool completed; // Track completion status for this set

  DisplaySet({
    required this.repetitions,
    this.weight,
    this.completed = false, // Default to not completed
  });
}

class WorkoutDetailsPage extends StatefulWidget {
  // Removed the required 'workout' parameter.
  // We will access arguments via ModalRoute.of(context).
  const WorkoutDetailsPage({super.key});

  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  bool started = false;
  List<DisplayExercise> _displayExercises = []; // List to hold exercises with set completion status
  bool _isLoading = true; // Loading state for fetching workout details
  bool _isSavingProgress = false; // Loading state for saving progress

  // Variables to hold workout data fetched or passed as arguments
  String _workoutId = '';
  String _workoutName = 'Loading Workout...'; // Default name while loading

  // Progress tracking variables
  int _completedSetsCount = 0;
  int _totalSetsCount = 0;
  double _percentageCompleted = 0.0;
  double _caloriesBurned = 0.0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // We can't access arguments directly in initState,
    // so we'll fetch data after the first frame or in didChangeDependencies.
    // A common pattern is to use a FutureBuilder or fetch in didChangeDependencies.
    // Let's use didChangeDependencies for simplicity here.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access arguments here after the context is available
    final args = ModalRoute.of(context)?.settings.arguments;

    if (_workoutId.isEmpty) { // Only process arguments if workoutId hasn't been set yet
      if (args is Map<String, dynamic>) {
        _workoutId = args['workoutId'] as String? ?? '';
        _workoutName = args['workoutName'] as String? ?? 'Unknown Workout';

        if (_workoutId.isNotEmpty) {
          _fetchWorkoutDetails(); // Fetch details using the ID
        } else {
          setState(() {
            _isLoading = false;
            _workoutName = 'Error: Workout ID not provided.';
          });
          print('Error: Workout ID not provided in arguments.');
          // Use addPostFrameCallback to show SnackBar after build
          if (mounted) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error loading workout details: ID missing.'), backgroundColor: Colors.red),
              );
            });
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          _workoutName = 'Error: Invalid arguments provided.';
        });
        print('Error: Invalid arguments for WorkoutDetailsPage.');
        // Use addPostFrameCallback to show SnackBar after build
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error loading workout details: Invalid arguments.'), backgroundColor: Colors.red),
            );
          });
        }
      }
    }
  }


  // *** Function to fetch detailed workout data from Firestore ***
  Future<void> _fetchWorkoutDetails() async {
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      print('Error: No user logged in to fetch workout details.');
      // Use addPostFrameCallback to show SnackBar after build
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in.'), backgroundColor: Colors.red),
          );
          Navigator.pop(context); // Go back if no user
        });
      }
      return;
    }

    if (_workoutId.isEmpty) {
      print('Error: Workout ID is empty, cannot fetch details.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch the specific workout document from the user's workoutProgram subcollection
      DocumentSnapshot workoutDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('workoutPrograms') // Use the correct subcollection name (plural)
          .doc(_workoutId) // Use the workout ID from arguments
          .get();

      if (workoutDoc.exists && workoutDoc.data() != null) {
        Map<String, dynamic> data = workoutDoc.data() as Map<String, dynamic>;

        // Assuming the exercises are stored in a field named 'exercises'
        List<dynamic> exercisesData = data['exercises'] ?? [];

        int totalSets = 0; // Calculate total sets during fetching
        List<DisplayExercise> fetchedDisplayExercises = [];

        // --- Fetch calories for each exercise from the top-level 'workouts' collection ---
        for (var exerciseData in exercisesData) {
          List<dynamic> setsData = exerciseData['sets'] ?? [];
          List<DisplaySet> displaySets = setsData.map((setData) {
            totalSets++; // Increment total sets count for each set
            return DisplaySet(
              repetitions: setData['repetitions'] ?? 0,
              weight: setData['weight']?.toString(), // Convert weight to string, handle null
              completed: false, // Initialize completed status for each set
            );
          }).toList();

          // Fetch the exercise document from the top-level 'workouts' collection
          // Assuming exerciseData['name'] is the workout_name in the 'workouts' collection
          double calories = 0.0; // Default calories to 0
          try {
            QuerySnapshot exerciseSnapshot = await _firestore
                .collection('workouts')
                .where('workout_name', isEqualTo: exerciseData['name'])
                .limit(1) // Assuming workout_name is unique or you only need one match
                .get();

            if (exerciseSnapshot.docs.isNotEmpty) {
              // Assuming 'cal' field exists and is a number in the 'workouts' collection (based on your screenshot)
              calories = (exerciseSnapshot.docs.first['cal'] as num?)?.toDouble() ?? 0.0;
            } else {
              print('Warning: Exercise "${exerciseData['name']}" not found in top-level workouts collection.');
            }
          } catch (e) {
            print('Error fetching calories for exercise "${exerciseData['name']}": $e');
            // Calories remain 0.0 on error
          }


          fetchedDisplayExercises.add(DisplayExercise(
            name: exerciseData['name'] ?? 'Unknown Exercise',
            weight: exerciseData['weight']?.toString(), // Convert global weight to string, handle null
            comments: exerciseData['comments'] ?? '',
            caloriesPerExercise: calories, // Use fetched calories
            sets: displaySets,
            // --- IMPORTANT ---
            // You'll need to fetch or provide actual exercise details (assetPath, description)
            // This might require a separate collection for exercise details or embedding them
            // in the workout document if they are specific to this workout program.
            // Using placeholders for now:
            assetPath: 'assets/placeholder_exercise.png', // Replace with actual logic
            description: 'No description available.', // Replace with actual logic
          ));
        }


        setState(() {
          _displayExercises = fetchedDisplayExercises;
          _totalSetsCount = totalSets; // Store total sets
          _isLoading = false; // Stop loading
          // Update workout name from fetched data if available, otherwise keep the one from arguments
          _workoutName = data['workoutName'] ?? _workoutName;
        });
        print('Fetched workout details for "$_workoutName". Total sets: $_totalSetsCount');

      } else {
        print('Workout document with ID $_workoutId not found.');
        setState(() {
          _isLoading = false; // Stop loading
          _workoutName = 'Workout Not Found';
        });
        // Use addPostFrameCallback to show SnackBar after build
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Workout details not found.'), backgroundColor: Colors.orange),
            );
          });
        }
      }

    } catch (e) {
      print('Error fetching workout details: $e');
      setState(() {
        _isLoading = false; // Stop loading even on error
        _workoutName = 'Error Loading Workout';
      });
      // Use addPostFrameCallback to show SnackBar after build
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading workout details: ${e.toString()}'), backgroundColor: Colors.red),
          );
        });
      }
    }
  }


  // Check if all sets in all exercises are completed
  bool get _allSetsCompleted {
    if (_displayExercises.isEmpty) return false;
    return _displayExercises.every((exercise) => exercise.sets.every((set) => set.completed));
  }

  // Handle back button press with confirmation if workout started
  void _handleBackButton(BuildContext context) {
    if (!started) {
      // If workout hasn't started, just pop
      Navigator.pop(context);
      return;
    }

    // If workout started, show confirmation dialog
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the workout? Your progress will be saved.'), // Indicate progress will be saved
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Don't exit
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async { // Made async to await saving progress
                await _saveWorkoutProgress(); // Save progress BEFORE popping page
                if (mounted) {
                  Navigator.of(context).pop(true); // Pop with 'true' to signal refresh
                }
              },
              child: const Text('Exit', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ).then((shouldPopAndRefresh) {
      if (shouldPopAndRefresh == true) {
        Navigator.pop(context, true); // Pop the workout details page with 'true'
      }
    });
  }


  // Reset workout state (started status and set completion)
  void _resetAll() {
    setState(() {
      started = false;
      // Reset completed status for all sets in all exercises
      for (var exercise in _displayExercises) {
        for (var set in exercise.sets) {
          set.completed = false;
        }
      }
      // Reset progress tracking variables
      _completedSetsCount = 0;
      _percentageCompleted = 0.0;
      _caloriesBurned = 0.0;
    });
  }

  // Function to toggle set completion status and update progress
  void _toggleSetCompletion(int exerciseIndex, int setIndex) {
    if (!started) return; // Only allow toggling if workout has started

    setState(() {
      // Toggle the completion status of the specific set
      _displayExercises[exerciseIndex].sets[setIndex].completed =
      !_displayExercises[exerciseIndex].sets[setIndex].completed;

      // Recalculate completed sets count
      _completedSetsCount = _displayExercises.fold(0, (sum, exercise) => sum + exercise.sets.where((set) => set.completed).length);

      // Recalculate percentage completed
      _percentageCompleted = _totalSetsCount > 0 ? (100 * _completedSetsCount / _totalSetsCount) : 0.0;

      // --- UPDATED CALORIE CALCULATION (Per Completed Set) ---
      _caloriesBurned = 0.0; // Reset calories burned
      for (var exercise in _displayExercises) {
        // Iterate through each set
        for (var set in exercise.sets) {
          // If the set is completed, add the full calorie value for the exercise
          if (set.completed) {
            _caloriesBurned += exercise.caloriesPerExercise;
          }
        }
      }
    });

    // Check if all sets are completed after toggling
    if (_allSetsCompleted) {
      // Save progress BEFORE navigating
      _saveWorkoutProgress().then((_) {
        // Navigate to ExerciseDoneScreen AFTER saving is complete
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExerciseDoneScreen()),
        ).then((_) {
          _resetAll(); // Reset the workout state when returning from completion screen
        });
      });
    }
  }

  // *** Function to save workout progress to Firestore ***
  Future<void> _saveWorkoutProgress() async {
    if (_isSavingProgress) return; // Prevent multiple saves
    if (currentUser == null) {
      print('Error: No user logged in to save workout progress.');
      return;
    }
    if (_workoutId.isEmpty) {
      print('Error: Workout ID is empty, cannot save progress.');
      return;
    }
    if (_completedSetsCount == 0 && !started) {
      // Don't save progress if no sets were completed and workout wasn't started
      print('No sets completed, not saving progress.');
      return;
    }


    setState(() {
      _isSavingProgress = true; // Start saving state
    });

    try {
      // Get the user's document reference
      DocumentReference userDocRef = _firestore.collection('users').doc(currentUser!.uid);

      // Add a new document to the 'workoutProgress' subcollection
      await userDocRef.collection('workoutProgress').add({
        'workoutId': _workoutId, // Store the ID of the workout program
        'workoutName': _workoutName, // Store the name of the workout program
        'percentageCompleted': double.parse(_percentageCompleted.toStringAsFixed(2)), // Save with 2 decimal places
        'caloriesBurned': double.parse(_caloriesBurned.toStringAsFixed(2)), // Save with 2 decimal places
        'completedSets': _completedSetsCount,
        'totalSets': _totalSetsCount,
        'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
      });

      print('Workout progress saved to Firestore for user ${currentUser!.uid}');

      if (mounted) {
        // Show success message after saving
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout progress saved!')),
        );
      }

    } catch (e) {
      print('Error saving workout progress: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout progress: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProgress = false; // Stop saving state
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    // Access arguments here in the build method if needed,
    // but fetching is already handled in didChangeDependencies.
    // final args = ModalRoute.of(context)?.settings.arguments;
    // if (args is Map<String, dynamic>) {
    //   _workoutId = args['workoutId'] as String? ?? '';
    //   _workoutName = args['workoutName'] as String? ?? 'Unknown Workout';
    // }


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
                    // Hardcoded image - consider fetching from exercise details if available
                    child: Image.network(
                      'https://assets.roguefitness.com/f_auto,q_auto,c_limit,w_1536,b_rgb:f8f8f8/catalog/Conditioning/Strength%20Equipment/Dumbbells/XX7125/XX7125-WEB3_rglczm.png',
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.fitHeight,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
                      onPressed: () {
                        _handleBackButton(context);
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
                      // Display the workout name from state
                      Text(
                        _workoutName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display progress information
                      Text(
                        'Progress: ${_percentageCompleted.toStringAsFixed(1)}% | Calories Burned: ${_caloriesBurned.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      // --- Exercise and Set List ---
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator()) // Show loading
                            : _displayExercises.isEmpty
                            ? const Center(child: Text('No exercises found for this workout.')) // Show message if no exercises
                            : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _displayExercises.length,
                          itemBuilder: (context, exerciseIndex) {
                            final exercise = _displayExercises[exerciseIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Exercise Title and View Details Button
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded( // Use Expanded to prevent overflow
                                        child: Text(
                                          exercise.name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis, // Handle long names
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, size: 22, color: Colors.blueAccent), // Changed icon for details
                                        // --- UPDATED NAVIGATION TO USE pushNamed ---
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/workout_details2_screen', // The named route for WorkoutDetails2Screen
                                            arguments: {
                                              'exerciseName': exercise.name,
                                              // WorkoutDetails2Screen will fetch other details
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Display global weight if available
                                if (exercise.weight != null && exercise.weight!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text('Weight: ${exercise.weight} KG', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                  ),
                                // Display comments if available
                                if (exercise.comments.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text('Comments: ${exercise.comments}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                  ),

                                // Sets List for this Exercise
                                ListView.builder(
                                  shrinkWrap: true, // Important for nested ListView
                                  physics: const NeverScrollableScrollPhysics(), // Prevent inner list from scrolling
                                  itemCount: exercise.sets.length,
                                  itemBuilder: (context, setIndex) {
                                    final set = exercise.sets[setIndex];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100], // Different color for sets
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          // Display set number and details
                                          Expanded(
                                            child: Text(
                                              'Set ${setIndex + 1}: ${set.repetitions} reps${set.weight != null && set.weight!.isNotEmpty ? ' at ${set.weight} KG' : ''}',
                                              style: const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                          // Set Completion Tick Button
                                          IconButton(
                                            icon: set.completed
                                                ? const Icon(Icons.check_circle, size: 24, color: Colors.green)
                                                : const Icon(Icons.check_circle_outline, size: 24, color: Colors.grey),
                                            onPressed: started ? () => _toggleSetCompletion(exerciseIndex, setIndex) : null,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16), // Spacing between exercises
                              ],
                            );
                          },
                        ),
                      ),

                      // Start Workout Button
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
                            onPressed: started || _isLoading || _isSavingProgress ? null : () => setState(() => started = true), // Disable if loading or saving
                            child: _isSavingProgress
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                                : Text(
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
