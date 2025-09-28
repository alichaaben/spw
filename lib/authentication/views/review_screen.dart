import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  // Sample data - in real app this would come from previous screens
  final Map<String, String> userInfo = {
    'Full Legal Name': 'Dylan Robinson',
    'Date of Birth': '28 May 1992',
    'Social Security Number': '*8349',
    'Residential Address': '428 Greenwich Ave #29A,\nBrooklyn, NY 11239',
    //'Email': 'dylan.robinson@email.com',
    //'Phone Number': '+1 (555) 123-4567',
  };

  void _continue() {
    Navigator.pushNamed(context, '/create-pin');
  }

  void _editInfo(String section) {
    // Navigate back to appropriate screen for editing
    switch (section) {
      case 'Full Legal Name':
      case 'Date of Birth':
      case 'Social Security Number':
        Navigator.pushNamed(context, '/personal-info');
        break;
      case 'Residential Address':
        Navigator.pushNamed(context, '/address-info');
        break;
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

                    // Information Cards
                    _buildInfoSections(),

                    const Spacer(),

                    // Agreement Note
                    _buildAgreementNote(),

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
            'Step 3 of 3',
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
          // Animated Review Icon Container
          Container(
            width: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            height: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00B894), Color(0xFF00A885)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B894).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.verified_user_rounded,
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
          "Almost There!",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          "Please review your information to ensure everything is correct before submitting your application.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSections() {
    return Column(
      children: [
        _buildInfoCard(
          label: "Full Legal Name",
          value: userInfo['Full Legal Name']!,
          icon: Icons.person_outline_rounded,
        ),

        SizedBox(height: 16),

        _buildInfoCard(
          label: "Date of Birth",
          value: userInfo['Date of Birth']!,
          icon: Icons.cake_outlined,
        ),

        SizedBox(height: 16),

        _buildInfoCard(
          label: "Social Security Number",
          value: userInfo['Social Security Number']!,
          icon: Icons.security_outlined,
          isSensitive: true,
        ),

        SizedBox(height: 16),

        _buildInfoCard(
          label: "Residential Address",
          value: userInfo['Residential Address']!,
          icon: Icons.home_outlined,
        ),

        SizedBox(height: 16),

      ],
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    bool isSensitive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00B894).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00B894), size: 20),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _editInfo(label),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined,
                        color: Colors.grey.shade600, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00B894).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: const Color(0xFF00B894),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "By continuing, you agree that all information provided is accurate and complete.",
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
          backgroundColor: const Color(0xFF00B894),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: const Color(0xFF00B894).withOpacity(0.3),
        ),
        onPressed: _continue,
        child: Text(
          "Submit Application",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}