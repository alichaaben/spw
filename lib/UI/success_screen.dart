import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

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
                  children: [
                    const Spacer(),
                    // Success Illustration
                    _buildSuccessIllustration(size, isSmallScreen),
                    SizedBox(height: size.height * 0.04),
                    // Success Message
                    _buildSuccessMessage(isSmallScreen),
                    const Spacer(),
                    // Get Started Button
                    _buildGetStartedButton(context, size),
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

  Widget _buildSuccessIllustration(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        children: [
          // Animated Success Container
          Container(
            width: isSmallScreen ? size.width * 0.3 : size.width * 0.25,
            height: isSmallScreen ? size.width * 0.3 : size.width * 0.25,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00B894), Color(0xFF00A885)],
              ),
              borderRadius: BorderRadius.circular(size.width * 0.15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B894).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 60),
          ),

          SizedBox(height: size.height * 0.04),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(bool isSmallScreen) {
    return Column(
      children: [
        Text(
          "Account Created!",
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 28,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isSmallScreen ? 16 : 20),

        Text(
          "Your account has been successfully created and verified.\nYou can now start using all the features of your wallet.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGetStartedButton(BuildContext context, Size size) {
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
        onPressed: () {
          // Navigate to main app
          Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route) => false);
        },
        child: Text(
          "Get Started",
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