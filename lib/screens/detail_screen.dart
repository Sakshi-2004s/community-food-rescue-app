import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> food;
  const DetailScreen({super.key, required this.food});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isClaimed = false;
  bool _isLoading = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ✅ Real Google Maps Directions
  Future<void> _openDirections() async {
    final location = widget.food['location'] ?? 'Pune';
    final query = Uri.encodeComponent(location);
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Could not open Google Maps!');
    }
  }

  // ✅ Real Share
  void _shareFood() {
    final food = widget.food;
    Share.share(
      '🍱 Free Food Available!\n\n'
      '${food['name']}\n'
      '📦 Quantity: ${food['quantity']}\n'
      '📍 Location: ${food['location']}\n'
      '⏰ Pickup: ${food['expiry']}\n\n'
      'Download Community Food Rescue App to claim!',
      subject: 'Free Food: ${food['name']}',
    );
  }

  // ✅ Real Firebase Claim
  Future<void> _claimFood() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Please login first!');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final listingId = widget.food['id'];
      await FirebaseFirestore.instance
          .collection('food_listings')
          .doc(listingId)
          .update({
        'status': 'claimed',
        'claimed_by': user.uid,
        'claimed_at': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('claims')
          .add({
        'listing_id': listingId,
        'receiver_uid': user.uid,
        'status': 'pending',
        'claimed_at': FieldValue.serverTimestamp(),
        'food_name': widget.food['name'],
      });
      setState(() => _isClaimed = true);
      _showSnack('Food claimed successfully! 🎉');
    } catch (e) {
      _showSnack('Error! Try again.');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final listingId = food['id'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text('Food Details',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        iconTheme:
            const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share,
                color: Colors.white),
            onPressed: _shareFood, // ✅ Real share!
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: listingId != null
            ? FirebaseFirestore.instance
                .collection('food_listings')
                .doc(listingId)
                .snapshots()
            : null,
        builder: (context, snapshot) {
          bool alreadyClaimed = _isClaimed;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data()
                as Map<String, dynamic>;
            if (data['status'] == 'claimed') {
              alreadyClaimed = true;
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  color: food['urgent'] == true
                      ? const Color(0xFFfcebeb)
                      : const Color(0xFFEAF3DE),
                  child: Icon(Icons.fastfood,
                      size: 100,
                      color: food['urgent'] == true
                          ? const Color(0xFFE24B4A)
                          : const Color(0xFF3B6D11)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              food['name'] ?? 'Food Item',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a1a1a)),
                            ),
                          ),
                          if (food['urgent'] == true)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE24B4A),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: const Text('Urgent',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _infoCard(
                              Icons.scale_outlined,
                              'Quantity',
                              food['quantity'] ?? '-',
                              const Color(0xFFEAF3DE),
                              const Color(0xFF3B6D11)),
                          const SizedBox(width: 10),
                          _infoCard(
                              Icons.category_outlined,
                              'Category',
                              food['category'] ?? '-',
                              const Color(0xFFE6F1FB),
                              const Color(0xFF0C447C)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _infoCard(
                              Icons.timer_outlined,
                              'Expiry',
                              food['expiry'] ?? '-',
                              food['urgent'] == true
                                  ? const Color(0xFFfcebeb)
                                  : const Color(0xFFFAEEDA),
                              food['urgent'] == true
                                  ? const Color(0xFFE24B4A)
                                  : const Color(0xFF633806)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFEAF3DE),
                                borderRadius:
                                    BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.person,
                                  color: Color(0xFF3B6D11)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Donor',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey)),
                                  const Text(
                                      'Community Member',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.bold,
                                          color: Color(
                                              0xFF1a1a1a))),
                                  Row(
                                    children: List.generate(
                                        5,
                                        (i) => const Icon(
                                            Icons.star,
                                            color: Color(
                                                0xFFEF9F27),
                                            size: 14)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ✅ Real Directions button
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFFE24B4A),
                                size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                food['location'] ?? 'Near you',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1a1a1a)),
                              ),
                            ),
                            TextButton(
                              onPressed:
                                  _openDirections, // ✅ Real!
                              child: const Text('Directions',
                                  style: TextStyle(
                                      color: Color(0xFF0C447C),
                                      fontWeight:
                                          FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      alreadyClaimed
                          ? Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFEAF3DE),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.check_circle,
                                      color:
                                          Color(0xFF3B6D11),
                                      size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                      'Food Claimed Successfully!',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.bold,
                                          color: Color(
                                              0xFF3B6D11))),
                                  SizedBox(height: 4),
                                  Text(
                                      'Contact donor for pickup details.',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey)),
                                ],
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _claimFood,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                              color:
                                                  Colors.white,
                                              strokeWidth: 2))
                                  : const Icon(
                                      Icons
                                          .shopping_bag_outlined,
                                      color: Colors.white),
                              label: const Text('Claim This Food',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF3B6D11),
                                minimumSize: const Size(
                                    double.infinity, 54),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            12)),
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(IconData icon, String label,
      String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: textColor)),
                  Text(value,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}