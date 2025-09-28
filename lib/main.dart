import 'package:flutter/material.dart';
import 'package:spw/authentication/views/adress_search_screen.dart';
import 'package:spw/authentication/views/confirm_code_screen.dart';
import 'package:spw/authentication/views/create_password_screen.dart';
import 'package:spw/authentication/views/verify_pin_screen.dart';
import 'package:spw/authentication/views/home_adress_screen.dart';
import 'package:spw/authentication/views/personal_info_screen.dart';
import 'package:spw/authentication/views/review_screen.dart';
import 'package:spw/authentication/views/sigin_in_screen.dart';
import 'package:spw/authentication/views/succes_screen.dart';
import 'package:spw/authentication/views/touch_id_screen.dart';
import 'package:spw/common/views/login_or_register_screen.dart';
import 'package:spw/common/views/splash_screen.dart';
import 'package:spw/common/views/welcome_screen.dart';
import 'package:spw/dashboard/views/dashboard_screen.dart';

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
        '/home': (context) => const DashboardScreen(),
        '/splash': (context) => const SplashScreen(),
        '/sign-in': (context) => const SignInPage(),
        '/choose-auth': (context) => ChooseLoginOrRegisterScreen(),
         '/success': (context) => const SuccessScreen(),
        '/create-password': (context) => const CreatePasswordScreen(),
        '/personal-info': (context) => const PersonalInfoScreen(),
        '/address-info': (context) => const HomeAddressScreen(),
        '/address-search': (context) => const AddressSearchScreen(),
        '/review': (context) => const ReviewScreen(),
        '/create-pin': (context) => const VerifyPinScreen(),
        '/touch-id': (context) => const TouchIdScreen(),
        '/welcome': (context) =>
            const WelcomeScreen(), // تحتاج لإنشاء هذه الصفحة
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
