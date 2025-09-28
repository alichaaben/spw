import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.02,
          ),
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
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
              ),

              SizedBox(height: size.height * 0.06),

              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // Title
              Text(
                "Welcome to Wallet",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Text(
                  "Your secure digital wallet for all your financial needs. Manage your money with ease and security.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, size.height * 0.065),
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shadowColor: const Color(0xFF6C5CE7).withOpacity(0.3),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign-in');
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
              ),

              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}