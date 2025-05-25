import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // <--- ADDED: Import Provider
import '../utils/textstyles.dart';
import '../utils/colors.dart';
// Assuming you have these utility files. If not, provide them or remove imports.
// import '../utils/dimensions.dart';
// import '../utils/buttons.dart';

// <--- ADDED: Import your UserProfileProvider --->
import '../providers/get_ready_provider.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;


  @override
  void dispose() {
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  String? _validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth cannot be empty';
    }
    final dobRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dobRegex.hasMatch(value)) {
      return 'Please enter date in yyyy-mm-dd format';
    }

    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (month < 1 || month > 12) {
        return 'Please enter a valid month (01-12)';
      }

      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (day < 1 || day > daysInMonth) {
        return 'Please enter a valid day (01-$daysInMonth for the selected month)';
      }

      final date = DateTime(year, month, day);
      if (date.isAfter(DateTime.now())) {
        return 'Date of Birth cannot be in the future';
      }
      return null;
    } catch (e) {
      return 'Invalid date entered';
    }
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number for $fieldName';
    }
    if (number <= 0) {
      return '$fieldName must be a positive number';
    }
    if (fieldName == "Weight" && (number > 260 || number < 25)) {
      return '$fieldName must be between 25 KG and 260 KG';
    }

    if (fieldName == "Your Height" && (number > 250 || number < 100)) {
      return '$fieldName must be between 100 CM and 250 CM';
    }

    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  int _calculateAge(String dobText) {
    final birthDate = DateTime.tryParse(dobText);
    if (birthDate == null) return 0;

    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }

    return (age > 0 && age <= 110) ? age : 0;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();
      final age = _calculateAge(_dobController.text);
      final weight = _weightController.text;
      final height = _heightController.text;
      final gender = _selectedGender;
      final dob = _dobController.text;

      if (currentUser != null) {
        try {
          DocumentReference userDocRef = _firestore.collection('users').doc(currentUser!.uid);

          await userDocRef.update({
            'dob': dob,
            'age': age,
            'weight': weight,
            'height': height,
            'gender': gender,
            'profileCompleted': true,
          });

          print('Personal information saved to Firestore for user: ${currentUser!.uid}');

          // <--- IMPORTANT ADDITION HERE: Refresh the UserProfileProvider data --->
          // Get the provider instance without listening (listen: false)
          // because we are only performing an action (refresh), not rebuilding the UI based on its state here.
          Provider.of<UserProfileProvider>(context, listen: false).refreshUserName();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile information saved successfully!')),
            );
            Navigator.pushReplacementNamed(context, '/get_ready');
          }

        } catch (e) {
          print('Error saving personal information: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save profile information: ${e.toString()}'),
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
        print('Error: No user is logged in.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User not logged in.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }

    } else {
      print('Form is invalid. Please check the fields.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the errors in the form')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/fitness_woman.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Let’s complete your profile",
                  style: AppTextStyles.header.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 30),
                _buildGenderDropdown(),
                _buildTextField(
                  "Date of Birth (yyyy-mm-dd)",
                  _dobController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.datetime,
                  validator: _validateDob,
                ),
                _buildWeightHeightField(
                  "Your Weight",
                  _weightController,
                  icon: Icons.monitor_weight,
                  unit: "KG",
                  validator: (value) => _validatePositiveNumber(value, "Weight"),
                ),
                _buildWeightHeightField(
                  "Your Height",
                  _heightController,
                  icon: Icons.height,
                  unit: "CM",
                  validator: (value) => _validatePositiveNumber(value, "Your Height"),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B61FF), Color(0xFF9E8BFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... _buildTextField, _buildWeightHeightField, _buildGenderDropdown methods remain the same
  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        IconData? icon,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildWeightHeightField(
      String label,
      TextEditingController controller, {
        required IconData icon,
        required String unit,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              ),
              validator: validator,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unit,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Choose Gender",
          prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
        hint: const Text("Select your gender"),
        isExpanded: true,
        items: _genders.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue;
          });
        },
        validator: _validateGender,
      ),
    );
  }
}