import 'package:flutter/material.dart';
import 'donate_screen.dart';
import 'request_screen.dart';

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
    const Center(child: Text('Profile Coming Soon')),
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
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello, Sakshi! 👋',
                        style: TextStyle(
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B6D11),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatCard('12', 'Available\nNearby',
                      Icons.food_bank,
                      const Color(0xFF3B6D11),
                      const Color(0xFFEAF3DE)),
                  const SizedBox(width: 10),
                  _buildStatCard('3', 'Expiring\nSoon',
                      Icons.timer_outlined,
                      const Color(0xFF633806),
                      const Color(0xFFFAEEDA)),
                  const SizedBox(width: 10),
                  _buildStatCard('47', 'Meals\nRescued',
                      Icons.favorite_outline,
                      const Color(0xFF0C447C),
                      const Color(0xFFE6F1FB)),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Browse by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27500A),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildChip('All', true),
                    _buildChip('Cooked', false),
                    _buildChip('Raw', false),
                    _buildChip('Packed', false),
                    _buildChip('Urgent', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Available Near You',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27500A),
                ),
              ),
              const SizedBox(height: 10),
              _buildFoodCard('Biryani + Dal Fry',
                  'Hotel Shree Krishna • 0.4 km',
                  '15 portions', 'Expires in 3h 20m', false),
              _buildFoodCard('Mixed Vegetables',
                  'Bhaji Market • 1.1 km',
                  '5 kg', 'Expires in 1h 45m', true),
              _buildFoodCard('Parle-G Biscuits',
                  'Akurdi Colony • 1.8 km',
                  '40 packets', 'Expires in 3 days', false),
              _buildFoodCard('Rice + Sabzi',
                  'Community Kitchen • 2.1 km',
                  '20 portions', 'Expires in 5h', false),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const DonateScreen()));
        },
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
                style:
                    TextStyle(fontSize: 11, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF3B6D11)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF3B6D11)
              : Colors.grey.shade300,
        ),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Colors.grey[700])),
    );
  }

  Widget _buildFoodCard(String name, String location,
      String quantity, String expiry, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFE24B4A)
              : Colors.grey.shade200,
          width: isUrgent ? 1.5 : 1,
        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a))),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE24B4A),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Text('Urgent',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(location,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600])),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(quantity,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B6D11),
                            fontWeight: FontWeight.w500)),
                    Text(expiry,
                        style: TextStyle(
                            fontSize: 11,
                            color: isUrgent
                                ? const Color(0xFFE24B4A)
                                : Colors.grey[500])),
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