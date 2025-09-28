import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'UI/splash_screen.dart';
import 'UI/sign_in_page.dart';
import 'UI/confirm_code_page.dart';
import 'UI/success_screen.dart';
import 'UI/create_password_screen.dart';
import 'UI/personal_info_screen.dart';
import 'UI/home_address_screen.dart';
import 'UI/address_search_screen.dart';
import 'UI/review_screen.dart';
import 'UI/create_pin_screen.dart';
import 'UI/touch_id_screen.dart';
import 'UI/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C5CE7),
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/sign-in': (context) => const SignInPage(),
        '/confirm': (context) => const ConfirmCodePage(),
        '/success': (context) => const SuccessScreen(),
        '/create-password': (context) => const CreatePasswordScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/address-info': (context) => const HomeAddressScreen(),
        '/address-search': (context) => const AddressSearchScreen(),
        '/review': (context) => const ReviewScreen(),
        '/create-pin': (context) => const CreatePinScreen(),
        '/touch-id': (context) => const TouchIdScreen(),
        '/welcome': (context) => const WelcomeScreen(), // تحتاج لإنشاء هذه الصفحة
/*        '/pin': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return CreatePinScreen(mode: args?['mode'] ?? 'login');
        },*/
/*        '/menuext': (context) => const MenuExtScreen(), // تحتاج لإنشاء هذه الصفحة
        '/offline': (context) => const OfflineScreen(), // تحتاج لإنشاء هذه الصفحة*/
      },
    );
  }
}