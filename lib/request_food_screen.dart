import 'package:flutter/material.dart';

class RequestFoodScreen extends StatefulWidget {
  const RequestFoodScreen({super.key});

  @override
  State<RequestFoodScreen> createState() => _RequestFoodScreenState();
}

class _RequestFoodScreenState extends State<RequestFoodScreen> {
  String selectedCategory = 'All';
  double distanceValue = 5.0;

  final List<Map<String, dynamic>> foodList = [
    {
      'name': 'Fresh Biryani',
      'donor': 'Ramesh Patil',
      'distance': '0.5 km',
      'expiry': '2 hours',
      'quantity': '5 portions',
      'category': 'Cooked',
      'color': Colors.green,
    },
    {
      'name': 'Bread & Butter',
      'donor': 'Priya Shop',
      'distance': '1.2 km',
      'expiry': '30 mins',
      'quantity': '10 pieces',
      'category': 'Packed',
      'color': Colors.orange,
    },
    {
      'name': 'Raw Vegetables',
      'donor': 'Suresh Farm',
      'distance': '2.0 km',
      'expiry': '1 day',
      'quantity': '3 kg',
      'category': 'Raw',
      'color': Colors.blue,
    },
    {
      'name': 'Dal Rice',
      'donor': 'Meena Tai',
      'distance': '0.8 km',
      'expiry': '3 hours',
      'quantity': '8 portions',
      'category': 'Cooked',
      'color': Colors.green,
    },
    {
      'name': 'Biscuits Pack',
      'donor': 'Quick Store',
      'distance': '1.5 km',
      'expiry': '2 days',
      'quantity': '5 packs',
      'category': 'Packed',
      'color': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get filteredList {
    if (selectedCategory == 'All') return foodList;
    return foodList
        .where((food) => food['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Request Food',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Cooked', 'Raw', 'Packed']
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          selectedColor: Colors.green,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          labelStyle: TextStyle(
                            color: selectedCategory == category
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // Distance Slider
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Within ${distanceValue.toStringAsFixed(1)} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: distanceValue,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        distanceValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  '${filteredList.length} items available',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Food List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final food = filteredList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Food Icon
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: food['color'] as Color,
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Food Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    food['donor'] as String,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Expires: ${food['expiry']}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    food['distance'] as String,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (food['color'] as Color).withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  food['category'] as String,
                                  style: TextStyle(
                                    color: food['color'] as Color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Request Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ ${food['name']} Requested!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text(
                            'Request',
                            style: TextStyle(color: Colors.white),
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
