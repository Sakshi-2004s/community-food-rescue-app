import 'package:flutter/material.dart';
import 'detail_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});
  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All', 'Cooked', 'Raw', 'Packed', 'Urgent'
  ];

  final List<Map<String, dynamic>> _foodList = [
    {
      'name': 'Biryani + Dal Fry',
      'location': 'Hotel Shree Krishna • 0.4 km',
      'quantity': '15 portions',
      'expiry': 'Expires in 3h 20m',
      'category': 'Cooked',
      'urgent': false,
    },
    {
      'name': 'Mixed Vegetables',
      'location': 'Bhaji Market • 1.1 km',
      'quantity': '5 kg',
      'expiry': 'Expires in 1h 45m',
      'category': 'Raw',
      'urgent': true,
    },
    {
      'name': 'Parle-G Biscuits',
      'location': 'Akurdi Colony • 1.8 km',
      'quantity': '40 packets',
      'expiry': 'Expires in 3 days',
      'category': 'Packed',
      'urgent': false,
    },
    {
      'name': 'Rice + Sabzi',
      'location': 'Community Kitchen • 2.1 km',
      'quantity': '20 portions',
      'expiry': 'Expires in 5h',
      'category': 'Cooked',
      'urgent': false,
    },
    {
      'name': 'Bread Loaves',
      'location': 'Bakery Shop • 0.8 km',
      'quantity': '10 loaves',
      'expiry': 'Expires in 45m',
      'category': 'Packed',
      'urgent': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredList {
    if (_selectedCategory == 'All') return _foodList;
    if (_selectedCategory == 'Urgent') {
      return _foodList
          .where((f) => f['urgent'] == true)
          .toList();
    }
    return _foodList
        .where((f) => f['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text(
          'Request Food',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF3B6D11),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search food...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withAlpha(40),
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
                        horizontal: 16, vertical: 4),
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

          // Food List
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.food_bank_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No food available in this category',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredList.length,
                    itemBuilder: (_, i) {
                      final food = _filteredList[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailScreen(food: food),
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
                              color: food['urgent']
                                  ? const Color(0xFFE24B4A)
                                  : Colors.grey.shade200,
                              width: food['urgent'] ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: food['urgent']
                                      ? const Color(0xFFfcebeb)
                                      : const Color(0xFFEAF3DE),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.fastfood,
                                  color: food['urgent']
                                      ? const Color(0xFFE24B4A)
                                      : const Color(0xFF3B6D11),
                                  size: 30,
                                ),
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
                                            food['name'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.bold,
                                              color:
                                                  Color(0xFF1a1a1a),
                                            ),
                                          ),
                                        ),
                                        if (food['urgent'])
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
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      food['location'],
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
                                          food['quantity'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3B6D11),
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          food['expiry'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: food['urgent']
                                                ? const Color(
                                                    0xFFE24B4A)
                                                : Colors.grey[500],
                                          ),
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
                  ),
          ),
        ],
      ),
    );
  }
}