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
import 'package:spw/dashboard/views/dashbord/QRCodeModal.dart';
import 'package:spw/dashboard/views/dashbord/account_topUp_screen.dart';
import 'package:spw/dashboard/views/dashbord/merchant_payment_screen.dart';
import 'package:spw/dashboard/views/dashbord/money_transfer_screen.dart';
import 'package:spw/dashboard/views/dashbord/notifications_screen.dart';
import 'package:spw/dashboard/views/dashbord/paymentID_screen.dart';
import 'package:spw/dashboard/views/dashbord/phone_recharge_screen.dart';
import 'package:spw/dashboard/views/dashbord/profile_screen.dart';
import 'package:spw/dashboard/views/dashbord/settings_screen.dart';
import 'package:spw/dashboard/views/dashbord/support_screen.dart';
import 'package:spw/dashboard/views/dashbord/transaction_history_screen.dart';
import 'package:spw/dashboard/views/dashbord/dashboard_screen.dart';
import 'package:spw/http/api_client.dart';

void main() {
 //   ApiClient.client; 
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
        '/dashboard': (context) => const WalletDashboard(),
        '/history': (context) => const TransactionHistoryScreen(),
        '/merchant': (context) => const MerchantPaymentScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/recharge': (context) => const PhoneRechargeScreen(),
        '/transfer': (context) => const MoneyTransferScreen(),
        '/topup': (context) => const AccountTopUpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/payment-id': (context) => const PaymentIDScreen(),
        '/scan': (context) => const QRCodeModal(),
        '/support': (context) => const SupportScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },
    );
  }
}
