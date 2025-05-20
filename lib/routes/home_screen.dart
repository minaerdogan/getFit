import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import '../utils/textstyles.dart';
// Import fl_chart components
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Import for date formatting


// Define a simple model to hold workout data fetched from Firestore
class Workout {
  final String id; // Document ID
  final String name;
  // You might want to add other fields here if needed, e.g., List<Exercise> exercises;

  Workout({required this.id, required this.name});
}

// Model to hold workout progress data fetched from the subcollection
class WorkoutProgressData {
  final String workoutName;
  final double percentageCompleted;
  final double caloriesBurned;
  final DateTime timestamp; // To order and potentially group data

  WorkoutProgressData({
    required this.workoutName,
    required this.percentageCompleted,
    required this.caloriesBurned,
    required this.timestamp,
  });
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> _userWorkouts = []; // List to hold workouts fetched from Firestore
  List<WorkoutProgressData> _workoutProgress = []; // List to hold workout progress data
  bool _isLoadingWorkouts = true; // Loading state for fetching workouts
  bool _isLoadingProgress = true; // Loading state for fetching progress data

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;


  int _selectedIndex = 0; // For BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _fetchUserWorkouts(); // Fetch workouts when the screen initializes
    _fetchWorkoutProgress(); // Fetch workout progress when the screen initializes
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

  // *** Function to fetch user's workout progress from Firestore ***
  Future<void> _fetchWorkoutProgress() async {
    if (currentUser == null) {
      setState(() {
        _isLoadingProgress = false;
      });
      print('No authenticated user found to fetch workout progress.');
      return;
    }

    try {
      // Get documents from the 'workoutProgress' subcollection for the current user
      // Order by timestamp to show recent progress
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('workoutProgress') // Use the correct subcollection name
          .orderBy('timestamp', descending: true)
          .limit(10) // Limit to the last 10 workouts for the chart
          .get();

      // Map the documents to our WorkoutProgressData model
      List<WorkoutProgressData> fetchedProgress = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return WorkoutProgressData(
          workoutName: data['workoutName'] as String? ?? 'Unknown Workout',
          percentageCompleted: (data['percentageCompleted'] as num?)?.toDouble() ?? 0.0,
          caloriesBurned: (data['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      setState(() {
        _workoutProgress = fetchedProgress.reversed.toList(); // Reverse to show oldest first on chart
        _isLoadingProgress = false; // Stop loading
      });
      print('Fetched ${_workoutProgress.length} workout progress entries.');

    } catch (e) {
      print('Error fetching workout progress from Firestore: $e');
      setState(() {
        _isLoadingProgress = false; // Stop loading even on error
        // Optionally, show an error message to the user
      });
    }
  }

  // Helper function to build the Workout Tracker chart (Bar Chart)
  Widget _buildWorkoutTrackerChart() {
    // Always return a SizedBox with a BarChart, even if data is empty
    return SizedBox(
      height: 200, // Adjust height as needed
      child: BarChart(
        BarChartData(
          barGroups: _workoutProgress.isEmpty ? [] : _workoutProgress.asMap().entries.map((entry) {
            int index = entry.key;
            WorkoutProgressData data = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.percentageCompleted,
                  color: const Color(0xFF3A7BD5), // Blue color for bars
                  width: 16, // Adjust bar width as needed
                  borderRadius: BorderRadius.circular(4), // Rounded corners for bars
                ),
              ],
            );
          }).toList(),
          gridData: const FlGridData(show: false), // Hide grid lines
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25, // Show titles every 25%
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%', style: const TextStyle(fontSize: 10));
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Display formatted timestamp instead of workout name
                  if (value.toInt() < _workoutProgress.length) {
                    final timestamp = _workoutProgress[value.toInt()].timestamp;
                    // Format the date as desired (e.g., 'MM/dd')
                    final formattedDate = DateFormat('MM/dd').format(timestamp);
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          alignment: BarChartAlignment.start, // *** Changed to .start for left alignment ***
          maxY: 100, // Max y-axis at 100%
          groupsSpace: 8, // Space between bar groups
          // *** Tooltip Configuration ***
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (groupData) => Colors.blueGrey, // Use getTooltipColor callback
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Display the percentage value
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)}%', // Format the value
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            // You can customize touch behavior further here if needed
            // touchCallback: (FlTouchEvent event, BarTouchResponse? response) { ... },
          ),
        ),
      ),
    );
  }

  // Helper function to build the Calorie Tracker chart (Bar Chart)
  Widget _buildCalorieTrackerChart() {
    // Always return a SizedBox with a BarChart, even if data is empty
    return SizedBox(
      height: 200, // Adjust height as needed
      child: BarChart( // Using BarChart for calories as well
        BarChartData(
          barGroups: _workoutProgress.isEmpty ? [] : _workoutProgress.asMap().entries.map((entry) {
            int index = entry.key;
            WorkoutProgressData data = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.caloriesBurned,
                  color: const Color(0xFF00d2ff), // Cyan color for bars
                  width: 16, // Adjust bar width as needed
                  borderRadius: BorderRadius.circular(4), // Rounded corners for bars
                ),
              ],
            );
          }).toList(),
          gridData: const FlGridData(show: false), // Hide grid lines
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                // Determine interval based on data, or use a default if empty
                interval: _workoutProgress.isEmpty ? 50 : (_workoutProgress.map((data) => data.caloriesBurned).reduce(
                      (value, element) => value > element ? value : element,
                ) * 1.2) / 4,
                getTitlesWidget: (value, meta) {
                  return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)); // Show whole numbers
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // Display formatted timestamp instead of workout name
                  if (value.toInt() < _workoutProgress.length) {
                    final timestamp = _workoutProgress[value.toInt()].timestamp;
                    // Format the date as desired (e.g., 'MM/dd')
                    final formattedDate = DateFormat('MM/dd').format(timestamp);
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          alignment: BarChartAlignment.start, // *** Changed to .start for left alignment ***
          // Determine maxY based on data, or use a default if empty
          maxY: _workoutProgress.isEmpty ? 100 : _workoutProgress.map((data) => data.caloriesBurned).reduce(
                (value, element) => value > element ? value : element,
          ) * 1.2,
          groupsSpace: 8, // Space between bar groups
          // *** Tooltip Configuration ***
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (groupData) => Colors.blueGrey, // Use getTooltipColor callback
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Display the calorie value
                return BarTooltipItem(
                  rod.toY.toStringAsFixed(1), // Format the value
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            // You can customize touch behavior further here if needed
            // touchCallback: (FlTouchEvent event, BarTouchResponse? response) { ... },
          ),
        ),
      ),
    );
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
                // Refresh the workout list and progress when returning
                _fetchUserWorkouts();
                _fetchWorkoutProgress();
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
              // --- Workout Tracker Chart ---
              const Text('Workout Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _isLoadingProgress
                  ? const Center(child: CircularProgressIndicator())
                  : _buildWorkoutTrackerChart(), // Use the chart builder function
              // Label for the X-axis
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Workout Session / Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Calorie Tracker Chart ---
              const Text('Calorie Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _isLoadingProgress
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCalorieTrackerChart(), // Use the chart builder function
              // Label for the X-axis
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Workout Session / Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
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
            // Already on home, refresh data when tapping Home icon
            _fetchUserWorkouts();
            _fetchWorkoutProgress();
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
