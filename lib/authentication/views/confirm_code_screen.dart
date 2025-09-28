import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:spw/authentication/views/verify_pin_screen.dart';

class ConfirmCodePage extends StatefulWidget {
  final String contactMethod; // 'email' or 'phone'
  final String contactValue; // actual email or phone number
  final String verificationType; // 'login' or 'signup' or other

  const ConfirmCodePage({
    super.key,
    required this.contactMethod,
    required this.contactValue,
    this.verificationType = 'login',
  });

  @override
  State<ConfirmCodePage> createState() => _ConfirmCodePageState();
}

class _ConfirmCodePageState extends State<ConfirmCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _remainingSeconds = 59;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    if (_canResend) {
      setState(() {
        _remainingSeconds = 59;
        _canResend = false;
        _isVerifying = false;
        for (var controller in _controllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
      _startTimer();
 
       
    }
  }

void _verifyCode() async {
  String code = _controllers.map((controller) => controller.text).join();
  if (code.length == 6) {
    setState(() {
      _isVerifying = true;
    });

    try {
      // Prepare verification data
      var verificationData = {
        'scode': code,
      };
      
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token') ?? '';

      // Validate token before making the call
      if (token.isEmpty) {
        setState(() {
          _isVerifying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication token missing'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Make HTTP POST request to verify code
      var response = await http.post(
        Uri.parse('https://spw.demo-tunisie.tn/api/postAuth/verifScodeIdentite'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'token': token,
        },
        body: verificationData,
      );

      setState(() {
        _isVerifying = false;
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('Verification API Response: $responseData');
        
        if (responseData['code'] == '00') {
          // Success case - code verification successful
          var data = responseData['data'];
          print('Code verification successful: $data');
          
          // Store any new token if returned
          // if (data['token'] != null) {
          //   await preferences.setString('token', data['token']);
          // }
          
          if (mounted) {
            _handleSuccessfulVerification();
          }
        } else if (responseData['code'] == '01') {
          _handleVerificationError(responseData['message'] ?? 'Verification failed');
        } else {
          _handleVerificationError('Unexpected response from server');
        }
      } else {
        _handleHttpError(response.statusCode);
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });
      _handleNetworkError(e);
    }
  } else {
    _showErrorMessage('Please enter all 6 digits');
  }
}

// Helper methods for better organization
void _handleSuccessfulVerification() {
  if (widget.verificationType == 'signup') {
    Navigator.pushNamed(context, '/create-password');
  } else {
    if (widget.verificationType != 'login') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VerifyPinScreen(),
        ),
      );
    } else {
      // For login - you might want to get the actual PIN from API response
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyPinScreen(
           ),
        ),
      );
    }
  }
}

void _handleVerificationError(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

void _handleHttpError(int statusCode) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('HTTP Error: $statusCode'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

void _handleNetworkError(dynamic error) {
  print('Error verifying code: $error');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error: ${error.toString()}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

void _showErrorMessage(String message) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
 

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getContactMethodText() {
    return widget.contactMethod == 'email' ? 'email' : 'phone number';
  }

  String _getMaskedContactValue() {
    if (widget.contactMethod == 'email') {
      // Mask email: show first 3 characters and domain
      final parts = widget.contactValue.split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domain = parts[1];
        if (username.length <= 3) {
          return widget.contactValue;
        }
        return '${username.substring(0, 3)}***@$domain';
      }
      return widget.contactValue;
    } else {
      // Mask phone number: show last 4 digits
      if (widget.contactValue.length <= 4) {
        return widget.contactValue;
      }
      return '*** *** ${widget.contactValue.substring(widget.contactValue.length - 4)}';
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
                    _buildBackButton(context),
                    SizedBox(height: size.height * 0.03),
                    _buildIllustrationSection(size, isSmallScreen),
                    SizedBox(height: size.height * 0.04),
                    _buildHeaderSection(isSmallScreen),
                    SizedBox(height: size.height * 0.04),
                    _buildPinInputField(size, isSmallScreen),
                    const Spacer(),
                    _buildBottomSection(),
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

  Widget _buildIllustrationSection(Size size, bool isSmallScreen) {
    return Center(
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            height: isSmallScreen ? size.width * 0.25 : size.width * 0.22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF74B9FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              widget.contactMethod == 'email'
                  ? Icons.email_rounded
                  : Icons.phone_iphone_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Text(
            "Verify Code",
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
          "Enter Verification Code",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
            children: [
              TextSpan(text: "We sent a 6-digit code to your\n"),
              TextSpan(
                text: _getContactMethodText(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const TextSpan(text: "\n"),
              TextSpan(
                text: _getMaskedContactValue(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF74B9FF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputField(Size size, bool isSmallScreen) {
    final boxSize = isSmallScreen ? size.width * 0.12 : size.width * 0.13;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "6-Digit Verification Code",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: boxSize,
              height: boxSize,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3436),
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? const Color(0xFF74B9FF)
                          : Colors.grey.shade300,
                      width: _controllers[index].text.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? const Color(0xFF74B9FF)
                          : Colors.grey.shade300,
                      width: _controllers[index].text.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF74B9FF),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _onChanged(value, index),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        if (_isVerifying) ...[
          Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF74B9FF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Verifying...",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ] else ...[
          Column(
            children: [
              GestureDetector(
                onTap: _canResend ? _resendCode : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _canResend
                        ? const Color(0xFF74B9FF).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: _canResend
                            ? const Color(0xFF74B9FF)
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _canResend
                            ? "Resend Code"
                            : "Resend in ${_formatTime(_remainingSeconds)}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _canResend
                              ? const Color(0xFF74B9FF)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Didn't receive the code? Check your spam folder.",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
