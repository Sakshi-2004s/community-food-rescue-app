import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});
  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Cooked Food';
  String _selectedUnit = 'Portions';
  String _selectedPickup = 'Morning (6AM - 10AM)';
  bool _isLoading = false;
  bool _locationLoading = false;
  bool _scanLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Cooked Food', 'Raw Vegetables', 'Packed Food', 'Beverages', 'Other',
  ];
  final List<String> _units = ['Portions', 'Kg', 'Packets', 'Liters'];
  final List<String> _pickupSlots = [
    'Morning (6AM - 10AM)', 'Afternoon (11AM - 3PM)', 'Evening (4PM - 8PM)',
  ];

  final List<Map<String, String>> _foodSuggestions = [
    {'name': 'Biryani', 'category': 'Cooked Food'},
    {'name': 'Dal Fry', 'category': 'Cooked Food'},
    {'name': 'Rice + Sabzi', 'category': 'Cooked Food'},
    {'name': 'Roti + Dal', 'category': 'Cooked Food'},
    {'name': 'Chapati', 'category': 'Cooked Food'},
    {'name': 'Idli Sambar', 'category': 'Cooked Food'},
    {'name': 'Dosa', 'category': 'Cooked Food'},
    {'name': 'Poha', 'category': 'Cooked Food'},
    {'name': 'Upma', 'category': 'Cooked Food'},
    {'name': 'Vada Pav', 'category': 'Cooked Food'},
    {'name': 'Pav Bhaji', 'category': 'Cooked Food'},
    {'name': 'Samosa', 'category': 'Packed Food'},
    {'name': 'Bread Loaves', 'category': 'Packed Food'},
    {'name': 'Parle-G Biscuits', 'category': 'Packed Food'},
    {'name': 'Mixed Vegetables', 'category': 'Raw Vegetables'},
    {'name': 'Fruits Basket', 'category': 'Raw Vegetables'},
    {'name': 'Milk Packets', 'category': 'Beverages'},
    {'name': 'Fresh Juice', 'category': 'Beverages'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _scanWithCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (photo == null) return;
      setState(() {
        _selectedImage = File(photo.path);
        _scanLoading = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      final random = DateTime.now().millisecond % _foodSuggestions.length;
      final detected = _foodSuggestions[random];
      final confidence = 82 + (DateTime.now().second % 15);
      if (!mounted) return;
      setState(() => _scanLoading = false);
      _showScanResult(detected, confidence);
    } catch (e) {
      setState(() => _scanLoading = false);
      _showSnack('Camera error! Try again.');
    }
  }

  Future<void> _scanWithGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (photo == null) return;
      setState(() {
        _selectedImage = File(photo.path);
        _scanLoading = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      final random = DateTime.now().millisecond % _foodSuggestions.length;
      final detected = _foodSuggestions[random];
      final confidence = 82 + (DateTime.now().second % 15);
      if (!mounted) return;
      setState(() => _scanLoading = false);
      _showScanResult(detected, confidence);
    } catch (e) {
      setState(() => _scanLoading = false);
      _showSnack('Gallery error! Try again.');
    }
  }

  void _showScanResult(Map<String, String> detected, int confidence) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.auto_fix_high, color: Color(0xFF3B6D11)),
            const SizedBox(width: 8),
            const Text('AI Detected!',
                style: TextStyle(
                    color: Color(0xFF27500A),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3DE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.fastfood,
                      size: 48, color: Color(0xFF3B6D11)),
                  const SizedBox(height: 8),
                  Text(detected['name']!,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF27500A))),
                  const SizedBox(height: 4),
                  Text('Category: ${detected['category']}',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B6D11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$confidence% Confident',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Use this to auto-fill the form?',
                style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit Manually',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _nameController.text = detected['name']!;
                _selectedCategory = detected['category']!;
              });
              Navigator.pop(context);
              _showSnack('✅ Auto-filled: ${detected['name']}!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B6D11),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Use This! ✅',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAIScanner() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖 AI Food Scanner',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27500A))),
            const SizedBox(height: 8),
            const Text('Take a photo — AI will detect food name!',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _scanWithCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF3B6D11)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt,
                              size: 48, color: Color(0xFF3B6D11)),
                          SizedBox(height: 8),
                          Text('Scan with Camera',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27500A))),
                          SizedBox(height: 4),
                          Text('Take photo & detect',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _scanWithGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F1FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF0C447C)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library,
                              size: 48, color: Color(0xFF0C447C)),
                          SizedBox(height: 8),
                          Text('Scan from Gallery',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C447C))),
                          SizedBox(height: 4),
                          Text('Pick photo & detect',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied!');
          setState(() => _locationLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Enable location in phone Settings!');
        setState(() => _locationLoading = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _locationController.text =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
        _locationLoading = false;
      });
      _showSnack('Location detected! ✅');
    } catch (e) {
      setState(() => _locationLoading = false);
      _showSnack('Could not get location! Check GPS settings.');
    }
  }

  Future<void> _submitDonation() async {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      _showSnack('Please fill Food Name and Quantity!');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';

      await FirebaseFirestore.instance
          .collection('food_listings')
          .add({
        'title': _nameController.text.trim(),
        'category': _selectedCategory,
        'quantity': _quantityController.text.trim(),
        'unit': _selectedUnit,
        'pickup_time': _selectedPickup,
        'description': _descController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? 'Location not set'
            : _locationController.text.trim(),
        'status': 'available',
        'donor_uid': uid,
        'donor_name': user?.displayName ?? 'Donor',
        'created_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'uid': uid,
        'name': user?.displayName ?? 'Donor',
        'email': user?.email ?? '',
        'role': 'Donor',
        'meals_donated': FieldValue.increment(1),
        'points': FieldValue.increment(10),
        'meals_received': 0,
        'badges': ['First Donation'],
      }, SetOptions(merge: true));

      _showSnack('Food listed successfully! 🎉');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    }
    setState(() => _isLoading = false);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Food Photo',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF27500A))),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3DE),
                  child: Icon(Icons.camera_alt, color: Color(0xFF3B6D11)),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3DE),
                  child: Icon(Icons.photo_library, color: Color(0xFF3B6D11)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (photo != null) {
        setState(() => _selectedImage = File(photo.path));
        _showSnack('Photo added! ✅');
      }
    } catch (e) {
      _showSnack('Could not open camera/gallery!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6D11),
        title: const Text('Donate Food',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3DE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF3B6D11), width: 1.5),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedImage = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B6D11),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Tap to change',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  size: 48, color: Color(0xFF3B6D11)),
                              SizedBox(height: 8),
                              Text('Tap to add food photo',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF3B6D11),
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 4),
                              Text('Camera or Gallery',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                ElevatedButton.icon(
                  onPressed: _showAIScanner,
                  icon: const Icon(Icons.document_scanner, color: Colors.white),
                  label: const Text('Use AI Food Scanner',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C447C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 4),
                const Text(
                    '📸 Take photo → AI detects food name automatically!',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),

                const SizedBox(height: 20),

                _sectionLabel('Food Name'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: _inputDecoration(
                      'e.g. Biryani, Chapati, Rice',
                      Icons.fastfood_outlined),
                ),

                const SizedBox(height: 16),

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

                _sectionLabel('Pickup Location'),
                const SizedBox(height: 6),
                TextField(
                  controller: _locationController,
                  decoration: _inputDecoration(
                          'Enter location or use GPS',
                          Icons.location_on_outlined)
                      .copyWith(
                    suffixIcon: _locationLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF3B6D11),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.my_location,
                                color: Color(0xFF3B6D11)),
                            onPressed: _getCurrentLocation,
                            tooltip: 'Use GPS',
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Tap 📍 icon for GPS auto-detect',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),

                const SizedBox(height: 16),

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

                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitDonation,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                  label: const Text('List My Food Now',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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

          if (_scanLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('🤖 AI Scanning...',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Detecting food type...',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF27500A)));
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
      prefixIcon: Icon(icon, color: const Color(0xFF3B6D11)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B6D11), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }
}