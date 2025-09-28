import 'package:flutter/material.dart';
import 'dart:async';

class ConfirmCodePage extends StatefulWidget {
  const ConfirmCodePage({super.key});

  @override
  State<ConfirmCodePage> createState() => _ConfirmCodePageState();
}

class _ConfirmCodePageState extends State<ConfirmCodePage> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _remainingSeconds = 56;
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
        _remainingSeconds = 56;
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
    if (code.length == 4) {
      setState(() {
        _isVerifying = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        Navigator.pushNamed(context, '/create-password');
      }
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
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
                    _buildPinInputField(size),
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
            child: const Icon(Icons.message_rounded,
                color: Colors.white, size: 40),
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
              const TextSpan(text: "We sent a 4-digit code to\n"),
              TextSpan(
                text: "+1 (562) 859-4936",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Verification Code",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: size.width * 0.16,
              height: size.width * 0.16,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? const Color(0xFF74B9FF)
                          : Colors.grey.shade300,
                      width: _controllers[index].text.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: _controllers[index].text.isNotEmpty
                          ? const Color(0xFF74B9FF)
                          : Colors.grey.shade300,
                      width: _controllers[index].text.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF74B9FF)),
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
          GestureDetector(
            onTap: _canResend ? _resendCode : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _canResend ? const Color(0xFF74B9FF).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: _canResend ? const Color(0xFF74B9FF) : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _canResend
                        ? "Resend Code"
                        : "Resend in ${_formatTime(_remainingSeconds)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _canResend ? const Color(0xFF74B9FF) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}