import 'package:flutter/material.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});
  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Cooked Food';
  String _selectedUnit = 'Portions';
  String _selectedPickup = 'Morning (6AM - 10AM)';

  final List<String> _categories = [
    'Cooked Food',
    'Raw Vegetables',
    'Packed Food',
    'Beverages',
    'Other',
  ];

  final List<String> _units = [
    'Portions',
    'Kg',
    'Packets',
    'Liters',
  ];

  final List<String> _pickupSlots = [
    'Morning (6AM - 10AM)',
    'Afternoon (11AM - 3PM)',
    'Evening (4PM - 8PM)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text(
          'Donate Food',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Upload
            GestureDetector(
              onTap: () => _showSnack(
                  'Camera will work after image_picker setup!'),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3DE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3B6D11),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 48, color: Color(0xFF3B6D11)),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add food photo',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3B6D11),
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'or use AI Scanner to auto-detect food',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // AI Scanner Button
            OutlinedButton.icon(
              onPressed: () =>
                  _showSnack('AI Scanner coming soon!'),
              icon: const Icon(Icons.document_scanner,
                  color: Color(0xFF3B6D11)),
              label: const Text(
                'Use AI Food Scanner',
                style: TextStyle(color: Color(0xFF3B6D11)),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side:
                    const BorderSide(color: Color(0xFF3B6D11)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 20),

            // Food Name
            _sectionLabel('Food Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration(
                  'e.g. Biryani, Chapati, Rice',
                  Icons.fastfood_outlined),
            ),

            const SizedBox(height: 16),

            // Category
            _sectionLabel('Category'),
            const SizedBox(height: 6),
            _buildDropdown(
              value: _selectedCategory,
              items: _categories,
              icon: Icons.category_outlined,
              onChanged: (val) =>
                  setState(() => _selectedCategory = val!),
            ),

            const SizedBox(height: 16),

            // Quantity + Unit
            _sectionLabel('Quantity'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                        'Amount', Icons.numbers_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildDropdown(
                    value: _selectedUnit,
                    items: _units,
                    icon: Icons.scale_outlined,
                    onChanged: (val) =>
                        setState(() => _selectedUnit = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Pickup Time
            _sectionLabel('Pickup Time Slot'),
            const SizedBox(height: 6),
            _buildDropdown(
              value: _selectedPickup,
              items: _pickupSlots,
              icon: Icons.access_time_outlined,
              onChanged: (val) =>
                  setState(() => _selectedPickup = val!),
            ),

            const SizedBox(height: 16),

            // Location
            _sectionLabel('Pickup Location'),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () =>
                  _showSnack('GPS location will work after geolocator setup!'),
              icon: const Icon(Icons.my_location,
                  color: Color(0xFF3B6D11)),
              label: const Text(
                'Use My Current Location',
                style: TextStyle(color: Color(0xFF3B6D11)),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(
                    color: Color(0xFF3B6D11)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            _sectionLabel('Description (Optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecoration(
                      'Any extra info about the food...',
                      Icons.notes_outlined)
                  .copyWith(alignLabelWithHint: true),
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: () {
                if (_nameController.text.isEmpty ||
                    _quantityController.text.isEmpty) {
                  _showSnack(
                      'Please fill Food Name and Quantity!');
                  return;
                }
                _showSnack(
                    'Food listed! Firebase will save it on Day 6.');
              },
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white),
              label: const Text(
                'List My Food Now',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B6D11),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF27500A)),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF3B6D11)),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(fontSize: 13, color: Colors.grey[500]),
      prefixIcon: Icon(icon, color: const Color(0xFF3B6D11)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: Color(0xFF3B6D11), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}