import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'donate_screen.dart';
import 'request_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'volunteer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeDashboard(),
    const DonateScreen(),
    const RequestScreen(),
    const HistoryScreen(),
    const VolunteerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF3B6D11),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism),
            label: 'Donate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            activeIcon: Icon(Icons.food_bank),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike_outlined),
            activeIcon: Icon(Icons.directions_bike),
            label: 'Volunteer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});
  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All', 'Cooked Food', 'Raw Vegetables',
    'Packed Food', 'Beverages'
  ];

  Stream<QuerySnapshot> _getStream() {
    if (_selectedCategory == 'All') {
      return FirebaseFirestore.instance
          .collection('food_listings')
          .where('status', isEqualTo: 'available')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('food_listings')
          .where('status', isEqualTo: 'available')
          .where('category', isEqualTo: _selectedCategory)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $userName! 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27500A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let\'s rescue food today!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B6D11),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('food_listings')
                    .where('status', isEqualTo: 'available')
                    .snapshots(),
                builder: (context, snapshot) {
                  int available = 0;
                  int total = 0;
                  if (snapshot.hasData) {
                    available =
                        snapshot.data!.docs.length;
                    total = available;
                  }
                  return Row(
                    children: [
                      _buildStatCard(
                          '$available',
                          'Available\nNearby',
                          Icons.food_bank,
                          const Color(0xFF3B6D11),
                          const Color(0xFFEAF3DE)),
                      const SizedBox(width: 10),
                      _buildStatCard(
                          '2',
                          'Expiring\nSoon',
                          Icons.timer_outlined,
                          const Color(0xFF633806),
                          const Color(0xFFFAEEDA)),
                      const SizedBox(width: 10),
                      _buildStatCard(
                          '$total',
                          'Meals\nRescued',
                          Icons.favorite_outline,
                          const Color(0xFF0C447C),
                          const Color(0xFFE6F1FB)),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Category Filter
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16),
              child: const Text(
                'Browse by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27500A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isSelected =
                      _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(
                        () => _selectedCategory = cat),
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B6D11)
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B6D11)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16),
              child: const Text(
                'Available Near You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27500A),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Real Firebase Listings
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF3B6D11)));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                              Icons.food_bank_outlined,
                              size: 64,
                              color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            _selectedCategory == 'All'
                                ? 'No food available right now'
                                : 'No $_selectedCategory available',
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey),
                          ),
                          const Text(
                            'Be the first to donate!',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    itemCount:
                        snapshot.data!.docs.length,
                    itemBuilder: (_, i) {
                      final doc =
                          snapshot.data!.docs[i];
                      final data = doc.data()
                          as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              food: {
                                'id': doc.id,
                                'name':
                                    data['title'] ?? '',
                                'location': 'Near you',
                                'quantity':
                                    '${data['quantity']} ${data['unit']}',
                                'expiry':
                                    data['pickup_time'] ??
                                        '',
                                'category':
                                    data['category'] ??
                                        '',
                                'urgent': false,
                              },
                            ),
                          ),
                        ),
                        child: _buildFoodCard(
                            data, doc.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const DonateScreen()),
        ),
        backgroundColor: const Color(0xFF3B6D11),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Donate Food',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String number, String label,
      IconData icon, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(height: 6),
            Text(number,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
      Map<String, dynamic> data, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood,
                color: Color(0xFF3B6D11), size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? 'Food Item',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a)),
                ),
                const SizedBox(height: 4),
                Text(
                  data['category'] ?? '',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${data['quantity']} ${data['unit']}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3B6D11),
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      data['pickup_time'] ?? '',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}