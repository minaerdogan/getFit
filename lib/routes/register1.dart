import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:proje/utils/colors.dart';
import 'package:proje/utils/textstyles.dart';
import 'package:proje/utils/dimensions.dart';
import 'package:proje/utils/buttons.dart'; // Assuming these are your custom button styles

class Register1 extends StatefulWidget {
  const Register1({super.key});
  @override
  _Register1State createState() => _Register1State();
}

class _Register1State extends State<Register1> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false; // To show a loading indicator

  // Initialize Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  String? _validatePassword(String? value) { // Added for consistency, you had it inline
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _performRegistration() async { // Made the function async
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      FocusScope.of(context).unfocus();

      try {
        // 1. Create user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Get the newly created user
        User? user = userCredential.user;

        if (user != null) {
          // Optionally, update the user's display name in Firebase Auth
          await user.updateDisplayName(name);

          // 2. Save additional user data to Cloud Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid, // Store UID for easy reference
            'name': name,
            'email': email,
            'createdAt': Timestamp.now(), // Add a timestamp for when the user was created
            // You can add other fields here as you collect them, e.g.:
            // 'age': null, // Add fields for personal info page
            // 'gender': null,
            // 'height': null,
            // 'weight': null,
          });

          print('Registered user: ${user.uid}, Name: $name. Data saved to Firestore.');

          // After successful registration and data saving, navigate
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration successful! You can now complete your profile.'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to the personal info page to collect more data
            Navigator.pushReplacementNamed(context, '/personal_info_page');
          }

        } else {
          // This case should ideally not happen if createUserWithEmailAndPassword is successful
          print('User credential returned null user.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration failed: Could not get user information.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }


      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else {
          errorMessage = 'An error occurred during registration. Please try again.';
          print('Firebase Auth Error Code: ${e.code}');
          print('Firebase Auth Error Message: ${e.message}');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle other potential errors, including Firestore write errors
        print('General Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print("Form is invalid - Please check the fields.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please correct the errors in the form.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account', style: AppTextStyles.header), // Changed title slightly
        backgroundColor: AppColors.primary, // Assuming AppColors.primary is defined
        elevation: 0,
        leading: IconButton( // Added a back button for better navigation
          icon: Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: Dimensions.mediumPadding, // Assuming Dimensions.mediumPadding is defined
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Changed to stretch for button width
              children: [
                SizedBox(height: Dimensions.medium),
                // Name
                Text("Full Name", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.person_outline),
                    contentPadding: Dimensions.mediumPadding, // Assuming custom padding
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: Dimensions.medium),

                // Email
                Text("Email Address", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.email_outlined),
                    contentPadding: Dimensions.mediumPadding,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: Dimensions.medium),

                // Password
                Text("Password", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                    contentPadding: Dimensions.mediumPadding,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword, // Using the separate validator function
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _isLoading ? null : _performRegistration(),
                ),

                SizedBox(height: Dimensions.extraLarge),

                // Sign Up Button
                SizedBox(
                  width: double.infinity, // Ensures button takes full width
                  height: ButtonDimensions.height, // Assuming ButtonDimensions is defined
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: ButtonDimensions.borderRadiusGeometry, // Assuming defined
                      ),
                      padding: ButtonDimensions.padding, // Assuming defined
                    ),
                    onPressed: _isLoading ? null : _performRegistration,
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : Text('Sign Up', style: AppTextStyles.button),
                  ),
                ),
                SizedBox(height: Dimensions.medium),
                // Option to go to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: AppTextStyles.small),
                    GestureDetector(
                      onTap: _isLoading ? null : () {
                        Navigator.pop(context); // Go back to the previous screen (likely login)
                        // Or Navigator.pushReplacementNamed(context, '/login'); if you want to be explicit
                      },
                      child: Text(
                        'Login',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primary, // Use your primary color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.medium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
