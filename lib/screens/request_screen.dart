import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});
  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All', 'Cooked Food', 'Raw Vegetables', 'Packed Food', 'Beverages'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text('Request Food',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF3B6D11),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search food...',
                hintStyle:
                    const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B6D11)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B6D11)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[700])),
                  ),
                );
              },
            ),
          ),

          // ✅ Real Firebase Food List
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
                        const Icon(Icons.food_bank_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _selectedCategory == 'All'
                              ? 'No food available right now'
                              : 'No $_selectedCategory available',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey),
                        ),
                        const Text('Be the first to donate!',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // Filter + search
                var docs = snapshot.data!.docs.toList();
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data =
                        doc.data() as Map<String, dynamic>;
                    final title = (data['title'] ?? '')
                        .toString()
                        .toLowerCase();
                    return title.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No food found!',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data =
                        doc.data() as Map<String, dynamic>;
                    final isUrgent = false;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            food: {
                              'id': doc.id, // ✅ ID pass karto
                              'name': data['title'] ?? '',
                              'location':
                                  data['location'] ?? 'Near you',
                              'quantity':
                                  '${data['quantity']} ${data['unit']}',
                              'expiry':
                                  data['pickup_time'] ?? '',
                              'category':
                                  data['category'] ?? '',
                              'urgent': isUrgent,
                            },
                          ),
                        ),
                      ),
                      child: Container(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
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
                                color: isUrgent
                                    ? const Color(0xFFfcebeb)
                                    : const Color(0xFFEAF3DE),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.fastfood,
                                  color: isUrgent
                                      ? const Color(0xFFE24B4A)
                                      : const Color(0xFF3B6D11),
                                  size: 30),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          data['title'] ??
                                              'Food Item',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: Color(
                                                  0xFF1a1a1a)),
                                        ),
                                      ),
                                      if (isUrgent)
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                                  horizontal: 8,
                                                  vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                                0xFFE24B4A),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(10),
                                          ),
                                          child: const Text(
                                              'Urgent',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      Colors.white,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data['location'] ??
                                        'Near you',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        '${data['quantity']} ${data['unit']}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color(0xFF3B6D11),
                                            fontWeight:
                                                FontWeight.w500),
                                      ),
                                      Text(
                                        data['pickup_time'] ?? '',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}