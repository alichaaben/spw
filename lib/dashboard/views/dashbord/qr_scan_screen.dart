import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:spw/http/api_crypter.dart';
import 'package:spw/dashboard/models/dash_models.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with SingleTickerProviderStateMixin {
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
      begin: const Color(0xFF6C5CE7).withOpacity(0.5),
      end: const Color(0xFF6C5CE7),
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
                  'Scan & Pay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Align QR code within frame',
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
                  
                  _processScannedCode(barcode.rawValue!);
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
                  scanLineColor: const Color(0xFF6C5CE7),
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
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  scannedResult ?? 'Position QR code in frame',
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
                    'Tap "Process Payment" to continue',
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
            color: const Color(0xFF6C5CE7),
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
                  colors: [Color(0xFF00B894), Color(0xFF00CEA9)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B894).withOpacity(0.4),
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
                      Icons.check_rounded,
                      color: Color(0xFF00B894),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QR Code Scanned',
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
                    'Process',
                    Icons.payment_rounded,
                    const Color(0xFF6C5CE7),
                    _processPayment,
                    isSmallScreen,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _buildEnhancedActionButton(
                    'Rescan',
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
                    Icons.qr_code_2_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Scan any SPW QR code to pay',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ), 
                Text(
                  'Ensure good lighting and steady hands',
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

  void _processScannedCode(String code) {
    _showAmountInputDialog(code);
  }

  void _showAmountInputDialog(String walletId) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFF836FFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'Enter amount to send',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Wallet Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: const Color(0xFF10B981), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Wallet: ${_truncateText(walletId, length: 20)}',
                          style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Amount Input
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (DT)',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      child: Text(
                        'DT',
                        style: TextStyle(
                          color: const Color(0xFF6C5CE7),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                // Description Input
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.description_rounded, color: Colors.grey.shade500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetScan();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            _showEnhancedErrorDialog('Please enter a valid amount');
                            return;
                          }
                          Navigator.pop(context);
                          _processWalletTransfer(
                            walletId, 
                            amount, 
                            descriptionController.text.isEmpty 
                              ? 'QR Payment' 
                              : descriptionController.text
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
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
      ),
    );
  }

  Future<void> _processWalletTransfer(String walletId, double amount, String description) async {
    try {
      _showLoadingDialog('Verifying recipient...');

      final verificationResponse = await _verifyWalletRecipient(walletId, amount, description);
      
      if (verificationResponse.isSuccess) {
        Navigator.pop(context);
        _showWalletTransferConfirmation(verificationResponse, amount, description);
      } else {
        Navigator.pop(context);
        _showEnhancedErrorDialog('Invalid wallet address or recipient not found');
      }
    } catch (e) {
      Navigator.pop(context);
      _showEnhancedErrorDialog('Error verifying recipient: $e');
    }
  }

  Future<TransferRequestResponse> _verifyWalletRecipient(String walletNumber, double montant, String etiquette) async {
    const String baseUrl = 'https://spw.demo-tunisie.tn/api/transfertsolde/demandeTransfertSolde';
    
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? nextToken = prefs.getString('nextToken');

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please login again.');
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
      var uuid = prefs.getString('idUnique');
      request.fields['identifiant'] = walletNumber;
      request.fields['wallet_idPaiement'] = uuid ?? '';
      request.fields['montant'] = montant.toString();
      request.fields['etiquette'] = etiquette;

      request.headers.addAll(headers);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
        final verificationResponse = TransferRequestResponse.fromJson(jsonResponse);
        
        if (verificationResponse.isSuccess) {
          if (verificationResponse.nextToken.isNotEmpty) {
            await prefs.setString('nextToken', verificationResponse.nextToken);
          }
          return verificationResponse;
        } else {
          throw Exception('Wallet verification failed: ${verificationResponse.state}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: $responseData');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _showWalletTransferConfirmation(TransferRequestResponse recipient, double amount, String description) {
    final pinController = TextEditingController();
    final fee = _calculateFee(amount);
    final totalAmount = amount + fee;

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
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_rounded,
                      color: Color(0xFF6C5CE7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QR Payment Confirmation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          recipient.fullName,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildTransferDetailItem('Recipient', recipient.fullName),
                    _buildTransferDetailItem('Wallet ID', scannedResult ?? ''),
                    _buildTransferDetailItem('Amount', '${amount.toStringAsFixed(3)} DT'),
                    _buildTransferDetailItem('Fee', '${fee.toStringAsFixed(3)} DT'),
                    _buildTransferDetailItem('Total', '${totalAmount.toStringAsFixed(3)} DT', isTotal: true),
                    if (description.isNotEmpty)
                      _buildTransferDetailItem('Description', description),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Security PIN',
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
                  decoration: const InputDecoration(
                    hintText: 'Enter your PIN',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              const SizedBox(height: 24),
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
                        'Cancel',
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
                          _showEnhancedErrorDialog('Please enter a valid 6-digit PIN');
                          return;
                        }
                        Navigator.pop(context);
                        await _executeWalletTransfer(recipient, pinController.text, amount, description);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pay Now',
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

  Future<void> _executeWalletTransfer(TransferRequestResponse recipient, String pin, double amount, String description) async {
    const String baseUrl = 'https://spw.demo-tunisie.tn/api/transfertsolde/validationTransfertSolde';
    
    try {
      _showLoadingDialog('Processing payment...');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? nextToken = prefs.getString('nextToken');

      if (token == null || token.isEmpty) {
        Navigator.pop(context);
        _showEnhancedErrorDialog('Please login again to make payments');
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
      request.fields['identifiant'] = scannedResult!;
      request.fields['wallet_idPaiement'] = prefs.getString('idUnique') ?? '';
      request.fields['montant'] = amount.toString();
      request.fields['etiquette'] = description.isEmpty ? 'QR Payment' : description;
      request.fields['modePaiement'] = 'wallet';
      request.fields['pin'] = pin;
      
      request.headers.addAll(headers);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
        final transferResponse = WalletTransferResponse.fromJson(jsonResponse);
        
        if (transferResponse.isSuccess) {
          if (transferResponse.nextToken.isNotEmpty) {
            await prefs.setString('nextToken', transferResponse.nextToken);
          }
          Navigator.pop(context);
          _showEnhancedTransferSuccess(transferResponse);
        } else {
          Navigator.pop(context);
          _showEnhancedErrorDialog('Payment failed: ${transferResponse.message}');
        }
      } else {
        Navigator.pop(context);
        _showEnhancedErrorDialog('Payment failed with status: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      _showEnhancedErrorDialog('Payment error: $e');
    }
  }

  void _showEnhancedTransferSuccess(WalletTransferResponse transfer) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
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
                const SizedBox(height: 20),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  transfer.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildTransactionSuccessItem('Transaction', transfer.idTransaction),
                      _buildTransactionSuccessItem('Amount', '${transfer.montant} DT'),
                      _buildTransactionSuccessItem('Recipient', transfer.numeroDestinataire),
                      _buildTransactionSuccessItem('Date', transfer.datePaiement),
                      _buildTransactionSuccessItem('New Balance', '${transfer.soldeAfterPayment} DT'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetScan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
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

  Widget _buildTransferDetailItem(String label, String value, {bool isTotal = false}) {
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
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isTotal ? const Color(0xFF6C5CE7) : const Color(0xFF1F2937),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSuccessItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
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

  void _showEnhancedErrorDialog(String message) {
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
                  'Error',
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
                      backgroundColor: const Color(0xFF6C5CE7),
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

  void _processPayment() {
    if (scannedResult != null) {
      _showAmountInputDialog(scannedResult!);
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

  double _calculateFee(double amount) {
    if (amount <= 0) return 0.0;
    final fee = amount * 0.005;
    return fee < 0.1 ? 0.1 : fee;
  }

  String _truncateText(String text, {int length = 30}) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}

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