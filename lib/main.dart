import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'listing_detail_screen.dart';
import 'live_map_screen.dart';
import 'request_food_screen.dart' as req;
import 'volunteer_screen.dart' as vol;

void main() {
=======
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
>>>>>>> feature/frontend-member1
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Food Rescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
<<<<<<< HEAD
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    req.RequestFoodScreen(),
    ListingDetailScreen(),
    LiveMapScreen(),
    vol.VolunteerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lunch_dining),
            label: 'Request',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Detail'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Volunteer',
          ),
        ],
      ),
    );
  }
}
=======
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B6D11)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
>>>>>>> feature/frontend-member1
