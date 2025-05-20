import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:proje/utils/colors.dart'; // Assuming this is correctly set up

class GetReadyScreen extends StatefulWidget {
  const GetReadyScreen({super.key});

  @override
  State<GetReadyScreen> createState() => _GetReadyScreenState();
}

class _GetReadyScreenState extends State<GetReadyScreen> {
  String _userName = 'User'; // Default name while loading or if name not found
  bool _isLoading = true; // To show a loading indicator

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the widget initializes
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current authenticated user

    if (user != null) {
      try {
        // Get the user's document from the 'users' collection
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Use the authenticated user's UID
            .get();

        // Check if the document exists and contains the 'name' field
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          if (data.containsKey('name')) {
            setState(() {
              _userName = data['name']; // Update the state with the fetched name
            });
          } else {
            print('Firestore document exists but does not contain a "name" field.');
          }
        } else {
          print('Firestore document for user ${user.uid} not found.');
        }
      } catch (e) {
        print('Error fetching user name from Firestore: $e');
        // Optionally show an error message to the user
      }
    } else {
      print('No authenticated user found.');
      // Handle case where no user is logged in (e.g., navigate back to login)
    }

    setState(() {
      _isLoading = false; // Stop loading regardless of success or failure
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading indicator
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Image.asset(
                  'assets/get_ready_graphic.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Display the fetched user name
              Text(
                'Welcome, $_userName',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8), // Adjusted spacing
              const Text(
                'You are all set now, let’s reach your goals together with us',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home_screen'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.classicButtonColor, // Using the color from your utils class
                  foregroundColor: Colors.white, // Optional: Set text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Optional: Add rounded corners
                  ),
                ),
                child: const Text('Go To Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
