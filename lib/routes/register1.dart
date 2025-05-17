import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proje/utils/colors.dart';
import 'package:proje/utils/textstyles.dart';
import 'package:proje/utils/dimensions.dart';
import 'package:proje/utils/buttons.dart';

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
  bool _isLoading = false;

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// 🔥 **Kullanıcıyı Firebase Auth'a kaydetme ve Firestore'a ekleme**
  Future<void> _performRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      FocusScope.of(context).unfocus();

      try {
        // 🔹 Firebase Auth ile kullanıcı kaydı
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          // 🔹 Display Name ekleme
          await userCredential.user!.updateDisplayName(name);

          // 🔹 Firestore'a kullanıcı bilgilerini ekleme
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'dob': '',
            'age': '',
            'weight': '',
            'height': '',
            'gender': ''
          });

          print('Kullanıcı kaydedildi: ${userCredential.user!.uid}, İsim: $name');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Complete your profile.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/personal_info_page');
          }
        }
      } catch (e) {
        print('Error during registration: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account', style: AppTextStyles.header),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: Dimensions.mediumPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Dimensions.medium),
                Text("Full Name", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    contentPadding: Dimensions.mediumPadding,
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
                Text("Email Address", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                    contentPadding: Dimensions.mediumPadding,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: Dimensions.medium),
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
                    prefixIcon: const Icon(Icons.lock_outline),
                    contentPadding: Dimensions.mediumPadding,
                  ),
                  validator: _validatePassword,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _performRegistration(),
                ),
                SizedBox(height: Dimensions.extraLarge),
                ElevatedButton(
                  onPressed: _isLoading ? null : _performRegistration,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
