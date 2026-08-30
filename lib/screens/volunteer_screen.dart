import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});
  @override
  State<VolunteerScreen> createState() =>
      _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _acceptDelivery(
      String docId, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('food_listings')
          .doc(docId)
          .update({
        'status': 'accepted',
        'volunteer_uid': user.uid,
        'volunteer_name':
            user.displayName ?? 'Volunteer',
        'accepted_at':
            FieldValue.serverTimestamp(),
      });
      _showSnack(
          'Delivery accepted! Navigate to donor. ✅');
    } catch (e) {
      _showSnack('Error! Try again.');
    }
  }

  Future<void> _rejectDelivery(String docId) async {
    _showSnack('Request rejected.');
  }

  Future<void> _markDelivered(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('food_listings')
          .doc(docId)
          .update({
        'status': 'delivered',
        'delivered_at': FieldValue.serverTimestamp(),
      });
      _showSnack('Delivery confirmed! Great job! 🎉');
    } catch (e) {
      _showSnack('Error! Try again.');
    }
  }

  void _showAcceptDialog(
      String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Delivery?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Food: ${data['title'] ?? ''}',
                style: const TextStyle(
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(
                'Quantity: ${data['quantity']} ${data['unit']}'),
            Text(
                'Pickup: ${data['pickup_time'] ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptDelivery(docId, data);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B6D11),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8)),
            ),
            child: const Text('Accept',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text(
          'Volunteer',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Available Pickups'),
            Tab(text: 'My Deliveries'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailablePickups(),
          _buildMyDeliveries(),
        ],
      ),
    );
  }

  Widget _buildAvailablePickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('food_listings')
          .where('status', isEqualTo: 'available')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF3B6D11)));
        }

        final docs = snapshot.data?.docs ?? [];

        return Column(
          children: [
            // Stats
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _buildVolStat(
                      '${docs.length}',
                      'Available\nNow',
                      Icons.delivery_dining,
                      const Color(0xFF3B6D11)),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200),
                  _buildVolStat('4.8', 'My\nRating',
                      Icons.star,
                      const Color(0xFFFFD700)),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200),
                  _buildVolStat('${docs.length}',
                      'Near\nMe', Icons.location_on,
                      const Color(0xFF0C447C)),
                ],
              ),
            ),

            if (docs.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No pickups available right now!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data()
                        as Map<String, dynamic>;
                    return _buildPickupCard(
                        doc.id, data);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPickupCard(
      String docId, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['title'] ?? 'Food Item',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  data['category'] ?? '',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3B6D11),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${data['quantity']} ${data['unit']}',
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 14, color: Color(0xFF3B6D11)),
              const SizedBox(width: 4),
              Text(
                data['pickup_time'] ?? '',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              OutlinedButton(
                onPressed: () =>
                    _rejectDelivery(docId),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Reject',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () =>
                    _showAcceptDialog(docId, data),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF3B6D11),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8)),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Accept',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyDeliveries() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
          child: Text('Please login first!'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('food_listings')
          .where('volunteer_uid', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF3B6D11)));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining,
                    size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('No deliveries yet!',
                    style:
                        TextStyle(color: Colors.grey)),
                Text('Accept pickups to get started!',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data =
                doc.data() as Map<String, dynamic>;
            final status =
                data['status'] ?? 'accepted';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['title'] ?? 'Food Item',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a)),
                      ),
                      Container(
                        padding: const EdgeInsets
                            .symmetric(
                                horizontal: 10,
                                vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'delivered'
                              ? const Color(0xFFEAF3DE)
                              : const Color(0xFFE6F1FB),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          status == 'delivered'
                              ? 'Delivered ✅'
                              : 'Accepted 🚴',
                          style: TextStyle(
                              fontSize: 12,
                              color: status ==
                                      'delivered'
                                  ? const Color(
                                      0xFF3B6D11)
                                  : const Color(
                                      0xFF0C447C),
                              fontWeight:
                                  FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${data['quantity']} ${data['unit']}',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pickup: ${data['pickup_time'] ?? ''}',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600]),
                  ),
                  if (status == 'accepted') ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _markDelivered(doc.id),
                        icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16),
                        label: const Text(
                          'Mark as Delivered',
                          style: TextStyle(
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF3B6D11),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVolStat(String value, String label,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600])),
      ],
    );
  }
}