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
  String? _selectedCountry;
  String? _selectedOtpMethod;
  bool _isLoading = false;

  final List<String> _countries = ['Tunisia', 'Canada', 'United Kingdom', 'Algeria', 'France', 'Germany'];
  final List<String> _otpMethods = ['Email', 'Phone'];

  @override
  void dispose() {
    _phoneController.dispose();
    _cinController.dispose();
    super.dispose();
  }


Future<void> _submitVerification() async {
  if (_selectedCountry == null || _phoneController.text.isEmpty || _cinController.text.isEmpty || _selectedOtpMethod == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ),
    );
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
    var response = await http.post(
      Uri.parse('https://spw.demo-tunisie.tn/api/postAuth/verifIdentite'),  
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'token' : token ?? '',
      },
      body: formData,
    );

    setState(() {
      _isLoading = false;
    });

    // Handle response
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print('API Response: $responseData');
      
      if (responseData['code'] == '00') {
        // Success case
        var data = responseData['data'];
        print('Verification successful: $data');
        
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
        
      } else if (responseData['code'] == '01') {
        // Error case
        String errorMessage = responseData['message'] ?? 'An error occurred';
        print('Verification failed: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Handle unexpected code
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected response from server'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // HTTP error
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('HTTP Error: ${response.statusCode}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    // Network or other errors
    setState(() {
      _isLoading = false;
    });
    
    print('Error making API call: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
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

              // CIN Input Field
              _buildCINInputField(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 12 : 16),

              // PIN Input Field
              _buildPINInputField(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 12 : 16),

              // OTP Method Selection
              _buildOtpMethodSelection(size, isSmallScreen),
              
              SizedBox(height: isSmallScreen ? 20 : 24),

              // Submit Button
              _buildSubmitButton(context, size, isSmallScreen),
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
          child: Text(
            "Additional Verification",
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              letterSpacing: -0.3,
            ),
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
                _selectedCountry = newValue;
              });
            },
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
            keyboardType: TextInputType.number,
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
              hintText: "Enter your Phone number",
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

  Widget _buildPINInputField(Size size, bool isSmallScreen) {
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

  Widget _buildSubmitButton(BuildContext context, Size size, bool isSmallScreen) {
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
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                "Verify & Continue",
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}