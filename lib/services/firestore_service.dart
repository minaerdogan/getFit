import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 **Kullanıcı Bilgilerini Kaydetme**
  Future<void> saveUserData({
    required String name,
    required String dob,
    required int age,
    required String weight,
    required String height,
    required String gender,
  }) async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'name': name,                      // 👈 İsim bilgisi eklendi
          'dob': dob,
          'age': age,
          'weight': weight,
          'height': height,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("Kullanıcı bilgileri Firestore'a kaydedildi: $name");
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  /// 🔹 **Kullanıcı Bilgilerini Getir**
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          print("Kullanıcı bilgileri alındı: ${doc.data()}");
          return doc.data();
        } else {
          print("Kullanıcı bilgisi bulunamadı.");
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }
}