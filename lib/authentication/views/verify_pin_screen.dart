import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPinScreen extends StatefulWidget {
  const VerifyPinScreen({
    super.key,
  });

  @override
  _VerifyPinScreenState createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _isFirstTime = true; // Will be loaded from SharedPreferences
  BiometricType _availableBiometric = BiometricType.weak;
  String? _storedPin; // Will store the PIN from SharedPreferences

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_pinFocusNode);
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await _loadSharedPreferences();
    await _checkBiometricAvailability();
    
    // If it's not first time and biometric is available, try biometric first
    if (!_isFirstTime && _isBiometricAvailable) {
      await _authenticateWithBiometrics();
    }
  }

  Future<void> _loadSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _isFirstTime = prefs.getBool('isFirst') ?? true;
        _storedPin = prefs.getString('userPin');
      });
      
      print('Loaded from SharedPreferences - isFirst: $_isFirstTime, hasStoredPin: ${_storedPin != null}');
    } catch (e) {
      print('Error loading SharedPreferences: $e');
    }
  }

  Future<void> _savePinToSharedPreferences(String pin) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPin', pin);
      await prefs.setBool('isFirst', false);
      
      setState(() {
        _storedPin = pin;
        _isFirstTime = false;
      });
      
      print('PIN saved to SharedPreferences successfully');
    } catch (e) {
      print('Error saving PIN to SharedPreferences: $e');
      throw Exception('Failed to save PIN');
    }
  }

  // NEW: Save user data to SharedPreferences
  Future<void> _saveUserDataToSharedPreferences(Map<String, dynamic> responseData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Save main response data
      if (responseData['nextToken'] != null) {
        await prefs.setString('nextToken', responseData['nextToken']);
      }
     
      // Save user object data
      if (responseData['user'] != null) {
        final user = responseData['user'];
        
        await prefs.setString('firstName', user['FirstName'] ?? '');
        await prefs.setString('lastName', user['LastName'] ?? '');
        await prefs.setString('userName', user['UserName'] ?? '');
        await prefs.setString('email', user['Email'] ?? '');
        await prefs.setString('birthDate', user['BirthDate'] ?? '');
        await prefs.setDouble('soldeAvoir', double.tryParse(user['SoldeAvoir']?.toString() ?? '0.0') ?? 0.0);
        await prefs.setString('session', user['Session'] ?? '');
        await prefs.setInt('action', int.tryParse(user['Action']?.toString() ?? '0') ?? 0);
        await prefs.setString('ville', user['Ville'] ?? '');
        await prefs.setString('adresse', user['Adresse'] ?? '');
        await prefs.setString('enable', user['Enable'] ?? '');
        await prefs.setString('phone', user['Phone'] ?? '');
        await prefs.setDouble('plafond', double.tryParse(user['plafond']?.toString() ?? '0.0') ?? 0.0);
        await prefs.setString('smsValidation', user['smsValidation'] ?? '');
        await prefs.setString('etat', user['etat'] ?? '');
        await prefs.setString('idUnique', user['id_unique'] ?? '');
        await prefs.setInt('idPays', int.tryParse(user['idPays']?.toString() ?? '0') ?? 0);
        await prefs.setInt('niveau', int.tryParse(user['Niveau']?.toString() ?? '0') ?? 0);
        await prefs.setDouble('soldeWallet', double.tryParse(user['SoldeWallet']?.toString() ?? '0.0') ?? 0.0);
        await prefs.setInt('nbPoint', int.tryParse(user['nbPoint']?.toString() ?? '0') ?? 0);
        await prefs.setString('actualStatus', user['actualStatus'] ?? '');
        await prefs.setString('typeVerification', user['typeVerification'] ?? '');
        await prefs.setInt('pinForPaiement', int.tryParse(user['pinForPaiement']?.toString() ?? '0') ?? 0);
        await prefs.setString('type', user['type'] ?? '');
      }
      
      print('User data saved to SharedPreferences successfully');
      print('Saved user data:');
      print('- Name: ${prefs.getString('firstName')} ${prefs.getString('lastName')}');
      print('- Email: ${prefs.getString('email')}');
      print('- Phone: ${prefs.getString('phone')}');
      print('- Wallet Balance: ${prefs.getDouble('soldeWallet')}');
      print('- Unique ID: ${prefs.getString('idUnique')}');
      
    } catch (e) {
      print('Error saving user data to SharedPreferences: $e');
      throw Exception('Failed to save user data');
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      
      if (!canAuthenticate) {
        return;
      }

      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isNotEmpty) {
        setState(() {
          _isBiometricAvailable = true;
          _availableBiometric = availableBiometrics.first;
        });
      }
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  void _verifyPin() async {
    if (_pinController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // If it's first time, save the PIN and verify automatically
      if (_isFirstTime) {
        if (_pinController.text.length == 6) {
          await _savePinToSharedPreferences(_pinController.text);
          
          // After saving PIN, verify it with API
          await _verifyPinWithApi();
        } else {
          setState(() {
            _isLoading = false;
          });
          _showError('PIN must be exactly 6 digits');
          return;
        }
      } else {
        // Not first time - verify with API
        await _verifyPinWithApi();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _verifyPinWithApi() async {
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

      // Prepare PIN verification data
      var verificationData = {
        'pin': _pinController.text,
      };

      // Make HTTP POST request to verify PIN
      var response = await http.post(
        Uri.parse('https://spw.demo-tunisie.tn/api/postAuth/verifPin'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'token': token,
        },
        body: verificationData,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('Verify PIN API Response: $responseData');
        
        if (responseData['code'] == '00') {
          // NEW: Save user data to SharedPreferences before navigation
          await _saveUserDataToSharedPreferences(responseData);
          
          // Success case - PIN verification successful
          if (mounted) {
            Navigator.pushNamed(context, '/dashboard');
          }
        } else if (responseData['code'] == '01') {
          _showError(responseData['message'] ?? 'Incorrect PIN. Please try again.');
          setState(() {
            _pinController.clear();
          });
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

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      setState(() {
        _isLoading = false;
      });

      if (didAuthenticate) {
        await _handleBiometricSuccess();
      } else {
        _showError('Authentication cancelled');
      }
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _handleBiometricError(e);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Authentication error: ${e.toString()}');
    }
  }

  Future<void> _handleBiometricSuccess() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use the stored PIN for biometric authentication
      if (_storedPin != null) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        var token = preferences.getString('token') ?? '';

        if (token.isEmpty) {
          _showError('Authentication token missing');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Prepare PIN verification data using stored PIN
        var verificationData = {
          'pin': _storedPin!,
        };

        // Make HTTP POST request to verify PIN
        var response = await http.post(
          Uri.parse('https://spw.demo-tunisie.tn/api/postAuth/verifPin'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'token': token,
          },
          body: verificationData,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          print('Biometric PIN Verification Response: $responseData');
          
          if (responseData['code'] == '00') {
            // NEW: Save user data to SharedPreferences before navigation
            await _saveUserDataToSharedPreferences(responseData);
            
            // Success case - navigate to dashboard
            if (mounted) {
              Navigator.pushNamed(context, '/dashboard');
            }
          } else {
            _showError('Biometric authentication failed');
          }
        } else {
          _showError('HTTP Error during biometric authentication: ${response.statusCode}');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _showError('No stored PIN found. Please use PIN login.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error during biometric authentication: ${e.toString()}');
    }
  }

  String _getBiometricApiValue() {
    switch (_availableBiometric) {
      case BiometricType.face:
        return 'face';
      case BiometricType.iris:
        return 'iris';
      case BiometricType.fingerprint:
      default:
        return 'fingerprint';
    }
  }

  IconData _getBiometricIcon() {
    switch (_availableBiometric) {
      case BiometricType.face:
        return Icons.face_rounded;
      case BiometricType.iris:
        return Icons.remove_red_eye_rounded;
      case BiometricType.fingerprint:
      default:
        return Icons.fingerprint_rounded;
    }
  }

  String _getBiometricText() {
    switch (_availableBiometric) {
      case BiometricType.face:
        return 'Use Face ID';
      case BiometricType.iris:
        return 'Use Iris Scan';
      case BiometricType.fingerprint:
      default:
        return 'Use Fingerprint';
    }
  }

  void _handleBiometricError(PlatformException e) {
    switch (e.code) {
      case 'PasscodeNotSet':
        _showError('Please set up device passcode to use biometric authentication');
        break;
      case 'LockedOut':
        _showError('Too many failed attempts. Biometric authentication is temporarily locked');
        break;
      case 'NotEnrolled':
        _showError('No biometric credentials enrolled on this device');
        break;
      case 'NotAvailable':
        _showError('Biometric authentication is not available on this device');
        break;
      case 'PermanentlyLockedOut':
        _showError('Biometric authentication is permanently locked. Please use PIN instead');
        break;
      case 'UserCanceled':
        // User canceled the authentication, no need to show error
        break;
      case 'AuthenticationFailed':
        _showError('Authentication failed. Please try again');
        break;
      default:
        _showError('Biometric authentication error: ${e.message}');
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

                      // Header Section - Dynamic based on first time or not
                      _buildHeaderSection(),

                      const SizedBox(height: 40),

                      // PIN Input Section
                      _buildPinInputSection(),

                      const Spacer(),

                      // Action Section
                      _buildActionSection(),
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
          child: Icon(
            _isFirstTime ? Icons.lock_open_rounded : Icons.lock_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _isFirstTime ? 'Create your PIN' : 'Enter your PIN',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _isFirstTime 
                ? 'Create a 6-digit PIN to secure your account'
                : 'Enter your PIN to access your account',
            style: const TextStyle(
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

  Widget _buildPinInputSection() {
    return Column(
      children: [
        // PIN Input Field
        Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: TextField(
            controller: _pinController,
            focusNode: _pinFocusNode,
            obscureText: _obscureText,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6, // Fixed to 6 digits
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 4,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: _isFirstTime ? 'Create 6-digit PIN' : 'Enter PIN',
              hintStyle: const TextStyle(
                color: Colors.grey,
                letterSpacing: 0,
              ),
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
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.grey.shade500,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
              counterText: '',
            ),
            onChanged: (value) {
              setState(() {});
              // Auto-submit when 6 digits are entered for first-time users
              if (_isFirstTime && value.length == 6) {
                _verifyPin();
              }
            },
            onSubmitted: (value) {
              if (_pinController.text.length == 6) {
                _verifyPin();
              }
            },
          ),
        ),

        const SizedBox(height: 12),

        // PIN Length Indicator
        _buildPinLengthIndicator(),
      ],
    );
  }

  Widget _buildPinLengthIndicator() {
    final length = _pinController.text.length;
    final isFirstTime = _isFirstTime;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Length: $length',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '6 digits',
            style: TextStyle(
              fontSize: 12,
              color: length == 6 ? Colors.green : Colors.grey.shade600,
              fontWeight: length == 6 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        // Action Button
        _buildActionButton(),

        // Biometric Option (only show if available and not first time)
        if (_isBiometricAvailable && !_isFirstTime) _buildBiometricOption(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButton() {
    final isValidPin = _pinController.text.isNotEmpty && 
        _pinController.text.length == 6; // Must be exactly 6 digits

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isValidPin && !_isLoading ? _verifyPin : null,
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
            : Text(
                _isFirstTime ? 'Create & Verify PIN' : 'Verify PIN',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBiometricOption() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          width: double.infinity,
          child: GestureDetector(
            onTap: _isLoading ? null : _authenticateWithBiometrics,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getBiometricIcon(),
                    size: 20,
                    color: const Color(0xFF6C5CE7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getBiometricText(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}