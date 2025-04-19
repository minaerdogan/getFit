import 'package:flutter/material.dart';
import '../utils/textstyles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _workouts = [
    'Abs Workout',
    'Full Body Workout',
    'Lower Body Workout',
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
              Center(
                child: Text(
                  'Welcome to getFit!',
                  style: AppTextStyles.welcome,
                ),
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
                      title: Text(
                        workout,
                        style: AppTextStyles.listItem,
                      ),
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
                          routeName = '/workout_details_page';
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
