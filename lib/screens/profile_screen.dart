import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled =
          prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notificationsEnabled = val);
    _showSnack(val
        ? 'Notifications enabled! 🔔'
        : 'Notifications disabled! 🔕');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text(
            'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpPage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Help & Support',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27500A))),
              const SizedBox(height: 20),
              _buildFAQ(
                'How do I donate food?',
                'Tap the Donate tab, fill in food details, add a photo and submit. Your listing will be visible to receivers nearby.',
              ),
              _buildFAQ(
                'How do I claim food?',
                'Go to Request tab, browse available food near you, tap on a listing and click "Claim This Food".',
              ),
              _buildFAQ(
                'How do volunteers work?',
                'Volunteers pick up food from donors and deliver to receivers. Go to Volunteer tab to accept pickup requests.',
              ),
              _buildFAQ(
                'How are badges earned?',
                'First Donation: donate 1 item. 10 Meals Hero: donate 10 items. Community Champion: donate 50 items.',
              ),
              _buildFAQ(
                'What is Impact Score?',
                'Every donation earns you 100 points. More donations = higher score!',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text('Contact Us',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27500A))),
                    SizedBox(height: 8),
                    Text(
                        'Email: support@foodrescue.com',
                        style: TextStyle(
                            color: Color(0xFF3B6D11))),
                    Text('Phone: +91 98765 43210',
                        style: TextStyle(
                            color: Color(0xFF3B6D11))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return ExpansionTile(
      title: Text(question,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF27500A))),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(answer,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey[700])),
        ),
      ],
    );
  }

  void _showEditProfile() {
    final nameController = TextEditingController(
        text: _user?.displayName ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF3B6D11)),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFF3B6D11),
                      width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _user?.updateDisplayName(
                    nameController.text.trim());
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
                _showSnack('Profile updated! ✅');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF3B6D11),
                minimumSize:
                    const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10)),
              ),
              child: const Text('Save Changes',
                  style:
                      TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Real badges based on donation count
  List<Map<String, dynamic>> _getBadges(int donationCount) {
    return [
      {
        'title': 'First Donation',
        'icon': Icons.star,
        'color': const Color(0xFFFFD700),
        'desc': 'Donate 1 item',
        'earned': donationCount >= 1,
        'requirement': 1,
      },
      {
        'title': '10 Meals Hero',
        'icon': Icons.favorite,
        'color': const Color(0xFFE24B4A),
        'desc': 'Donate 10 items',
        'earned': donationCount >= 10,
        'requirement': 10,
      },
      {
        'title': 'Community Helper',
        'icon': Icons.people,
        'color': const Color(0xFF3B6D11),
        'desc': 'Donate 25 items',
        'earned': donationCount >= 25,
        'requirement': 25,
      },
      {
        'title': 'Super Volunteer',
        'icon': Icons.directions_bike,
        'color': const Color(0xFF0C447C),
        'desc': 'Donate 50 items',
        'earned': donationCount >= 50,
        'requirement': 50,
      },
      {
        'title': '50 Meals Hero',
        'icon': Icons.emoji_events,
        'color': const Color(0xFF633806),
        'desc': 'Donate 75 items',
        'earned': donationCount >= 75,
        'requirement': 75,
      },
      {
        'title': 'Community Champion',
        'icon': Icons.military_tech,
        'color': const Color(0xFFFFD700),
        'desc': 'Donate 100 items',
        'earned': donationCount >= 100,
        'requirement': 100,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.displayName ?? 'User';
    final email = _user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text('My Profile',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: Colors.white),
            onPressed: _showEditProfile,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_listings')
            .where('donor_uid', isEqualTo: _user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final donationCount =
              snapshot.data?.docs.length ?? 0;
          final points = donationCount * 100;
          final allBadges = _getBadges(donationCount);
          final earnedBadges = allBadges
              .where((b) => b['earned'] == true)
              .toList();
          final lockedBadges = allBadges
              .where((b) => b['earned'] == false)
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B6D11),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white,
                                  width: 3),
                            ),
                            child: _user?.photoURL != null
                                ? ClipOval(
                                    child: Image.network(
                                      _user!.photoURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 50,
                                    color: Color(
                                        0xFF3B6D11)),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showSnack(
                                  'Photo upload coming soon!'),
                              child: Container(
                                padding:
                                    const EdgeInsets.all(6),
                                decoration:
                                    const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color:
                                        Color(0xFF3B6D11)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text('Donor',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w500)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Impact Score
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Color(0xFFFFD700),
                            size: 32),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Impact Score',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey)),
                            Text('$points Points',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Color(
                                        0xFF27500A))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatBox(
                          '$donationCount',
                          'Meals\nDonated',
                          Icons.volunteer_activism,
                          const Color(0xFF3B6D11),
                          const Color(0xFFEAF3DE)),
                      const SizedBox(width: 10),
                      _buildStatBox(
                          '0',
                          'Meals\nReceived',
                          Icons.food_bank,
                          const Color(0xFF0C447C),
                          const Color(0xFFE6F1FB)),
                      const SizedBox(width: 10),
                      _buildStatBox(
                          '0',
                          'Deliveries',
                          Icons.directions_bike,
                          const Color(0xFF633806),
                          const Color(0xFFFAEEDA)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Real Badges
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('My Badges',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27500A))),
                      const SizedBox(height: 12),

                      // Earned
                      if (earnedBadges.isNotEmpty) ...[
                        const Text('Earned ✅',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight:
                                    FontWeight.w500)),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: earnedBadges.length,
                          itemBuilder: (_, i) =>
                              _buildBadgeCard(
                                  earnedBadges[i], false),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF3DE),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                  Icons
                                      .volunteer_activism,
                                  color:
                                      Color(0xFF3B6D11)),
                              SizedBox(width: 8),
                              Text(
                                'Donate food to earn your first badge!',
                                style: TextStyle(
                                    color:
                                        Color(0xFF3B6D11),
                                    fontWeight:
                                        FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Locked
                      if (lockedBadges.isNotEmpty) ...[
                        const Text('Locked 🔒',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight:
                                    FontWeight.w500)),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: lockedBadges.length,
                          itemBuilder: (_, i) =>
                              _buildBadgeCard(
                                  lockedBadges[i], true),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Settings with real Notifications toggle
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Settings',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27500A))),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            // ✅ Notifications Toggle
                            ListTile(
                              leading: Icon(
                                  Icons
                                      .notifications_outlined,
                                  color: _notificationsEnabled
                                      ? const Color(
                                          0xFF3B6D11)
                                      : Colors.grey),
                              title: const Text(
                                  'Notifications',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w500,
                                      color: Color(
                                          0xFF27500A))),
                              subtitle: Text(
                                  _notificationsEnabled
                                      ? 'Food alerts enabled'
                                      : 'Notifications off',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.grey[500])),
                              trailing: Switch(
                                value: _notificationsEnabled,
                                onChanged:
                                    _toggleNotifications,
                                activeColor:
                                    const Color(0xFF3B6D11),
                              ),
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.shade200),
                            // ✅ Help Page
                            ListTile(
                              leading: const Icon(
                                  Icons.help_outline,
                                  color: Color(0xFF27500A)),
                              title: const Text(
                                  'Help & Support',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w500,
                                      color: Color(
                                          0xFF27500A))),
                              subtitle: Text('FAQs, contact us',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.grey[500])),
                              trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400]),
                              onTap: _showHelpPage,
                            ),
                            Divider(
                                height: 1,
                                color: Colors.grey.shade200),
                            // Logout
                            ListTile(
                              leading: const Icon(
                                  Icons.logout,
                                  color: Colors.red),
                              title: const Text('Logout',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w500,
                                      color: Colors.red)),
                              subtitle: Text(
                                  'Sign out of your account',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.grey[500])),
                              trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400]),
                              onTap: _showLogoutDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadgeCard(
      Map<String, dynamic> badge, bool locked) {
    final color =
        locked ? Colors.grey : badge['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: locked
            ? Colors.grey.shade100
            : (badge['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: locked
                ? Colors.grey.shade300
                : (badge['color'] as Color).withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            locked
                ? Icons.lock_outlined
                : badge['icon'] as IconData,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(badge['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: locked
                      ? Colors.grey
                      : const Color(0xFF1a1a1a))),
          const SizedBox(height: 2),
          Text(badge['desc'],
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9,
                  color: locked
                      ? Colors.grey
                      : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatBox(String number, String label,
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
            Icon(icon, color: textColor, size: 22),
            const SizedBox(height: 6),
            Text(number,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10, color: textColor)),
          ],
        ),
      ),
    );
  }
}