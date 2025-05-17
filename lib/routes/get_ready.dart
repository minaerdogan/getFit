import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proje/utils/colors.dart';

class GetReadyScreen extends StatefulWidget {
  const GetReadyScreen({super.key});

  @override
  State<GetReadyScreen> createState() => _GetReadyScreenState();
}

class _GetReadyScreenState extends State<GetReadyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  /// 🔎 **Firestore'dan Kullanıcı İsmini Çekme**
  Future<void> _fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;

      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          setState(() {
            _userName = doc.data()?['name'] ?? 'User';
          });
        }
      } catch (e) {
        print('Firestore read error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Image.asset(
                  'assets/get_ready_graphic.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              /// 🔥 **Kullanıcı İsmi Gösteriliyor**
              Text(
                'Welcome, $_userName',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'You are all set now, let’s reach your goals together with us',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home_screen'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.classicButtonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Go To Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

