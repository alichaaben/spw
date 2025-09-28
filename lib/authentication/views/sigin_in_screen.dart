import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spw/common/views/verification_modal.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Validation messages
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  // Real-time validation for email
  void _onEmailChanged(String value) {
    if (_emailError != null) {
      setState(() {
        _emailError = _validateEmail(value);
      });
    }
  }

  // Real-time validation for password
  void _onPasswordChanged(String value) {
    if (_passwordError != null) {
      setState(() {
        _passwordError = _validatePassword(value);
      });
    }
  }

  // Check if form is valid
  bool _isFormValid() {
    final emailValid = _validateEmail(_emailController.text) == null;
    final passwordValid = _validatePassword(_passwordController.text) == null;
    return emailValid && passwordValid;
  }

  Future<void> _signIn() async {
    // Validate all fields
    final emailValidation = _validateEmail(_emailController.text);
    final passwordValidation = _validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailValidation;
      _passwordError = passwordValidation;
    });

    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse('https://spw.demo-tunisie.tn/api/oauth');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('API Response: $responseData');

        // Check the response code
        if (responseData['code'] == '00') {
          var data = responseData['data'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['token']);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return VerificationModal();
            },
          ).then((value) {
            if (value == true) {
              Navigator.pushNamed(context, '/home');
            }
          });
        } else if (responseData['code'] == '01') {
          // Error case - code 01
          String errorMessage = responseData['message'] ?? 'An error occurred';
          print('Login failed: $errorMessage');

          // Show error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Handle unexpected code
          print('Unexpected response code: ${responseData['code']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected response from server'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        var errorData = json.decode(response.body);
        String errorMessage = 'Login failed';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
                child: Form(
                  key: _formKey,
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

                      // Email Input Field
                      _buildEmailInputField(size),

                      SizedBox(height: size.height * 0.02),

                      // Password Input Field
                      _buildPasswordInputField(size),

                      SizedBox(height: size.height * 0.03),

                      // Forgot Password
                      _buildForgotPassword(),

                      const Spacer(),

                      // Sign In Button
                      _buildSignInButton(context, size),

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
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.grey.shade700,
        ),
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
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 40,
            ),
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
          "Enter your email and password to securely access your account.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInputField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
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
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email_rounded,
                color: Colors.grey.shade500,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your email",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _emailError != null ? Colors.red : Colors.grey.shade200, 
                  width: 1
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _emailError != null ? Colors.red : Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              errorText: _emailError,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            onChanged: _onEmailChanged,
            validator: _validateEmail,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInputField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
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
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade500),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey.shade500,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your password",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _passwordError != null ? Colors.red : Colors.grey.shade200, 
                  width: 1
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _passwordError != null ? Colors.red : Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              errorText: _passwordError,
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            onChanged: _onPasswordChanged,
            validator: _validatePassword,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          // Navigate to forgot password screen
          Navigator.pushNamed(context, '/forgot-password');
        },
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            color: const Color(0xFF6366F1),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context, Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, size.height * 0.065),
          backgroundColor: _isFormValid() ? const Color(0xFF6366F1) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: _isFormValid() 
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : Colors.transparent,
        ),
        onPressed: _isLoading ? null : _signIn,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                "Sign In",
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