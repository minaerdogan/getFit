import 'package:flutter/material.dart';
// Make sure these paths are correct for your project structure
import 'package:proje/utils/colors.dart';
import 'package:proje/utils/textstyles.dart';
import 'package:proje/utils/dimensions.dart';
import 'package:proje/utils/buttons.dart'; // Ensure ButtonDimensions is defined here or in dimensions.dart

class Register1 extends StatefulWidget {
  const Register1({super.key});
  @override
  _Register1State createState() => _Register1State();
}

class _Register1State extends State<Register1> {
  // Key for accessing the Form state
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields to manage their values
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to track password visibility
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize password visibility state (optional, as default is false)
    _passwordVisible = false;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    // to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validator function for email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email'; // Simplified message
    }
    // Regular expression for basic email validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null; // Return null if the email is valid
  }

  // Function to handle the registration process when the button is pressed
  void _performRegistration() {
    // Validate the form using its current state
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed with registration logic
      print("Form is valid - Proceeding with registration");
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text; // Get password value

      print('Registering with Name: $name, Email: $email'); // Password is intentionally not printed for security

      // TODO: Implement your actual registration logic here
      // This might involve:
      // - Showing a loading indicator
      // - Making an API call to your backend server
      // - Handling success (e.g., navigating to another page, showing a success message)
      // - Handling errors (e.g., showing an error message if registration fails)


      // Example: Navigate to the next page after successful validation (replace with actual success handling)
      // Consider showing feedback before navigating (e.g., a SnackBar or loading indicator)
      Navigator.pushNamed(context, '/personal_info_page');
      // Or replace the current screen so the user can't go back to registration:
      // Navigator.pushReplacementNamed(context, '/personal_info_page');

    } else {
      // If the form is invalid, validation errors will be displayed automatically
      // by the TextFormField widgets. You can optionally show a general message.
      print("Form is invalid - Please check the fields.");
      // Optionally show a SnackBar:
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please fix the errors in the form')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          'Register',
          // Ensure AppTextStyles.header is defined and provides good contrast
          style: AppTextStyles.header ?? const TextStyle(color: Colors.white, fontSize: 20),
        ),
        // Ensure AppColors.primary is defined
        backgroundColor: AppColors.primary ?? Theme.of(context).primaryColor,
        elevation: 0, // Removes the shadow below the AppBar
      ),
      // Wrap the body with SingleChildScrollView to prevent overflow
      body: SingleChildScrollView(
        child: Padding(
          // Ensure Dimensions.mediumPadding provides adequate spacing
          padding: Dimensions.mediumPadding ?? const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Assign the key to the Form
            child: Column(
              // Align children to the start (left)
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Name Field ---
                Text(
                    "Name",
                    // Ensure AppTextStyles.regular is defined
                    style: AppTextStyles.regular ?? const TextStyle(fontSize: 16)
                ),
                // Ensure Dimensions.regular provides adequate spacing
                const SizedBox(height: Dimensions.regular ?? 8.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      // Example border radius
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    // Ensure Dimensions.mediumPadding provides adequate internal padding
                    contentPadding: Dimensions.mediumPadding ?? const EdgeInsets.all(16.0),
                  ),
                  // Validator for the name field
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required'; // Simplified message
                    }
                    return null; // Valid
                  },
                ),
                // Ensure Dimensions.medium provides adequate spacing
                const SizedBox(height: Dimensions.medium ?? 16.0),

                // --- Email Field ---
                Text(
                    "Email",
                    style: AppTextStyles.regular ?? const TextStyle(fontSize: 16)
                ),
                const SizedBox(height: Dimensions.regular ?? 8.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: Dimensions.mediumPadding ?? const EdgeInsets.all(16.0),
                  ),
                  keyboardType: TextInputType.emailAddress, // Set appropriate keyboard type
                  validator: _validateEmail, // Use the custom email validator
                ),
                const SizedBox(height: Dimensions.medium ?? 16.0),

                // --- Password Field ---
                Text(
                    "Password",
                    style: AppTextStyles.regular ?? const TextStyle(fontSize: 16)
                ),
                const SizedBox(height: Dimensions.regular ?? 8.0),
                TextFormField(
                  controller: _passwordController,
                  // Use the state variable to control text obscuring
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: Dimensions.mediumPadding ?? const EdgeInsets.all(16.0),
                    // Add the icon button to toggle password visibility
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Choose icon based on visibility state
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        // Optional: Set icon color
                        // color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        // Update the state variable when the icon is pressed
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  // Validator for the password field
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required'; // Simplified message
                    }
                    // Optional: Add more password strength validation
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null; // Valid
                  },
                ),

                // Ensure Dimensions.extraLarge provides adequate spacing before the button
                const SizedBox(height: Dimensions.extraLarge ?? 32.0),

                // --- Sign Up Button ---
                SizedBox(
                  width: double.infinity, // Make button take full width
                  // Ensure ButtonDimensions are defined and provide reasonable values
                  height: ButtonDimensions.height ?? 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Ensure AppColors.primary is defined
                      backgroundColor: AppColors.primary ?? Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        // Ensure ButtonDimensions.borderRadiusGeometry is defined
                        borderRadius: ButtonDimensions.borderRadiusGeometry ?? BorderRadius.circular(8.0),
                      ),
                      // Ensure ButtonDimensions.padding is defined
                      padding: ButtonDimensions.padding ?? const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    // Call the registration function when pressed
                    onPressed: _performRegistration,
                    child: Text(
                      'Sign Up', // Use appropriate text for registration
                      // Ensure AppTextStyles.button is defined and provides good contrast
                      style: AppTextStyles.button ?? const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // Add some extra space at the bottom if needed, especially inside the scroll view
                const SizedBox(height: Dimensions.medium ?? 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

