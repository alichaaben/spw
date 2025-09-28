import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

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
                    // Back Button
                    _buildBackButton(context),

                    SizedBox(height: size.height * 0.03),

                    // Logo Section
                    _buildLogoSection(size, isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Header Text
                    _buildHeaderText(isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Phone Input Field
                    _buildPhoneInputField(size),

                    const Spacer(),

                    // Continue Button
                    _buildContinueButton(context, size),

                    SizedBox(height: size.height * 0.02),

                    // Terms Text
                    _buildTermsText(size),

                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildLogoSection(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        children: [
          // Animated Logo Container
          Container(
            width: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            height: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 40),
          ),

          SizedBox(height: size.height * 0.03),

          // Welcome Text
          Text(
            "Welcome to Wallet",
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sign in to your account",
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),

        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          "Enter your phone number to securely sign in to your account. We'll send you a verification code.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),

        SizedBox(height: size.height * 0.01),

        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "+1",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down_rounded,
                        color: Colors.grey.shade500),
                  ],
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: "(562) 859-4936",
              hintStyle: TextStyle(color: Colors.grey.shade400),
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
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, size.height * 0.065),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/confirm');
        },
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

  Widget _buildTermsText(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Colors.grey.shade500,
          ),
          children: [
            const TextSpan(text: "By continuing, you agree to our "),
            TextSpan(
              text: "Terms of Service",
              style: TextStyle(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}