import 'package:flutter/material.dart';
// başka sayfaların importlanması lazım




class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Basic email validation using a regular expression
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
  // This will be changed after we get the database
  void _login() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed with login logic
      String email = _emailController.text;
      String password = ''; // Get password from its controller

      print('Logging in with Email: $email, Password: $password');
      // Add your actual login API call or authentication logic here
      // For now, without a database, just navigate to the home page

      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        // Home screen e geçiş
      );
      */

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Hey there,',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Welcome Back',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: GestureDetector( // Make the icon tappable
                    onTap: _togglePasswordVisibility,
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                // You can add password validation here if needed
                validator: _validatePassword,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Or',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey[300],
                      thickness: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              OutlinedButton(
                onPressed: () {
                  print('Sign in with Google');
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/7123025_logo_google_g_icon.png',
                      height: 24.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Sign in with Google',
                      style: TextStyle(color: Colors.black87, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Don't have an account yet? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      print('Register tapped');
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
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



