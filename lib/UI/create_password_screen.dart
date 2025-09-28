import 'package:flutter/material.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFocused = false;
  bool _isConfirmFocused = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isPasswordValid {
    final password = _passwordController.text;
    return password.length >= 8 &&
        (RegExp(r'[A-Z]').hasMatch(password) ||
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  bool get _isConfirmPasswordValid {
    return _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;
  }

  bool get _isFormValid {
    return _isPasswordValid && _isConfirmPasswordValid;
  }

  void _continue() {
    if (_isFormValid) {
      Navigator.pushNamed(context, '/personal-info');
    }
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) ||
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (password.length >= 12) strength++;

    return strength.clamp(0, 4);
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 1: return "Weak";
      case 2: return "Fair";
      case 3: return "Good";
      case 4: return "Strong";
      default: return "Very Weak";
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 1: return const Color(0xFFFF7675);
      case 2: return const Color(0xFFFDCB6E);
      case 3: return const Color(0xFF74B9FF);
      case 4: return const Color(0xFF00B894);
      default: return Colors.grey.shade500;
    }
  }

  List<Color> _getStrengthColors(int strength) {
    switch (strength) {
      case 1: return [const Color(0xFFFF7675), const Color(0xFFFF7675)];
      case 2: return [const Color(0xFFFDCB6E), const Color(0xFFFDCB6E)];
      case 3: return [const Color(0xFF74B9FF), const Color(0xFF74B9FF)];
      case 4: return [const Color(0xFF00B894), const Color(0xFF00B894)];
      default: return [Colors.grey.shade300, Colors.grey.shade300];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final passwordStrength = _calculatePasswordStrength(_passwordController.text);

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

                    // Illustration Section
                    _buildIllustrationSection(size, isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Header Section
                    _buildHeaderSection(isSmallScreen),

                    SizedBox(height: size.height * 0.04),

                    // Password Input Field
                    _buildPasswordInputField(size),

                    SizedBox(height: size.height * 0.02),

                    // Confirm Password Input Field
                    _buildConfirmPasswordInputField(size),

                    SizedBox(height: size.height * 0.03),

                    // Password Strength Indicator
                    _buildPasswordStrengthIndicator(passwordStrength),

                    SizedBox(height: size.height * 0.03),

                    // Password Requirements
                    _buildPasswordRequirements(),

                    const Spacer(),

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

  Widget _buildIllustrationSection(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        children: [
          // Animated Security Icon Container
          Container(
            width: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            height: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF9F43), Color(0xFFFECA57)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9F43).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.security_rounded,
                color: Colors.white, size: 40),
          ),

          SizedBox(height: size.height * 0.03),

          // Title
          Text(
            "Create Password",
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

  Widget _buildHeaderSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Secure Your Account",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),

        SizedBox(height: isSmallScreen ? 8 : 12),

        Text(
          "Create a strong password to protect your wallet. Make sure it's unique and easy for you to remember.",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            height: 1.5,
            color: Colors.grey.shade600,
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
            boxShadow: _isFocused ? [
              BoxShadow(
                color: const Color(0xFFFF9F43).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ] : [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Container(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    _isPasswordVisible ?
                    Icons.visibility_off_rounded :
                    Icons.visibility_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _isFocused ? const Color(0xFFFF9F43) : Colors.grey.shade300,
                  width: _isFocused ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF9F43),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (value) => setState(() {}),
            onTap: () => setState(() { _isFocused = true; }),
            onSubmitted: (_) => _continue(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordInputField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm Password",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),

        SizedBox(height: size.height * 0.01),

        Container(
          decoration: BoxDecoration(
            boxShadow: _isConfirmFocused ? [
              BoxShadow(
                color: const Color(0xFFFF9F43).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ] : [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Container(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ?
                    Icons.visibility_off_rounded :
                    Icons.visibility_rounded,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _isConfirmFocused ? const Color(0xFFFF9F43) : Colors.grey.shade300,
                  width: _isConfirmFocused ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF9F43),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (value) => setState(() {}),
            onTap: () => setState(() { _isConfirmFocused = true; }),
            onSubmitted: (_) => _continue(),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator(int strength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password Strength",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),

        SizedBox(height: 8),

        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Expanded(
                flex: strength,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getStrengthColors(strength),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(
                flex: 4 - strength,
                child: const SizedBox(),
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        Text(
          _getStrengthText(strength),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _getStrengthColor(strength),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final requirements = [
      {
        'text': 'At least 8 characters',
        'isValid': _passwordController.text.length >= 8,
      },
      {
        'text': 'Uppercase letter or symbol',
        'isValid': RegExp(r'[A-Z]').hasMatch(_passwordController.text) ||
            RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text),
      },
      {
        'text': 'Contains a number',
        'isValid': RegExp(r'[0-9]').hasMatch(_passwordController.text),
      },
      {
        'text': 'Passwords match',
        'isValid': _isConfirmPasswordValid,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Requirements",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),

        SizedBox(height: 12),

        Column(
          children: requirements.map((req) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: req['isValid'] as bool ?
                      const Color(0xFF00B894) : Colors.transparent,
                      border: Border.all(
                        color: req['isValid'] as bool ?
                        const Color(0xFF00B894) : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: req['isValid'] as bool ?
                    const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      req['text'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: req['isValid'] as bool ?
                        Colors.grey.shade800 : Colors.grey.shade500,
                        fontWeight: req['isValid'] as bool ?
                        FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContinueButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, size.height * 0.065),
          backgroundColor: _isFormValid ?
          const Color(0xFFFF9F43) : Colors.grey.shade300,
          foregroundColor: _isFormValid ?
          Colors.white : Colors.grey.shade500,
          elevation: _isFormValid ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shadowColor: _isFormValid ?
          const Color(0xFFFF9F43).withOpacity(0.3) : Colors.transparent,
        ),
        onPressed: _isFormValid ? _continue : null,
        child: Text(
          "Create Password",
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