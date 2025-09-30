import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:spw/http/api_crypter.dart';
import 'package:spw/dashboard/models/dash_models.dart';

class ScanQRMarchandScreen extends StatefulWidget {
  const ScanQRMarchandScreen({super.key});

  @override
  State<ScanQRMarchandScreen> createState() => _ScanQRMarchandScreenState();
}

class _ScanQRMarchandScreenState extends State<ScanQRMarchandScreen> 
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedResult;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _borderColorAnimation = ColorTween(
      begin: const Color(0xFF8B5CF6).withOpacity(0.5),
      end: const Color(0xFF8B5CF6),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background with gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                      Colors.black,
                    ],
                  ),
                ),
              ),

              // Main Content
              Column(
                children: [
                  // Enhanced App Bar
                  _buildEnhancedAppBar(isSmallScreen),
                  
                  // Scanner Section
                  Expanded(
                    flex: 6,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: _buildEnhancedQrView(context, size),
                      ),
                    ),
                  ),

                  // Control Section
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.5),
                        child: _buildEnhancedControlSection(isSmallScreen, size),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnhancedAppBar(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Marchand',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Scannez le QR code du marchand',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
              ],
            ),
          ),
          
          // Flash Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: _isFlashOn
                  ? Icon(Icons.flash_on, color: Colors.yellow.shade300)
                  : const Icon(Icons.flash_off, color: Colors.white),
              onPressed: _toggleFlash,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQrView(BuildContext context, Size size) {
    return Stack(
      children: [
        // Camera Preview
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            if (!_isProcessing) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_isProcessing) {
                  setState(() {
                    scannedResult = barcode.rawValue;
                    _isProcessing = true;
                  });
                  
                  _processScannedMerchantCode(barcode.rawValue!);
                  break;
                }
              }
            }
          },
        ),

        // Scanner Overlay
        if (_isCameraInitialized)
          AnimatedBuilder(
            animation: _borderColorAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: EnhancedQrScannerOverlay(
                  borderColor: _borderColorAnimation.value!,
                  scanLineColor: const Color(0xFF8B5CF6),
                  isAnimating: _animationController.status == AnimationStatus.forward,
                ),
              );
            },
          ),

        // Scanning Instructions
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.store_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  scannedResult ?? 'Scannez le QR code du marchand',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scannedResult != null ? const Color(0xFF00B894) : Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: scannedResult != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (scannedResult != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Code marchand détecté',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Corner Decorations
        Positioned(
          top: size.height * 0.15,
          left: size.width * 0.15,
          child: _buildCornerDecoration(true, false),
        ),
        Positioned(
          top: size.height * 0.15,
          right: size.width * 0.15,
          child: _buildCornerDecoration(false, false),
        ),
        Positioned(
          bottom: size.height * 0.25,
          left: size.width * 0.15,
          child: _buildCornerDecoration(true, true),
        ),
        Positioned(
          bottom: size.height * 0.25,
          right: size.width * 0.15,
          child: _buildCornerDecoration(false, true),
        ),
      ],
    );
  }

  Widget _buildCornerDecoration(bool isLeft, bool isBottom) {
    return Transform.rotate(
      angle: isBottom ? (isLeft ? 3 * 3.14159 / 2 : 3.14159) : (isLeft ? 0 : 3.14159 / 2),
      child: Container(
        width: 40,
        height: 40,
        child: CustomPaint(
          painter: CornerDecorationPainter(
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedControlSection(bool isSmallScreen, Size size) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (scannedResult != null) ...[
            // Scanned Result Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(bottom: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marchand Détecté',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _truncateText(scannedResult!, length: 25),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 12 : 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedActionButton(
                    'Payer',
                    Icons.payment_rounded,
                    const Color(0xFF8B5CF6),
                    _processMerchantPayment,
                    isSmallScreen,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildEnhancedActionButton(
                    'Rescanner',
                    Icons.refresh_rounded,
                    const Color(0xFFFD79A8),
                    _resetScan,
                    isSmallScreen,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Default State
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Scannez le QR code d\'un marchand',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ), 
                Text(
                  'Assurez-vous d\'avoir un bon éclairage',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton(String text, IconData icon, Color color, VoidCallback onTap, bool isSmallScreen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.2)!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isSmallScreen ? 18 : 20),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processScannedMerchantCode(String code) {
    // Process the scanned merchant code
    _verifyMerchantCode(code);
  }

  Future<void> _verifyMerchantCode(String codeBoutique) async {
    const String baseUrl = 'https://spw.demo-tunisie.tn/api/marchand/code/verifCodeBoutique';
    
    try {
      _showLoadingDialog('Vérification du marchand...');

      // Get tokens from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? nextToken = prefs.getString('nextToken');

      if (token == null || token.isEmpty) {
        Navigator.pop(context);
        _showEnhancedErrorDialog('Session expirée', 'Veuillez vous reconnecter.');
        return;
      }
 
      // Generate keys
      final String idempotencyKey = ApiCrypter.generateKey();
      final String encryptedKey = ApiCrypter.crypt(idempotencyKey);

      // Create headers
      final headers = {
        'token': token,
        if (nextToken != null && nextToken.isNotEmpty) 'NextToken': nextToken,
        'idempotencykey': idempotencyKey,
        'key': encryptedKey,
      };

      // Create form data
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['codeBoutique'] = codeBoutique;
      
      // Add headers
      request.headers.addAll(headers);

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
        final merchantResponse = MerchantVerificationResponse.fromJson(jsonResponse);
        
        if (merchantResponse.isSuccess) {
          // Save nextToken if present in response
          if (merchantResponse.nextToken.isNotEmpty) {
            await prefs.setString('nextToken', merchantResponse.nextToken);
          }
          
          Navigator.pop(context); // Close loading dialog
          _showPaymentAmountDialog(merchantResponse);
        } else {
          Navigator.pop(context); // Close loading dialog
          _showEnhancedErrorDialog(
            'Code marchand invalide',
            'Le code marchand scanné est invalide ou n\'existe pas.'
          );
        }
      } else {
        Navigator.pop(context); // Close loading dialog
        _showEnhancedErrorDialog(
          'Erreur de connexion',
          'Impossible de vérifier le code marchand. Code: ${response.statusCode}'
        );
      }

    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showEnhancedErrorDialog(
        'Erreur',
        'Une erreur s\'est produite lors de la vérification: $e'
      );
    }
  }

  void _showPaymentAmountDialog(MerchantVerificationResponse merchant) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Merchant Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: merchant.logo.isNotEmpty 
                        ? DecorationImage(
                            image: NetworkImage(merchant.logo),
                            fit: BoxFit.cover,
                          )
                        : null,
                      color: merchant.logo.isEmpty ? const Color(0xFF8B5CF6).withOpacity(0.1) : null,
                    ),
                    child: merchant.logo.isEmpty 
                      ? Icon(Icons.store_rounded, color: Color(0xFF8B5CF6), size: 28)
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.nomBoutique,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${scannedResult}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Amount Limits
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLimitItem('Minimum', '${merchant.montantMin} DT'),
                    Container(width: 1, height: 30, color: const Color(0xFF3B82F6).withOpacity(0.3)),
                    _buildLimitItem('Maximum', '${merchant.montantMax} DT'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Amount Input
              const Text(
                'Montant du paiement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: 'Entrez le montant',
                    prefixText: 'DT ',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Quick Amount Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [10, 20, 50, 100, 200, 500].where((amount) {
                  final min = double.tryParse(merchant.montantMin) ?? 1;
                  final max = double.tryParse(merchant.montantMax) ?? 3000;
                  return amount >= min && amount <= max;
                }).map((amount) {
                  return GestureDetector(
                    onTap: () {
                      amountController.text = amount.toString();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '$amount DT',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        final min = double.tryParse(merchant.montantMin) ?? 1;
                        final max = double.tryParse(merchant.montantMax) ?? 3000;
                        
                        if (amount < min) {
                          _showEnhancedErrorDialog(
                            'Montant trop faible',
                            'Le montant minimum est de $min DT.'
                          );
                        } else if (amount > max) {
                          _showEnhancedErrorDialog(
                            'Montant trop élevé',
                            'Le montant maximum est de $max DT.'
                          );
                        } else if (amount > 0) {
                          Navigator.pop(context);
                          await _verifyPaymentAmount(merchant, amount);
                        } else {
                          _showEnhancedErrorDialog(
                            'Montant invalide',
                            'Veuillez saisir un montant valide.'
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Payer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPaymentAmount(MerchantVerificationResponse merchant, double amount) async {
    const String baseUrl = 'https://spw.demo-tunisie.tn/api/marchand/code/verifCodeBoutique';
    
    try {
      _showLoadingDialog('Vérification du paiement...');

      // Get tokens from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? nextToken = prefs.getString('nextToken');

      if (token == null || token.isEmpty) {
        Navigator.pop(context);
        _showEnhancedErrorDialog(
          'Session expirée',
          'Veuillez vous reconnecter pour effectuer le paiement.'
        );
        return;
      }
 
      // Generate keys
      final String idempotencyKey = ApiCrypter.generateKey();
      final String encryptedKey = ApiCrypter.crypt(idempotencyKey);

      // Create headers
      final headers = {
        'token': token,
        if (nextToken != null && nextToken.isNotEmpty) 'NextToken': nextToken,
        'idempotencykey': idempotencyKey,
        'key': encryptedKey,
      };

      // Create form data
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['codeBoutique'] = scannedResult!;
      request.fields['montant'] = amount.toString();
      
      // Add headers
      request.headers.addAll(headers);

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Check if request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
        final paymentResponse = PaymentVerificationResponse.fromJson(jsonResponse);
        
        if (paymentResponse.isSuccess) {
          // Save nextToken if present in response
          if (paymentResponse.nextToken.isNotEmpty) {
            await prefs.setString('nextToken', paymentResponse.nextToken);
          }
          
          Navigator.pop(context); // Close loading dialog
          _showPaymentMethodsDialog(paymentResponse);
        } else {
          Navigator.pop(context); // Close loading dialog
          _showEnhancedErrorDialog(
            'Erreur de vérification',
            'Impossible de vérifier le paiement: ${paymentResponse.state} - ${paymentResponse.code}'
          );
        }
      } else {
        Navigator.pop(context); // Close loading dialog
        _showEnhancedErrorDialog(
          'Erreur de connexion',
          'Impossible de vérifier le paiement. Code: ${response.statusCode}'
        );
      }

    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showEnhancedErrorDialog(
        'Erreur',
        'Une erreur s\'est produite lors de la vérification: $e'
      );
    }
  }

  void _showPaymentMethodsDialog(PaymentVerificationResponse payment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: payment.logo.isNotEmpty 
                        ? DecorationImage(
                            image: NetworkImage(payment.logo),
                            fit: BoxFit.cover,
                          )
                        : null,
                      color: payment.logo.isEmpty ? const Color(0xFF8B5CF6).withOpacity(0.1) : null,
                    ),
                    child: payment.logo.isEmpty 
                      ? Icon(Icons.store_rounded, color: Color(0xFF8B5CF6), size: 28)
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.nomBoutique,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${payment.montant} DT',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Payment Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildPaymentDetailItem('Montant à payer', '${payment.montantPay} DT'),
                    if (payment.remise > 0)
                      _buildPaymentDetailItem('Remise', '-${payment.remise} DT'),
                    if (payment.bonusClient != "0.000")
                      _buildPaymentDetailItem('Bonus client', '+${payment.bonusClient} DT'),
                    _buildPaymentDetailItem('Commission', '${payment.commissionSupplementaire}%'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Payment Methods
              const Text(
                'Méthodes de paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ...payment.paymentMethods.map((method) => _buildPaymentMethodItem(method, payment)),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method, PaymentVerificationResponse payment) {
    return GestureDetector(
      onTap: () => _handlePaymentMethodSelection(method, payment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPaymentMethodIcon(method.methode),
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.libelle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (method.solde != null)
                    Text(
                      'Solde: ${method.solde} DT',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (method.listWallets.isNotEmpty)
                    ...method.listWallets.map((wallet) => Text(
                      'Portefeuille: ${wallet['wallet_solde']} DT',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    )).toList(),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF6B7280),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentMethodSelection(PaymentMethod method, PaymentVerificationResponse payment) {
    if (method.methode == 'sf' || method.methode == 'wallet') {
      _showPinDialog(method, payment);
    } else if (method.methode == 'cb' || method.methode == 'cbi') {
      _showEnhancedErrorDialog('Paiement par carte', 'Le paiement par carte bancaire sera disponible prochainement.');
    } else {
      _showEnhancedErrorDialog('Méthode non supportée', 'Cette méthode de paiement n\'est pas encore disponible.');
    }
  }

  void _showPinDialog(PaymentMethod method, PaymentVerificationResponse payment) {
    final pinController = TextEditingController();
    final etiquetteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirmation de paiement',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${payment.montant} DT - ${payment.nomBoutique}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // PIN Input
              const Text(
                'Code PIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: pinController,
                  decoration: InputDecoration(
                    hintText: 'Entrez votre code PIN',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Etiquette (optional)
              const Text(
                'Étiquette (optionnel)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: etiquetteController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Achat en magasin',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (pinController.text.length != 6) {
                          _showEnhancedErrorDialog('PIN invalide', 'Le code PIN doit contenir 6 chiffres.');
                          return;
                        }
                        
                        Navigator.pop(context); // Close PIN dialog
                        await _processPayment(
                          method: method,
                          payment: payment,
                          pin: pinController.text,
                          wallet_idPaiement: method.methode == 'wallet' && method.listWallets.isNotEmpty
                            ? method.listWallets.first['wallet_idPaiement'].toString()
                            : '',
                          etiquette: etiquetteController.text.isEmpty ? 'Paiement QR Marchand' : etiquetteController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirmer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment({
    required PaymentMethod method,
    required PaymentVerificationResponse payment,
    required String pin,
    required String etiquette,
    String wallet_idPaiement = '',
  }) async {
    const String baseUrl = 'https://spw.demo-tunisie.tn/api/marchand/code/validerPaiementCodeBoutique';
    
    try {
      _showLoadingDialog('Traitement du paiement...');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? nextToken = prefs.getString('nextToken');

      if (token == null || token.isEmpty) {
        Navigator.pop(context);
        _showEnhancedErrorDialog('Session expirée', 'Veuillez vous reconnecter pour effectuer le paiement.');
        return;
      }
 
      final String idempotencyKey = ApiCrypter.generateKey();
      final String encryptedKey = ApiCrypter.crypt(idempotencyKey);

      final headers = {
        'token': token,
        if (nextToken != null && nextToken.isNotEmpty) 'NextToken': nextToken,
        'idempotencykey': idempotencyKey,
        'key': encryptedKey,
      };

      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
      request.fields['codeBoutique'] = scannedResult!;
      request.fields['montant'] = payment.montant;
      request.fields['etiquette'] = etiquette;
      request.fields['modePaiement'] = method.methode;
      request.fields['pin'] = pin;
      request.fields['wallet_idPaiement'] = wallet_idPaiement;
      
      request.headers.addAll(headers);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
        final validationResponse = PaymentValidationResponse.fromJson(jsonResponse);
        
        if (validationResponse.isSuccess) {
          if (validationResponse.nextToken.isNotEmpty) {
            await prefs.setString('nextToken', validationResponse.nextToken);
          }
          
          Navigator.pop(context); // Close loading dialog
          _showPaymentSuccessDialog(validationResponse);
        } else {
          Navigator.pop(context); // Close loading dialog
          _showEnhancedErrorDialog('Échec du paiement', 'Le paiement a échoué: ${validationResponse.message}');
        }
      } else {
        Navigator.pop(context); // Close loading dialog
        _showEnhancedErrorDialog('Erreur de connexion', 'Impossible de traiter le paiement. Code: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showEnhancedErrorDialog('Erreur', 'Une erreur s\'est produite lors du traitement: $e');
    }
  }

  void _showPaymentSuccessDialog(PaymentValidationResponse payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Paiement Réussi !',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                payment.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              // Transaction Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildTransactionDetailItem('Marchand', payment.nomBoutique),
                    _buildTransactionDetailItem('Montant', '${payment.montant} DT'),
                    _buildTransactionDetailItem('Transaction', payment.idTransaction),
                    _buildTransactionDetailItem('Date', _formatDateTime(payment.datePaiement)),
                    _buildTransactionDetailItem('Mode de paiement', payment.modePaiement),
                    _buildTransactionDetailItem('Nouveau solde', '${payment.soldeAfterPayment} DT'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Navigator.pop(context); // Close payment methods dialog
                    _resetScan();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Terminer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildPaymentDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  IconData _getPaymentMethodIcon(String methode) {
    switch (methode) {
      case 'cb':
        return Icons.credit_card_rounded;
      case 'cbi':
        return Icons.credit_card_rounded;
      case 'sf':
        return Icons.account_balance_wallet_rounded;
      case 'wallet':
        return Icons.wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnhancedErrorDialog(String title, String message) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFDC2626),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processMerchantPayment() {
    if (scannedResult != null) {
      _verifyMerchantCode(scannedResult!);
    }
  }

  void _resetScan() {
    setState(() {
      scannedResult = null;
      _isProcessing = false;
    });
    cameraController.start();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    cameraController.toggleTorch();
  }

  String _truncateText(String text, {int length = 30}) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}

// Reuse the same custom painters from your reference screen
class EnhancedQrScannerOverlay extends CustomPainter {
  final Color borderColor;
  final Color scanLineColor;
  final bool isAnimating;

  EnhancedQrScannerOverlay({
    required this.borderColor,
    required this.scanLineColor,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.7;
    final height = width;
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;
    final rect = Rect.fromLTWH(left, top, width, height);

    // Draw semi-transparent overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw outer transparent area
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final transparentPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)));
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      transparentPath,
    );

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw animated border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = LinearGradient(
        colors: [borderColor, borderColor.withOpacity(0.7), borderColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      borderPaint,
    );

    // Draw animated scan line
    if (isAnimating) {
      final scanLinePaint = Paint()
        ..color = scanLineColor
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: [
            scanLineColor.withOpacity(0.1),
            scanLineColor,
            scanLineColor.withOpacity(0.1),
          ],
        ).createShader(Rect.fromLTRB(left, top, left + width, top + height));

      final scanLineY = top + (DateTime.now().millisecond / 1000) * height;
      canvas.drawRect(
        Rect.fromLTRB(left + 10, scanLineY, left + width - 10, scanLineY + 2),
        scanLinePaint,
      );
    }

    // Draw enhanced corners
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 25.0;
    const cornerWidth = 4.0;

    // Top left corner
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top right corner
    canvas.drawLine(Offset(left + width, top), Offset(left + width - cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left + width, top), Offset(left + width, top + cornerLength), cornerPaint);

    // Bottom left corner
    canvas.drawLine(Offset(left, top + height), Offset(left + cornerLength, top + height), cornerPaint);
    canvas.drawLine(Offset(left, top + height), Offset(left, top + height - cornerLength), cornerPaint);

    // Bottom right corner
    canvas.drawLine(Offset(left + width, top + height), Offset(left + width - cornerLength, top + height), cornerPaint);
    canvas.drawLine(Offset(left + width, top + height), Offset(left + width, top + height - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CornerDecorationPainter extends CustomPainter {
  final Color color;

  CornerDecorationPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLength = 15.0;

    // Draw L-shaped corner
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}