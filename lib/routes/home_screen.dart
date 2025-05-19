import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../utils/textstyles.dart';

// Define a simple model to hold workout data fetched from Firestore
class Workout {
  final String id; // Document ID
  final String name;
  // You might want to add other fields here if needed, e.g., List<Exercise> exercises;

  Workout({required this.id, required this.name});
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Removed the hardcoded list
  // final List<String> _workouts = ['Abs Workout', 'Full Body Workout', 'Lower Body Workout',];

  List<Workout> _userWorkouts = []; // List to hold workouts fetched from Firestore
  bool _isLoadingWorkouts = true; // Loading state for fetching workouts
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;


  int _selectedIndex = 0; // For BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _fetchUserWorkouts(); // Fetch workouts when the screen initializes
  }

  // *** Function to fetch user's workout programs from Firestore ***
  Future<void> _fetchUserWorkouts() async {
    if (currentUser == null) {
      setState(() {
        _isLoadingWorkouts = false;
        // Handle case where user is not logged in, maybe navigate to login
      });
      print('No authenticated user found to fetch workouts.');
      return;
    }

    try {
      // Get documents from the 'workoutProgram' subcollection for the current user
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('workoutPrograms') // Use the correct subcollection name
          .orderBy('createdAt', descending: true) // Optional: Order by creation date
          .get();

      // Map the documents to our Workout model
      List<Workout> fetchedWorkouts = querySnapshot.docs.map((doc) {
        // Assuming 'workoutName' is the field containing the workout name
        return Workout(
          id: doc.id, // Store the document ID
          name: doc['workoutName'] as String,
          // You can fetch other fields here if needed
        );
      }).toList();

      setState(() {
        _userWorkouts = fetchedWorkouts;
        _isLoadingWorkouts = false; // Stop loading
      });
      print('Fetched ${_userWorkouts.length} workout programs.');

    } catch (e) {
      print('Error fetching user workouts from Firestore: $e');
      setState(() {
        _isLoadingWorkouts = false; // Stop loading even on error
        // Optionally, show an error message to the user
      });
    }
  }

  // *** Function to delete a workout program from Firestore ***
  Future<void> _deleteWorkout(String workoutId, int index) async {
    if (currentUser == null) {
      print('Error: No user logged in to delete workout.');
      return;
    }

    try {
      // Delete the document from the 'workoutProgram' subcollection
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('workoutPrograms')
          .doc(workoutId)
          .delete();

      print('Workout with ID $workoutId deleted successfully.');

      // Remove the workout from the local list to update the UI
      setState(() {
        _userWorkouts.removeAt(index);
      });

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted successfully!')),
        );
      }

    } catch (e) {
      print('Error deleting workout: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete workout: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('getFit Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the screen to add a new workout schedule
              Navigator.pushNamed(context, '/saveWorkout').then((_) {
                // Refresh the workout list when returning from the add screen
                _fetchUserWorkouts();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assuming this is a static graph image
              Image.asset(
                'assets/graph.png',
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox( // Use SizedBox as a placeholder
                    height: 150, // Give it a size
                    child: Center(child: Text('Graph image not found')),
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Welcome to getFit!',
                  style: AppTextStyles.welcome,
                ),
              ),
              const SizedBox(height: 20),
              const Text('My Workout Programs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Title for the list
              const SizedBox(height: 10),


              // --- Display fetched workouts or loading indicator ---
              _isLoadingWorkouts
                  ? const Center(child: CircularProgressIndicator()) // Show loading
                  : _userWorkouts.isEmpty
                  ? const Center(child: Text('No workout programs saved yet.\nTap "+" to add one.', textAlign: TextAlign.center,)) // Show message if list is empty
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = _userWorkouts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        workout.name, // Display workout name from Firestore
                        style: AppTextStyles.listItem,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Call delete function, passing the workout ID and index
                              _deleteWorkout(workout.id, index);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/workout_details_page',
                          arguments: {
                            'workoutId': workout.id,
                            'workoutName': workout.name,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) async {
          if (_selectedIndex == index) return;
          setState(() => _selectedIndex = index);
          if (index == 1) {
            await Navigator.pushNamed(context, '/my_account');
            setState(() => _selectedIndex = 0); // Reset index when returning
          } else if (index == 0) {
            // Already on home, no navigation needed unless you want to refresh
            // _fetchUserWorkouts(); // Uncomment to refresh when tapping Home icon
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
