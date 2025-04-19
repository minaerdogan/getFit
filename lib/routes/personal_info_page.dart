import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/textstyles.dart';
import '../utils/colors.dart';



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
  final List<String> _genders = ['Male', 'Female', 'Other']; // Available gender options

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

      final daysInMonth = DateTime(year, month + 1, 0).day; // Get last day of the month
      if (day < 1 || day > daysInMonth) {
        return 'Please enter a valid day (01-$daysInMonth for the selected month)';
      }

      final date = DateTime(year, month, day);
      if (date.isAfter(DateTime.now())) {
        return 'Date of Birth cannot be in the future';
      }
      return null; // Valid date
    } catch (e) {
      return 'Invalid date entered';
    }
  }



// Validator for positive nums
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
    if (fieldName == "Weight" && number > 260) {
      return '$fieldName cannot be greater than 260 KG';
    }

    if (fieldName == "Weight" && number < 25) {
      return '$fieldName cannot be greater than 25 KG';
    }

    if (fieldName == "Your Height" && number > 250) {
      return '$fieldName cannot be greater than 250 CM';
    }

    if (fieldName == "Your Height" && number < 100) {
      return '$fieldName cannot be smaller than 100 CM';
    }

    return null; // Valid
  }

  // Validator for gender
  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null; // Valid
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

    return (age > 0 && age <= 110) ? age : 0; // Return 0 if age is negative or greater than 110
  }


  void _submitForm() {

    if (_formKey.currentState!.validate()) {

      _formKey.currentState!.save();
      final age = _calculateAge(_dobController.text);
      final weight = _weightController.text;
      final height = _heightController.text;
      final gender = _selectedGender;

      print('Form is valid!');
      print('DOB: ${_dobController.text}, Age: $age');
      print('Weight: $weight KG');
      print('Height: $height CM');
      print('Gender: $gender');



      Navigator.pushNamed(context, '/get_ready');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile information saved!')),
      );

    } else {

      print('Form is invalid. Please check the fields.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
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
                  validator: (value) => _validatePositiveNumber(value, "Weight"), // positive number validator
                ),
                _buildWeightHeightField(
                  "Your Height",
                  _heightController,
                  icon: Icons.height,
                  unit: "CM",
                  validator: (value) => _validatePositiveNumber(value, "Height"), //  positive number validator
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
                        ]
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _submitForm, // submit function
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "Next",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Padding
              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        IconData? icon,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField( // Use TextFormField for validation
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder( // Style for when enabled
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder( // Style for when focused
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50], // Slightly off-white background
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        ),
        validator: validator, // Assign the validator
      ),
    );
  }

  // Updated Weight/Height field builder with validator
  Widget _buildWeightHeightField(
      String label,
      TextEditingController controller, {
        required IconData icon,
        required String unit,
        String? Function(String?)? validator, // Add validator parameter
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Match approx text field height
            decoration: BoxDecoration(

              color: Theme.of(context).primaryColorLight, // Example: Light purple
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
