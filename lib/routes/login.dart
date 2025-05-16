import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../utils/textstyles.dart'; // Assuming these are correctly set up
import '../utils/colors.dart';     // Assuming these are correctly set up
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Controller for password
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false; // To show a loading indicator during login
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn here

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    // You could add more password validation here (e.g., minimum length)
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async { // Made the function async
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim(); // Get password from controller

      FocusScope.of(context).unfocus();

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Logged in user: ${userCredential.user!.uid}');

        // Navigate to the next screen upon successful login and remove all previous routes
        if (mounted) { // Check if the widget is still in the tree
          Navigator.pushNamedAndRemoveUntil(context, '/get_ready', (Route<dynamic> route) => false);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid.';
        } else if (e.code == 'too-many-requests') {
          errorMessage = 'Too many login attempts. Please try again later.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
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
        // Handle other potential errors
        print('General Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Stop loading
          });
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { // User cancelled
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('Google Sign-In successful: ${userCredential.user!.displayName}');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/get_ready', (Route<dynamic> route) => false);
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Failed: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Hey there,',
                style: AppTextStyles.small.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Welcome Back',
                style: AppTextStyles.header.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined),
                  labelText: 'Email',
                  labelStyle: AppTextStyles.regular,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                enabled: !_isLoading, // Disable when loading
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController, // Assign password controller
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Password',
                  labelStyle: AppTextStyles.regular,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  suffixIcon: GestureDetector(
                    onTap: _isLoading ? null : _togglePasswordVisibility, // Disable tap when loading
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validatePassword,
                enabled: !_isLoading, // Disable when loading
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _login, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.classicButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24.0, // Match icon/text height
                  width: 24.0,  // Match icon/text height
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3.0),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20), // Adjusted size
                    const SizedBox(width: 8.0),
                    Text('Login', style: AppTextStyles.button),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1.0)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Or', style: AppTextStyles.small.copyWith(color: Colors.grey[600])),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300], thickness: 1.0)),
                ],
              ),
              const SizedBox(height: 16.0),
              OutlinedButton(
                onPressed: _isLoading ? null : _signInWithGoogle, // Call Google Sign-In, disable when loading
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24.0,
                  width: 24.0,
                  child: CircularProgressIndicator(), // Default color
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/7123025_logo_google_g_icon.png', height: 24.0), // Make sure this asset exists
                    const SizedBox(width: 8.0),
                    Text('Sign in with Google', style: AppTextStyles.regular),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Don't have an account yet? ", style: AppTextStyles.small.copyWith(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: _isLoading ? null : () { // Disable tap when loading
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Register',
                      style: AppTextStyles.small.copyWith(
                        color: _isLoading ? Colors.grey : Colors.purple[300], // Grey out when loading
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}