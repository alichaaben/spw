import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _ssnController = TextEditingController();

  bool get _isFormValid {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _dobController.text.isNotEmpty &&
        _ssnController.text.isNotEmpty;
  }

  void _continue() {
    if (_isFormValid) {
      Navigator.pushNamed(context, '/address-info');
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

                    // Form Fields
                    _buildFormFields(),

                    const Spacer(),

                    // Security Note
                    _buildSecurityNote(),

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
            'Step 1 of 3',
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
          // Animated Profile Icon Container
          Container(
            width: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            height: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person_outline_rounded,
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
          "Personal Information",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          "We ask for your personal information to verify your application details securely.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: "First Name",
          hint: "Enter your first name",
          icon: Icons.person_outline_rounded,
        ),

        SizedBox(height: 20),

        _buildTextField(
          controller: _lastNameController,
          label: "Last Name",
          hint: "Enter your last name",
          icon: Icons.person_outline_rounded,
        ),

        SizedBox(height: 20),

        _buildTextField(
          controller: _dobController,
          label: "Date of Birth",
          hint: "MM / DD / YYYY",
          icon: Icons.calendar_today_rounded,
          isSecure: true,
        ),

        SizedBox(height: 20),

        _buildTextField(
          controller: _ssnController,
          label: "Social Security Number",
          hint: "Enter your SSN",
          icon: Icons.security_rounded,
          isSecure: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isSecure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
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
            obscureText: isSecure,
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
              suffixIcon: isSecure ? Container(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ) : null,
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
                borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            color: const Color(0xFF6C5CE7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "We use 128-bit encryption for security, and this is only used for identity verification purposes.",
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
          const Color(0xFF6C5CE7) : Colors.grey.shade300,
          foregroundColor: _isFormValid ?
          Colors.white : Colors.grey.shade500,
          elevation: _isFormValid ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: _isFormValid ?
          const Color(0xFF6C5CE7).withOpacity(0.3) : Colors.transparent,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _ssnController.dispose();
    super.dispose();
  }
}