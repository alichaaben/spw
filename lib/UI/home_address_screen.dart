import 'package:flutter/material.dart';

class HomeAddressScreen extends StatefulWidget {
  const HomeAddressScreen({super.key});

  @override
  State<HomeAddressScreen> createState() => _HomeAddressScreenState();
}

class _HomeAddressScreenState extends State<HomeAddressScreen> {
  final _streetController = TextEditingController();
  final _aptController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  bool get _isFormValid {
    return _streetController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _zipController.text.isNotEmpty;
  }

  void _continue() {
    if (_isFormValid) {
      Navigator.pushNamed(context, '/review');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.vertical,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                  vertical: size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Step Indicator
                    _buildHeaderSection(isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Illustration Section
                    _buildIllustrationSection(size, isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Title Section
                    _buildTitleSection(isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Address Form Fields
                    _buildAddressFormFields(),

                    const Spacer(),

                    // Shipping Note
                    _buildShippingNote(),

                    SizedBox(height: size.height * 0.03),

                    // Continue Button
                    _buildContinueButton(size),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Row(
      children: [
        // Back Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.grey.shade700),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),

        const Spacer(),

        // Step Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            'Step 2 of 3',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustrationSection(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        children: [
          // Animated Home Icon Container
          Container(
            width: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            height: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFD79A8), Color(0xFFE84393)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFD79A8).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.home_work_outlined,
                color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Home Address",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          "Let us know where we should send your Wallet Mastercard® Debit Card.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _streetController,
          label: "Street Address",
          hint: "Enter your street address",
          icon: Icons.location_on_outlined,
        ),

        SizedBox(height: 20),

        _buildTextField(
          controller: _aptController,
          label: "Apt / Suite Number (Optional)",
          hint: "Apt, suite, unit, etc.",
          icon: Icons.apartment_outlined,
          isOptional: true,
        ),

        SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _cityController,
                label: "City",
                hint: "City",
                icon: Icons.location_city_outlined,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildTextField(
                controller: _stateController,
                label: "State",
                hint: "State",
                icon: Icons.map_outlined,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        // ZIP Code Field with Search Button
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _zipController,
              label: "ZIP Code",
              hint: "Enter ZIP code",
              icon: Icons.local_post_office_outlined,
              keyboardType: TextInputType.number,
            ),

            // إضافة زر البحث هنا - تحت حقل ZIP Code
            _buildSearchButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 4),
              Text(
                "(Optional)",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  icon,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFD79A8), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  // زر البحث الذي ستضيفه تحت حقل ZIP Code
  Widget _buildSearchButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/address-search');
          },
          icon: Icon(Icons.search_rounded, color: const Color(0xFFFD79A8)),
          label: Text(
            'Search on Map',
            style: TextStyle(
              color: const Color(0xFFFD79A8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShippingNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFD79A8).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFD79A8).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_rounded,
            color: const Color(0xFFFD79A8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Your debit card will be shipped to this address within 5-7 business days after approval.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, size.height * 0.065),
          backgroundColor: _isFormValid ?
          const Color(0xFFFD79A8) : Colors.grey.shade300,
          foregroundColor: _isFormValid ?
          Colors.white : Colors.grey.shade500,
          elevation: _isFormValid ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: _isFormValid ?
          const Color(0xFFFD79A8).withOpacity(0.3) : Colors.transparent,
        ),
        onPressed: _isFormValid ? _continue : null,
        child: Text(
          "Continue",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _aptController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }
}