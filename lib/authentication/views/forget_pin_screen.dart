import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPinScreen extends StatefulWidget {
  const ForgetPinScreen({
    super.key,
  });

  @override
  _ForgetPinScreenState createState() => _ForgetPinScreenState();
}

class _ForgetPinScreenState extends State<ForgetPinScreen> {
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _cinFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_cinFocusNode);
    });
  }

  @override
  void dispose() {
    _cinController.dispose();
    _phoneController.dispose();
    _cinFocusNode.dispose();
    super.dispose();
  }

  void _resetPin() async {
    if (_cinController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token') ?? '';

      if (token.isEmpty) {
        _showError('Authentication token missing');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Prepare PIN reset data
      var resetData = {
        'cin': _cinController.text,
        'phone': _phoneController.text,
      };

      // Make HTTP POST request to reset PIN
      var response = await http.post(
        Uri.parse('https://spw.demo-tunisie.tn/api/postAuth/resetPin'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'token': token,
        },
        body: resetData,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('Reset PIN API Response: $responseData');
        
        if (responseData['code'] == '00') {
          // Success case - PIN reset initiated
          var data = responseData['data'];
          print('PIN reset initiated successfully: $data');
          
          // Store any new token if returned
          if (data['token'] != null) {
            await preferences.setString('token', data['token']);
          }
          
          if (mounted) {
            _showSuccess('PIN reset instructions sent to your phone');
            // Navigate to verification screen or back to login
            Navigator.pop(context);
          }
        } else if (responseData['code'] == '01') {
          _showError(responseData['message'] ?? 'PIN reset failed. Please check your information.');
        } else {
          _showError('Unexpected response from server');
        }
      } else {
        _showError('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Network error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      Container(
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
                      ),

                      const SizedBox(height: 32),

                      // Header Section
                      _buildHeaderSection(),

                      const SizedBox(height: 40),

                      // Form Section
                      _buildFormSection(),

                      const Spacer(),

                      // Action Section
                      _buildActionSection(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF6C5CE7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Reset Your PIN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Enter your CIN and phone number to reset your PIN',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          // CIN Input Field
          TextField(
            controller: _cinController,
            focusNode: _cinFocusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'CIN Number',
              hintText: 'Enter your CIN',
              prefixIcon: const Icon(Icons.badge_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
            },
            onSubmitted: (value) {
              FocusScope.of(context).nextFocus();
            },
          ),

          const SizedBox(height: 16),

          // Phone Input Field
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: const Icon(Icons.phone_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {});
            },
            onSubmitted: (value) {
              if (_cinController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                _resetPin();
              }
            },
          ),

          const SizedBox(height: 20),

          // Info Text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF6C5CE7),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We will send PIN reset instructions to your registered phone number',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C5CE7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          // Reset Button
          _buildResetButton(),

          const SizedBox(height: 20),

          // Help Option
          _buildHelpOption(),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    final isValid = _cinController.text.isNotEmpty && _phoneController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValid && !_isLoading ? _resetPin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Reset PIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildHelpOption() {
    return GestureDetector(
      onTap: () {
        _showHelpDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.help_outline_rounded,
              size: 20,
              color: Color(0xFF6C5CE7),
            ),
            SizedBox(width: 8),
            Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C5CE7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Need Help?'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'If you are having trouble resetting your PIN:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '• Ensure your CIN number is correct\n• Use the phone number registered with your account\n• Contact support if you continue to have issues',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}