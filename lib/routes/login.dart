import 'package:flutter/material.dart';
import '../utils/textstyles.dart';
import '../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = '';
      print('Logging in with Email: $email, Password: $password');
      FocusScope.of(context).unfocus();

      Future.delayed(const Duration(milliseconds: 250), () {
        Navigator.pushNamed(context, '/get_ready');
      });
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
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Password',
                  labelStyle: AppTextStyles.regular,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  suffixIcon: GestureDetector(
                    onTap: _togglePasswordVisibility,
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.classicButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
                onPressed: () {
                  print('Sign in with Google');
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/7123025_logo_google_g_icon.png', height: 24.0),
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
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Register',
                      style: AppTextStyles.small.copyWith(
                        color: Colors.purple[300],
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
}
