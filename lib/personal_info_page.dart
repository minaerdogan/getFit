import 'package:flutter/material.dart';
import 'my_account.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  int _calculateAge(String dobText) {
    final birthDate = DateTime.tryParse(dobText);
    final currentDate = DateTime(2025, 4, 16);
    int age = 0;

    if (birthDate != null) {
      age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
        age--;
      }
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Image.asset(
                  'assets/fitness_woman.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Let’s complete your profile",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "It will help us to know more about you!",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              _buildGenderDropdown(),
              _buildTextField("Date of Birth (yyyy-mm-dd)", _dobController, icon: Icons.cake),
              _buildWeightHeightField("Your Weight", _weightController, icon: Icons.monitor_weight, unit: "KG"),
              _buildWeightHeightField("Your Height", _heightController, icon: Icons.height, unit: "CM"),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C83FD), Color(0xFFA3A8F1)],
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      final age = _calculateAge(_dobController.text);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyAccountPage(
                            name: 'Stefani Wong',
                            age: age,
                            weight: _weightController.text,
                            height: _heightController.text,
                            gender: _selectedGender ?? 'Not set',
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Next", style: TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, color: Colors.white),
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWeightHeightField(String label, TextEditingController controller,
      {required IconData icon, required String unit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD8B4FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unit,
              style: const TextStyle(
                color: Colors.white,
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
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "Choose Gender",
          prefixIcon: const Icon(Icons.person_outline),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedGender,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
            items: _genders.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            hint: const Text("Select your gender"),
          ),
        ),
      ),
    );
  }
}
