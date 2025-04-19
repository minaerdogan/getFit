import 'package:flutter/material.dart';
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

  void _performRegistration() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      print('Registering with Name: $name, Email: $email');
      Navigator.pushNamed(context, '/personal_info_page');
    } else {
      print("Form is invalid - Please check the fields.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: AppTextStyles.header),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: Dimensions.mediumPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text("Name", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: Dimensions.mediumPadding,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Dimensions.medium),

                // Email
                Text("Email", style: AppTextStyles.regular),
                SizedBox(height: Dimensions.regular),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: Dimensions.mediumPadding,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
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
                    contentPadding: Dimensions.mediumPadding,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: Dimensions.extraLarge),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: ButtonDimensions.height,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: ButtonDimensions.borderRadiusGeometry,
                      ),
                      padding: ButtonDimensions.padding,
                    ),
                    onPressed: _performRegistration,
                    child: Text('Sign Up', style: AppTextStyles.button),
                  ),
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
