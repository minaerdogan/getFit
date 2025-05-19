import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:google_sign_in/google_sign_in.dart'; // Import GoogleSignIn
import 'login.dart'; // Keep for the full edit page

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String _name = 'Loading...'; // Default while loading
  int _age = 0; // Default while loading
  String _weight = 'Loading...'; // Default while loading
  String _height = 'Loading...'; // Default while loading
  String _gender = 'Loading...'; // Default while loading
  String? _profileImage; // To hold the profile image path (will need to save/load this too)

  bool _isLoading = true; // To show a loading indicator for initial fetch
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // List of predefined images (You'll need to save the selected image path to Firestore)
  final List<String> _predefinedImages = [
    'assets/profile_image1.png',
    'assets/profile_image2.png',
    'assets/profile_image3.png',
    'assets/profile_image4.png',
    'assets/profile_image.png', // Default placeholder
  ];
  // Assuming 'assets/profile_image.png' is the default if none is selected/saved

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page initializes
  }

  // *** Fetch user data from Firestore ***
  Future<void> _fetchUserData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            // Update state variables with fetched data
            _name = data['name'] ?? 'User Name'; // Use default if null
            _age = data['age'] ?? 0;
            _weight = data['weight']?.toString() ?? 'N/A'; // Convert to string, handle null
            _height = data['height']?.toString() ?? 'N/A'; // Convert to string, handle null
            _gender = data['gender'] ?? 'Not specified';
            _profileImage = data['profileImage'] ?? 'assets/profile_image.png'; // Fetch profile image path
          });
        } else {
          print('User document not found in Firestore.');
          setState(() {
            // Set default placeholders if document not found
            _name = 'User Name';
            _age = 0;
            _weight = 'N/A';
            _height = 'N/A';
            _gender = 'Not specified';
            _profileImage = 'assets/profile_image.png';
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        // Optionally show an error to the user
        setState(() {
          // Set default placeholders on error
          _name = 'Error';
          _age = 0;
          _weight = 'Error';
          _height = 'Error';
          _gender = 'Error';
          _profileImage = 'assets/profile_image.png';
        });
      }
    } else {
      print('No authenticated user found.');
      setState(() {
        // Set default placeholders if no user logged in
        _name = 'Not Logged In';
        _age = 0;
        _weight = 'N/A';
        _height = 'N/A';
        _gender = 'Not specified';
        _profileImage = 'assets/profile_image.png';
      });
      // Consider navigating back to login if no user is authenticated
      // if(mounted) Navigator.pushReplacementNamed(context, '/login');
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  // *** Update user data in Firestore ***
  Future<void> _updateUserData(Map<String, dynamic> dataToUpdate) async {
    if (currentUser != null) {
      try {
        await _firestore.collection('users').doc(currentUser!.uid).update(dataToUpdate);
        print('User data updated in Firestore: $dataToUpdate');
        // Optionally show a success message
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        print('Error updating user data: $e');
        // Optionally show an error message
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
          );
        }
        // Re-fetch data to revert local state if update failed
        _fetchUserData();
      }
    } else {
      print('Error: Cannot update data, no user logged in.');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
      }
    }
  }


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
    if (fieldName == "Weight" && (number > 260 || number < 25)) {
      return '$fieldName must be between 25 KG and 260 KG';
    }
    if (fieldName == "Height" && (number > 250 || number < 100)) {
      return '$fieldName must be between 100 CM and 250 CM';
    }
    return null; // Valid
  }

  Future<void> _showEditDialog(
      String title,
      String currentValue,
      Function(String) onValueChanged, // This will now also trigger Firestore update
          {
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        Map<String, dynamic> Function(String)? getDataToUpdate, // Function to get data for Firestore
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
            onSubmitted: (value) async { // Made async to await Firestore update
              if (validator == null || validator(value) == null) {
                onValueChanged(value); // Update local state
                if (getDataToUpdate != null) {
                  await _updateUserData(getDataToUpdate(value)); // Update Firestore
                }
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
              onPressed: () async { // Made async to await Firestore update
                if (validator == null || validator(controller.text) == null) {
                  onValueChanged(controller.text); // Update local state
                  if (getDataToUpdate != null) {
                    await _updateUserData(getDataToUpdate(controller.text)); // Update Firestore
                  }
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

  // Modified edit functions to call _updateUserData
  void _editName() {
    _showEditDialog(
      'Name',
      _name,
          (newValue) {
        setState(() {
          _name = newValue;
        });
      },
      validator: (value) => _validateRequired(value, 'Name'),
      getDataToUpdate: (value) => {'name': value}, // Data for Firestore
    );
  }

  void _editAge() {
    _showEditDialog(
      'Age',
      _age.toString(),
          (newValue) {
        if (int.tryParse(newValue) != null &&
            int.parse(newValue) > 0 &&
            int.parse(newValue) < 110) {
          setState(() {
            _age = int.parse(newValue);
          });
        } else {
          // Validation is handled by the validator now, so this might be redundant
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
        int age = int.parse(value);
        if (age <= 0 || age >= 110) {
          return 'Age must be between 1 and 109'; // Corrected range based on typical age
        }
        return null;
      },
      getDataToUpdate: (value) => {'age': int.tryParse(value) ?? 0}, // Data for Firestore
    );
  }

  void _editWeight() {
    _showEditDialog(
      'Weight',
      _weight,
          (newValue) {
        setState(() {
          _weight = newValue;
        });
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) => _validatePositiveNumber(value, 'Weight'),
      getDataToUpdate: (value) => {'weight': value}, // Data for Firestore
    );
  }

  void _editHeight() {
    _showEditDialog(
      'Height',
      _height,
          (newValue) {
        setState(() {
          _height = newValue;
        });
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) => _validatePositiveNumber(value, 'Height'),
      getDataToUpdate: (value) => {'height': value}, // Data for Firestore
    );
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
              onPressed: () async { // Made async to await Firestore update
                if (selectedGender?.isNotEmpty == true) {
                  // Only update if different from current value to avoid unnecessary writes
                  if (selectedGender != _gender) {
                    setState(() {
                      _gender = selectedGender!;
                    });
                    await _updateUserData({'gender': selectedGender}); // Update Firestore
                  }
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
    ); // No .then() needed here as async/await is used in onPressed
  }

  // Modified function to show image selection dialog and save selection
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
                  onTap: () async { // Made async to await Firestore update
                    setState(() {
                      _profileImage = imagePath;
                      // We don't need _showPencilIcon state anymore if we always show it
                      // on the currently selected image or a default.
                    });
                    await _updateUserData({'profileImage': imagePath}); // Save selected image path
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(imagePath),
                    radius: 40, // Adjust as needed
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
    // Show loading indicator if you have one on the page level
    // setState(() { _isLoading = true; }); // Example

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Check if the current user is signed in with Google
      final currentUser = auth.currentUser;
      final providerData = currentUser?.providerData;
      final isGoogleSignedIn = providerData?.any((info) => info.providerId == 'google.com') ?? false;

      if (isGoogleSignedIn) {
        // Sign out from Google
        await googleSignIn.signOut();
      }

      // Sign out from Firebase
      await auth.signOut();

      // Navigate to the login screen and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    } finally {
      // Hide loading indicator
      // setState(() { _isLoading = false; }); // Example
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: _showImageSelectionDialog,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        // Use _profileImage state for the image
                        backgroundImage: _profileImage != null
                            ? AssetImage(_profileImage!)
                            : const AssetImage('assets/profile_image.png'), // Fallback
                      ),
                      // Always show pencil icon on the profile picture itself
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name, // Display fetched name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // You might want to display email or other info here
                      // if available in your Firestore document
                      Text(
                        currentUser?.email ?? 'No Email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Display fetched data in info boxes
            _buildEditableInfoBox('Age', '$_age', Icons.edit, _editAge),
            _buildEditableInfoBox('Weight', '${_weight}kg', Icons.edit, _editWeight),
            _buildEditableInfoBox('Height', '${_height}cm', Icons.edit, _editHeight),
            _buildEditableInfoBox('Gender', _gender, Icons.edit, _editGender),
            _buildEditableInfoBox('Name', _name, Icons.edit, _editName), // Moved name here for consistency
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Assuming Account is the second item (index 1)
        selectedItemColor: const Color(0xFF7C83FD),
        unselectedItemColor: Colors.grey, // Add unselected color for clarity
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
            // Navigate to home, replacing the current route
            Navigator.pushReplacementNamed(context, '/home_screen');
          }
          // If index is 1 (Account), do nothing as we are already on this page
        },
      ),
    );
  }

  // _buildEditableInfoBox remains the same, it uses the state variables
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

// _buildTextField, _buildWeightHeightField, _buildGenderDropdown are not needed here
// as editing is done via dialogs, not inline text fields.
}
