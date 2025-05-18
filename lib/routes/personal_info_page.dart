import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import '../utils/textstyles.dart';
import '../utils/colors.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔥 **Kullanıcı Adını Firebase'den Çekiyoruz**
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
      });
    }
  }

  /// 🔹 Age Hesaplama Fonksiyonu
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

  /// 🔹 Form Submit İşlemi
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final age = _calculateAge(_dobController.text);
      final weight = _weightController.text;
      final height = _heightController.text;
      final gender = _selectedGender ?? "";
      final name = _nameController.text;

      print('Form is valid!');
      print('Name: $name');
      print('DOB: ${_dobController.text}, Age: $age');
      print('Weight: $weight KG');
      print('Height: $height CM');
      print('Gender: $gender');

      // 🔎 Firestore Kayıt Kontrolü
      try {
        await _firestoreService.saveUserData(
          name: name,
          dob: _dobController.text,
          age: age,
          weight: weight,
          height: height,
          gender: gender,
        );
        print("Veri başarılı şekilde kaydedildi!");
      } catch (e) {
        print("Firestore'a kayıt yapılırken hata oluştu: $e");
      }

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

  /// 🔹 Arayüz Tasarımı
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
                const SizedBox(height: 20),
                _buildTextField(
                  "Full Name",
                  _nameController,
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                ),
                _buildGenderDropdown(),
                _buildTextField(
                  "Date of Birth (yyyy-mm-dd)",
                  _dobController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.datetime,
                ),
                _buildWeightHeightField(
                  "Your Weight",
                  _weightController,
                  icon: Icons.monitor_weight,
                  unit: "KG",
                ),
                _buildWeightHeightField(
                  "Your Height",
                  _heightController,
                  icon: Icons.height,
                  unit: "CM",
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 TextField Builder
  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, TextInputType? keyboardType}) {
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
          ),
        ),
      ),
    );
  }

  /// 🔹 Dropdown Builder
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(labelText: "Choose Gender"),
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
    );
  }

  /// 🔹 Weight/Height Field Builder
  Widget _buildWeightHeightField(
      String label,
      TextEditingController controller, {
        required IconData icon,
        required String unit,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTextField(label, controller, icon: icon, keyboardType: TextInputType.number),
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
          ),
        ],
      ),
    );
  }
}