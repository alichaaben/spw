import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spw/authentication/views/confirm_code_screen.dart';

class VerificationModal extends StatefulWidget {
  const VerificationModal({super.key});

  @override
  State<VerificationModal> createState() => _VerificationModalState();
}

class _VerificationModalState extends State<VerificationModal> {
  final _phoneController = TextEditingController();
  final _cinController = TextEditingController();
  String _selectedCountry = 'Tunisia';
  String? _selectedOtpMethod;
  bool _isLoading = false;

  final List<String> _countries = ['Tunisia', 'Canada', 'United Kingdom', 'Algeria', 'France', 'Germany'];
  final List<String> _otpMethods = ['Email', 'Phone'];

  // Global key for overlay
  final GlobalKey _overlayKey = GlobalKey();

  @override
  void dispose() {
    _phoneController.dispose();
    _cinController.dispose();
    super.dispose();
  }

  // Enhanced snackbar display method
  void _showEnhancedSnackBar(String message, {bool isError = true, int duration = 4}) {
    // Hide any existing snackbars first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Create a custom overlay entry for better positioning
    final overlay = Overlay.of(context);
    final renderBox = _overlayKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!isError)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - offset.dy + 20,
          left: 16,
          right: 16,
        ),
        duration: Duration(seconds: duration),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Enhanced validation method
  String? _validateForm() {
    if (_selectedCountry.isEmpty) {
      return 'Please select your country';
    }
    if (_phoneController.text.isEmpty) {
      return 'Please enter your phone number';
    }
    if (_phoneController.text.length != 8) {
      return 'Phone number must be 8 digits';
    }
    if (_cinController.text.isEmpty) {
      return 'Please enter your CIN number';
    }
    if (_cinController.text.length != 8) {
      return 'CIN number must be 8 digits';
    }
    if (_selectedOtpMethod == null) {
      return 'Please select OTP delivery method';
    }
    return null;
  }

  Future<void> _submitVerification() async {
    // Enhanced validation with specific error messages
    final validationError = _validateForm();
    if (validationError != null) {
      _showEnhancedSnackBar(validationError, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create form data
      var formData = {
        'idPays': '177',
        'phone': _phoneController.text, 
        'numIdentite': _cinController.text,
        'typeEnvoiscode': _selectedOtpMethod == 'Email' ? 'email' : 'sms',
      };
    
      // Make HTTP POST request
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token') ?? '';
      
      final response = await http.post(
        Uri.parse('https://spw.demo-tunisie.tn/api/postAuth/verifIdentite'),  
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'token': token,
        },
        body: formData,
      ).timeout(const Duration(seconds: 30));

      setState(() {
        _isLoading = false;
      });

      // Handle response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('API Response: $responseData');
        
        if (responseData['code'] == '00') {
          // Success case
          final data = responseData['data'];
          print('Verification successful: $data');
          
          // Show success message
          _showEnhancedSnackBar(
            'Verification successful! Redirecting...',
            isError: false,
            duration: 2,
          );

          // Navigate after a short delay to show success message
          await Future.delayed(const Duration(milliseconds: 1500));
          
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmCodePage(
                  contactMethod: _selectedOtpMethod == 'Email' ? 'email' : 'phone',
                  contactValue: _selectedOtpMethod == 'Email' 
                      ? 'user@example.com' // Replace with actual email from response if available
                      : _cinController.text,
                  verificationType: 'login',
                ),
              ),
            );
          }
          
        } else if (responseData['code'] == '01') {
          // Error case
          final errorMessage = responseData['message'] ?? 'An error occurred during verification';
          print('Verification failed: $errorMessage');
          
          _showEnhancedSnackBar(errorMessage, isError: true);
        } else {
          // Handle unexpected code
          _showEnhancedSnackBar(
            'Unexpected response from server. Please try again.',
            isError: true,
          );
        }
      } else {
        // HTTP error
        _showEnhancedSnackBar(
          'Server error (${response.statusCode}). Please try again.',
          isError: true,
        );
      }
    } on http.ClientException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showEnhancedSnackBar(
        'Network connection error. Please check your internet.',
        isError: true,
      );
      print('HTTP Client Error: $e');
    } on TimeoutException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showEnhancedSnackBar(
        'Request timeout. Please try again.',
        isError: true,
      );
      print('Timeout Error: $e');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showEnhancedSnackBar(
        'An unexpected error occurred. Please try again.',
        isError: true,
      );
      print('Unexpected Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final isVerySmallScreen = size.width < 320;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 12 : 20,
        vertical: 20,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          key: _overlayKey, // Key for overlay positioning
          constraints: BoxConstraints(
            maxWidth: 400,
            minWidth: isVerySmallScreen ? 280 : 320,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen ? 16 : 20,
            vertical: isVerySmallScreen ? 16 : 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(size, isSmallScreen),
              
              SizedBox(height: isVerySmallScreen ? 16 : 20),

              // Country Dropdown
              _buildCountryDropdown(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Phone Input Field
              _buildPhoneInputField(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 12 : 16),

              // CIN Input Field
              _buildCINInputField(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 12 : 16),

              // OTP Method Selection
              _buildOtpMethodSelection(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 20 : 24),

              // Enhanced Submit Button with better loading state
              _buildEnhancedSubmitButton(context, size, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Additional Verification",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Please verify your identity to continue",
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.close_rounded, 
                size: 16, color: Colors.grey.shade700),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Country",
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCountry,
            isExpanded: true,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on_rounded, 
                  size: 20, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              hintText: "Select your country",
              hintStyle: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _countries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(
                  country,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCountry = newValue ?? 'Tunisia';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputField(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 8,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone, 
                  size: 20, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your phone number",
              hintStyle: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCINInputField(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CIN Number",
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _cinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.badge_rounded, 
                  size: 20, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your CIN number",
              hintStyle: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                color: Colors.grey.shade400,
              ),
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpMethodSelection(Size size, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "OTP Delivery Method",
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            children: _otpMethods.map((method) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: method == _otpMethods.first
                        ? BorderSide(color: Colors.grey.shade200, width: 1)
                        : BorderSide.none,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: isSmallScreen ? 4 : 8,
                  ),
                  leading: Icon(
                    method == 'Email' ? Icons.email_rounded : Icons.phone_iphone_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  title: Text(
                    method,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  trailing: _selectedOtpMethod == method
                      ? Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedOtpMethod = method;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: method == _otpMethods.first
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          )
                        : method == _otpMethods.last
                            ? const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              )
                            : BorderRadius.zero,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedSubmitButton(BuildContext context, Size size, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, isSmallScreen ? 48 : 52),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        onPressed: _isLoading ? null : _submitVerification,
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Verifying...",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Verify & Continue",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}