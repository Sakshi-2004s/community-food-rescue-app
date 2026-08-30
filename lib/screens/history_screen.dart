import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text('My Activity',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'My Donations'),
            Tab(text: 'My Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _MyDonationsTab(),
          const _MyRequestsTab(),
        ],
      ),
    );
  }
}

class _MyDonationsTab extends StatelessWidget {
  const _MyDonationsTab();

  Color _statusColor(String status) {
    switch (status) {
      case 'available': return const Color(0xFF3B6D11);
      case 'claimed': return const Color(0xFF0C447C);
      case 'delivered': return const Color(0xFF2E7D32);
      case 'expired': return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'available': return 'Live';
      case 'claimed': return 'Claimed';
      case 'delivered': return 'Delivered';
      case 'expired': return 'Expired/Cancelled';
      default: return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'available': return Icons.radio_button_checked;
      case 'claimed': return Icons.handshake_outlined;
      case 'delivered': return Icons.check_circle_outline;
      default: return Icons.timer_off_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please login!'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('food_listings')
          .where('donor_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B6D11)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.volunteer_activism_outlined,
            message: 'No donations yet',
            subtitle: 'Start donating food to see history here!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            // ✅ Safe data read — no crash
            Map<String, dynamic> data = {};
            try {
              data = doc.data() as Map<String, dynamic>;
            } catch (e) {
              return const SizedBox();
            }

            final status = data['status']?.toString() ?? 'available';
            final color = _statusColor(status);

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title']?.toString() ?? 'Food Item',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1a1a1a)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon(status), size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(_statusLabel(status),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.scale_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${data['quantity']?.toString() ?? ''} ${data['unit']?.toString() ?? ''}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        data['pickup_time']?.toString() ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (data['location'] != null && data['location'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            data['location'].toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (status == 'available') ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('food_listings')
                              .doc(doc.id)
                              .update({'status': 'expired'});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Listing cancelled!')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error! Try again.')));
                          }
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                      label: const Text('Cancel Listing',
                          style: TextStyle(color: Colors.red, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                  if (status == 'claimed') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.handshake_outlined, size: 14, color: Color(0xFF3B6D11)),
                          SizedBox(width: 4),
                          Text('Food has been claimed!',
                              style: TextStyle(fontSize: 12, color: Color(0xFF3B6D11), fontWeight: FontWeight.w500)),
                        ],
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
}

class _MyRequestsTab extends StatelessWidget {
  const _MyRequestsTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please login!'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('claims')
          .where('receiver_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B6D11)));
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
            icon: Icons.food_bank_outlined,
            message: 'No requests yet',
            subtitle: 'Claim food listings to see them here!',
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.food_bank_outlined,
            message: 'No requests yet',
            subtitle: 'Claim food listings to see them here!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];

            // ✅ Safe data read
            Map<String, dynamic> data = {};
            try {
              data = doc.data() as Map<String, dynamic>;
            } catch (e) {
              return const SizedBox();
            }

            final status = data['status']?.toString() ?? 'pending';
            final foodName = data['food_name']?.toString() ?? 'Food Item';

            Color statusColor;
            String statusLabel;
            IconData statusIcon;

            switch (status) {
              case 'delivered':
                statusColor = const Color(0xFF2E7D32);
                statusLabel = 'Delivered';
                statusIcon = Icons.check_circle_outline;
                break;
              case 'pickup':
                statusColor = const Color(0xFF633806);
                statusLabel = 'Pickup Pending';
                statusIcon = Icons.delivery_dining_outlined;
                break;
              default:
                statusColor = const Color(0xFF0C447C);
                statusLabel = 'Waiting for Volunteer';
                statusIcon = Icons.hourglass_empty;
            }

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(foodName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(statusLabel,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('Claimed recently',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: status == 'delivered'
                          ? const Color(0xFFEAF3DE)
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status == 'delivered' ? Icons.check_circle : Icons.hourglass_empty,
                          size: 14,
                          color: status == 'delivered' ? const Color(0xFF3B6D11) : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status == 'delivered'
                              ? 'Food delivered successfully!'
                              : 'Waiting for volunteer pickup',
                          style: TextStyle(
                              fontSize: 12,
                              color: status == 'delivered'
                                  ? const Color(0xFF3B6D11)
                                  : Colors.orange,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget _buildEmptyState({
  required IconData icon,
  required String message,
  required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3DE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: const Color(0xFF3B6D11)),
          ),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27500A))),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    ),
  );
}