import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = 'User'; // Default name
  bool _isLoading = true; // Loading state
  String? _errorMessage; // Optional: for displaying errors

  // Getters to expose the state to widgets
  String get userName => _userName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Sets up a listener for Firebase Auth state changes
  UserProfileProvider() {
    // This listener ensures that when a user logs in or out,
    // the provider automatically tries to fetch or clear the user's name.
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        // If a user is logged in, fetch their name using their UID.
        _fetchUserName(user.uid);
      } else {
        // If no user is logged in (e.g., logged out), reset the state.
        _userName = 'User';
        _isLoading = false;
        _errorMessage = null;
        notifyListeners(); // Notify any listening widgets to update.
      }
    });
  }

  // Private method to fetch the user's name from Firestore
  Future<void> _fetchUserName(String userId) async {
    _isLoading = true;
    _errorMessage = null; // Clear any previous error
    notifyListeners(); // Notify widgets that loading has started.

    try {
      // Access the 'users' collection and the document corresponding to the userId.
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('name')) {
          _userName = data['name']; // Update the name from Firestore.
          print('User name fetched: $_userName'); // For debugging.
        } else {
          _userName = 'Unnamed User'; // Fallback if 'name' field is missing.
          print('Firestore document exists but does not contain a "name" field.');
        }
      } else {
        _userName = 'New User'; // Fallback if user document is not found.
        print('Firestore document for user $userId not found.');
      }
    } catch (e) {
      print('Error fetching user name from Firestore: $e'); // Log the error.
      _errorMessage = 'Failed to load user data: ${e.toString()}'; // Set error message.
      _userName = 'Error User'; // Display an error placeholder name.
    } finally {
      _isLoading = false; // Loading is complete.
      notifyListeners(); // Notify widgets to rebuild with the new state.
    }
  }

  // You can add a public method to manually refresh the data if needed later.
  // For 'GetReadyScreen', the authStateChanges listener is usually sufficient.
  Future<void> refreshUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _fetchUserName(user.uid);
    } else {
      _userName = 'User';
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }
  }
}