import 'package:flutter/material.dart';

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final _searchController = TextEditingController(text: 'Greenwich');
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectAddress(String address) {
    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Map Placeholder
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF6C5CE7).withOpacity(0.8),
                        const Color(0xFF6C5CE7).withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Map View',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Positioned(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Back Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18, color: Colors.grey.shade700),
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Search Field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search address...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        // Clear Button
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: Colors.grey.shade500, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),

                        const SizedBox(width: 8),

                        // Search Icon
                        Icon(Icons.search_rounded,
                            color: const Color(0xFF6C5CE7), size: 24),
                      ],
                    ),
                  ),
                ),

                // Current Location Button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.my_location_rounded,
                          color: const Color(0xFF6C5CE7), size: 24),
                      onPressed: () {
                        // Get current location
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Address List Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Location
                  _buildCurrentLocation(),

                  const SizedBox(height: 24),

                  // Section Title
                  Text(
                    'Suggested Addresses',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Address List
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildAddressItem(
                          address: '428 Greenwich Ave',
                          location: 'Brooklyn, NY 11222',
                          distance: '0.8 mi',
                        ),
                        _buildAddressItem(
                          address: '285 Greenwich Village',
                          location: 'Hermosa Beach, CA 90254',
                          distance: '1.2 mi',
                        ),
                        _buildAddressItem(
                          address: '89 Greenwich Drive',
                          location: 'Manhattan, NY 10012',
                          distance: '2.1 mi',
                        ),
                        _buildAddressItem(
                          address: '65 Greenwich West',
                          location: 'New York, NY 10014',
                          distance: '3.5 mi',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return GestureDetector(
      onTap: () => _selectAddress('Current Location'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6C5CE7).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.my_location_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Current Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C5CE7),
                    ),
                  ),
                  Text(
                    'Automatically detect your location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF6C5CE7), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem({
    required String address,
    required String location,
    required String distance,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAddress(address),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on_rounded,
                      color: Colors.grey.shade600, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade400, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}