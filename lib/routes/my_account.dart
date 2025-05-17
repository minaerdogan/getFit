import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  String _name = 'Loading...';
  int _age = 0;
  String _weight = 'Loading...';
  String _height = 'Loading...';
  String _gender = 'Loading...';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// 🔎 **Firestore'dan Verileri Çekme**
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;

      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          setState(() {
            _name = doc.data()?['name'] ?? 'Not Provided';

            // 🔥 Yaş kontrolü ve dönüşümü
            var ageData = doc.data()?['age'];
            _age = (ageData is int) ? ageData : int.tryParse(ageData.toString()) ?? 0;

            // 🔥 Kilo ve Boy kontrolü ve dönüşümü
            var weightData = doc.data()?['weight'];
            var heightData = doc.data()?['height'];

            // Eğer sayı olarak gelmişse direkt, string ise parse edelim
            _weight = (weightData is int || weightData is double)
                ? weightData.toString()
                : weightData ?? '0';

            _height = (heightData is int || heightData is double)
                ? heightData.toString()
                : heightData ?? '0';

            _gender = doc.data()?['gender'] ?? 'Not Provided';
          });
        }
      } catch (e) {
        print('Firestore read error: $e');
      }
    }
  }
  /// 🔥 **Veriyi Firestore'a Güncelleme**
  Future<void> _updateFirestore(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // 🛠️ Eğer alan weight, height veya age ise, sayıya çevirip kaydet
        if (field == 'weight' || field == 'height') {
          if (value is String) {
            value = int.tryParse(value) ?? double.tryParse(value) ?? 0;
          }
        }

        if (field == 'age') {
          if (value is String) {
            value = int.tryParse(value) ?? 0;
          }
        }

        await _firestore.collection('users').doc(user.uid).update({field: value});
        print('$field güncellendi!');
        _fetchUserData(); // Verileri güncelledikten sonra tekrar çek
      } catch (e) {
        print("Güncellenirken hata oluştu: $e");
      }
    }
  }
  /// 🔄 **Edit İşlemi**
  Future<void> _editDialog(String title, String field, dynamic currentValue) async {
    TextEditingController controller = TextEditingController(text: currentValue.toString());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            keyboardType: (field == 'age' || field == 'weight' || field == 'height')
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(hintText: 'Enter new $title'),
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
                final newValue = controller.text;
                setState(() {
                  if (field == 'age' || field == 'weight' || field == 'height') {
                    if (int.tryParse(newValue) != null) {
                      _updateFirestore(field, int.parse(newValue));
                    } else if (double.tryParse(newValue) != null) {
                      _updateFirestore(field, double.parse(newValue));
                    }
                  } else {
                    _updateFirestore(field, newValue);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEditableInfoBox('Name', _name, Icons.edit, () => _editDialog('Name', 'name', _name)),
            _buildEditableInfoBox('Age', '$_age', Icons.edit, () => _editDialog('Age', 'age', _age)),
            _buildEditableInfoBox('Weight', '${_weight} kg', Icons.edit, () => _editDialog('Weight', 'weight', _weight)),
            _buildEditableInfoBox('Height', '${_height} cm', Icons.edit, () => _editDialog('Height', 'height', _height)),
            _buildEditableInfoBox('Gender', _gender, Icons.edit, () => _editDialog('Gender', 'gender', _gender)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoBox(String title, String value, IconData icon, VoidCallback onEdit) {
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
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
