import 'package:flutter/material.dart';
import 'login.dart'; // Keep for the full edit page

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String _name = 'User Name'; // Placeholder
  int _age = 30; // Placeholder
  String _weight = '75'; // Placeholder
  String _height = '175'; // Placeholder
  String _gender = 'Male'; // Placeholder
  String? _profileImage; // To hold the profile image path
  // List of predefined images
  final List<String> _predefinedImages = [
    'assets/profile_image1.png',
    'assets/profile_image2.png',
    'assets/profile_image3.png',
    'assets/profile_image4.png',
    'assets/profile_image.png',
  ];
  bool _showPencilIcon = true; // Added state variable to control pencil visibility

  // *** VALIDATION FUNCTIONS (COPIED FROM personal_info_page.dart) ***
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null; // Valid
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
    if (fieldName == "Weight" && number > 260) {
      return '$fieldName cannot be greater than 260 KG';
    }
    if (fieldName == "Weight" && number < 25) {
      return '$fieldName cannot be smaller than 25 KG';
    }
    if (fieldName == "Height" && number > 250) {
      return '$fieldName cannot be greater than 250 CM';
    }
    if (fieldName == "Height" && number < 100) {
      return '$fieldName cannot be smaller than 100 CM';
    }
    return null; // Valid
  }

  Future<void> _showEditDialog(
      String title,
      String currentValue,
      Function(String) onValueChanged, {
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) async {
    TextEditingController controller = TextEditingController(text: currentValue);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: 'Enter new $title'),
            onSubmitted: (value) {
              if (validator == null || validator(value) == null) {
                onValueChanged(value);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(validator(value)!)),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (validator == null || validator(controller.text) == null) {
                  onValueChanged(controller.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(validator(controller.text)!)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editName() {
    _showEditDialog('Name', _name, (newValue) {
      setState(() {
        _name = newValue;
      });
    }, validator: (value) => _validateRequired(value, 'Name'));
  }

  void _editAge() {
    _showEditDialog('Age', _age.toString(), (newValue) {
      if (int.tryParse(newValue) != null &&
          int.parse(newValue) > 0 &&
          int.parse(newValue) < 110) {
        setState(() {
          _age = int.parse(newValue);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid age')),
        );
      }
    },
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Age cannot be empty';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number for age';
          }
          if (int.parse(value) <= 0 || int.parse(value) >= 110) {
            return 'Age must be between 1 and 119';
          }
          return null;
        });
  }

  void _editWeight() {
    _showEditDialog('Weight', _weight, (newValue) {
      final validationResult = _validatePositiveNumber(newValue, 'Weight');
      if (validationResult == null) {
        setState(() {
          _weight = newValue;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationResult)),
        );
      }
    },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) => _validatePositiveNumber(value, 'Weight'));
  }

  void _editHeight() {
    _showEditDialog('Height', _height, (newValue) {
      final validationResult = _validatePositiveNumber(newValue, 'Height');
      if (validationResult == null) {
        setState(() {
          _height = newValue;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationResult)),
        );
      }
    },
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) => _validatePositiveNumber(value, 'Height'));
  }

  void _editGender() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? selectedGender = _gender;
        return AlertDialog(
          title: const Text('Edit Gender'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Other'),
                    value: 'Other',
                    groupValue: selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (selectedGender?.isNotEmpty == true) {
                  setState(() {
                    _gender = selectedGender!;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a gender')),
                  );
                }
              },
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _gender = value;
        });
      }
    });
  }

  // Modified function to show image selection dialog
  Future<void> _showImageSelectionDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Profile Picture'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 images per row
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _predefinedImages.length,
              itemBuilder: (context, index) {
                final imagePath = _predefinedImages[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _profileImage = imagePath;
                      _showPencilIcon = false; // Hide the pencil icon after selection
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Stack(  // Use Stack to overlay the icon
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(imagePath),
                        radius: 40, // Adjust as needed
                      ),
                      if (index == 0 && _showPencilIcon) // Show pencil only on the first image and if _showPencilIcon is true
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Background for the icon
                              borderRadius: BorderRadius.circular(10), // Make it round
                            ),
                            padding: const EdgeInsets.all(2), // Padding for the icon
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.blue, // Icon color
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false, // Removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: _signOut,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Modified
            Row(
              children: [
                GestureDetector(
                  // Use the new function here
                  onTap: _showImageSelectionDialog,
                  child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: _profileImage != null
                              ? AssetImage(_profileImage!)
                              : const AssetImage('assets/profile_image.png'),
                        ),
                        if (_showPencilIcon)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ),
                          )
                      ]
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildEditableInfoBox('Name', _name, Icons.edit, _editName), // Added _editName
            _buildEditableInfoBox('Age', '$_age', Icons.edit, _editAge),
            _buildEditableInfoBox('Weight', '${_weight}kg', Icons.edit,
                _editWeight),
            _buildEditableInfoBox('Height', '${_height}cm', Icons.edit,
                _editHeight),
            _buildEditableInfoBox('Gender', _gender, Icons.edit, _editGender),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF7C83FD),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildEditableInfoBox(
      String title, String value, IconData icon, VoidCallback onEdit) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Row(
            children: [
              Text(
                value,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: Icon(icon, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

