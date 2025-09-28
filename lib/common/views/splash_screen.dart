import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString('token') != null;
    final hasStatus = prefs.getString('statut') != null;

    if (!mounted) return;

    // if (hasToken) {
    //   if (hasStatus) {
    //     Navigator.pushReplacementNamed(context, '/menuext');
    //   } else {
    //     Navigator.pushReplacementNamed(context, '/pin', arguments: {'mode': 'login'});
    //   }
    // } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C5CE7), // لون أساسي مشابه لـ Ionic
      body: Column(
        children: [
          // المحتوى الرئيسي
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 60,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Wallet App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer مع Spinner
          Container(
            height: 80,
            color: const Color(0xFF6C5CE7),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}