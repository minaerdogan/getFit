import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _workouts = [
    'Abs Workout', // Or 'Abs Workout' if you prefer the full name
    'Full Body Workout', // Or 'Full Body Workout'
    'Lower Body Workout', // Or 'Lower Body Workout'
    // Add other workout categories as needed
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('getFit Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/saveWorkout');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/graph.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to getFit!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workouts.length,
                itemBuilder: (context, index) {
                  final workout = _workouts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(workout),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _workouts.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        String routeName = '';
                        if (workout == 'Abs Workout') {
                          routeName = '/abs_page';
                        } else if (workout == 'Full Body Workout') {
                          routeName = '/full_body_page';
                        } else if (workout == 'Lower Body Workout') {
                          routeName = '/lower_body_page';
                        } else {
                          // Handle other workout types or provide a default route
                          routeName = '/workout_details_page'; // Or some other default
                        }

                        if (routeName.isNotEmpty) {
                          Navigator.pushNamed(context, routeName);
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) async {
          if (_selectedIndex == index) return;
          setState(() => _selectedIndex = index);
          if (index == 1) {
            await Navigator.pushNamed(context, '/my_account');
            setState(() => _selectedIndex = 0);
          }
        },
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
      ),
    );
  }
}