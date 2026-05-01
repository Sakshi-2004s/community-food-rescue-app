import 'package:flutter/material.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> foodLocations = [
    {
      'name': 'Fresh Biryani',
      'donor': 'Ramesh Patil',
      'distance': '0.5 km',
      'expiry': '2 hours',
      'quantity': '5 portions',
      'color': Colors.green,
    },
    {
      'name': 'Bread & Butter',
      'donor': 'Priya Shop',
      'distance': '1.2 km',
      'expiry': '30 mins',
      'quantity': '10 pieces',
      'color': Colors.orange,
    },
    {
      'name': 'Raw Vegetables',
      'donor': 'Suresh Farm',
      'distance': '2.0 km',
      'expiry': '1 day',
      'quantity': '3 kg',
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Live Food Map',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green[50],
            padding: const EdgeInsets.all(12),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text('Available'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '1',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text('Expiring Soon'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '2',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text('Volunteers'),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: ['All', 'Cooked', 'Raw', 'Packed', 'Expiring Soon']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        selectedColor: Colors.green,
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            height: 200,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 60, color: Colors.green),
                  Text(
                    'Live Map',
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: foodLocations.length,
              itemBuilder: (context, index) {
                final food = foodLocations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: food['color'] as Color,
                      child: const Icon(Icons.fastfood, color: Colors.white),
                    ),
                    title: Text(
                      food['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${food['quantity']} • ${food['distance']} • Expires: ${food['expiry']}',
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Claim',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () {},
        icon: const Icon(Icons.add_location, color: Colors.white),
        label: const Text('Donate Here', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
