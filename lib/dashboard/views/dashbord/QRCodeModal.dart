import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:clipboard/clipboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeModal extends StatefulWidget {
  final VoidCallback? onClose;

  const QRCodeModal({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  State<QRCodeModal> createState() => _QRCodeModalState();
}

class _QRCodeModalState extends State<QRCodeModal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String _selectedAction = 'share';
  bool _isCopied = false;
  
  // User data from SharedPreferences
  String _userName = 'Utilisateur';
  String _paymentId = '0000000000';
  double _balance = 0.0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _actions = [
    {'id': 'share', 'icon': Icons.share_rounded, 'label': 'Partager', 'color': Color(0xFF8B5CF6)},
    {'id': 'download', 'icon': Icons.download_rounded, 'label': 'Télécharger', 'color': Color(0xFF06B6D4)},
    {'id': 'copy', 'icon': Icons.content_copy_rounded, 'label': 'Copier', 'color': Color(0xFF10B981)},
    {'id': 'save', 'icon': Icons.bookmark_border_rounded, 'label': 'Sauvegarder', 'color': Color(0xFFF59E0B)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserData();
    _animationController.forward();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _userName = prefs.getString('userName') ?? 'Utilisateur';
        _paymentId = prefs.getString('idUnique') ?? '0000000000';
        _balance = prefs.getDouble('soldeWallet') ?? 0.0;
        _isLoading = false;
      });
      
      print('✅ Loaded user data from SharedPreferences:');
      print('👤 Name: $_userName');
      print('💰 Wallet ID: $_paymentId');
      print('💳 Balance: $_balance');
      
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      maxHeight: size.height * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: _isLoading 
                      ? _buildLoadingState(isSmallScreen)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with gradient background
                            _buildHeader(isSmallScreen),

                            // Content area
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                                child: Column(
                                  children: [
                                    // User Info Section
                                    _buildUserInfoSection(isSmallScreen),
                                    SizedBox(height: isSmallScreen ? 24 : 32),

                                    // QR Code Section
                                    _buildQRCodeSection(isSmallScreen),
                                    SizedBox(height: isSmallScreen ? 24 : 32),

                                    // Payment ID Section
                                    _buildPaymentIdSection(isSmallScreen),
                                    SizedBox(height: isSmallScreen ? 24 : 32),

                                    // Quick Actions
                                    _buildQuickActions(isSmallScreen),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(isSmallScreen),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                ),
                SizedBox(height: 16),
                Text(
                  'Chargement des données...',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF6C5CE7),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mon QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Partagez pour recevoir des paiements',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _closeModal,
            child: Container(
              width: isSmallScreen ? 36 : 44,
              height: isSmallScreen ? 36 : 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF6C5CE7)],
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: isSmallScreen ? 24 : 28,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: $_paymentId',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Solde: ${_balance.toStringAsFixed(3)} DT',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_rounded, size: 14, color: const Color(0xFF10B981)),
                SizedBox(width: 4),
                Text(
                  'Vérifié',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(bool isSmallScreen) {
    return Column(
      children: [
        Text(
          'Scannez pour payer',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              QrImageView(
                data: _paymentId,
                version: QrVersions.auto,
                size: isSmallScreen ? 180 : 220,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1F2937),
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                padding: const EdgeInsets.all(8),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Text(
          'Positionnez le QR code dans le cadre',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: const Color(0xFF6B7280),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentIdSection(bool isSmallScreen) {
    return Column(
      children: [
        Text(
          'ID Paiement',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        GestureDetector(
          onTap: _copyPaymentId,
          onLongPress: _copyPaymentId,
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isCopied ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCopied ? Icons.check_rounded : Icons.fingerprint_rounded,
                  color: _isCopied ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                  size: isSmallScreen ? 18 : 20,
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    _paymentId,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Icon(
                  Icons.content_copy_rounded,
                  color: const Color(0xFF6B7280),
                  size: isSmallScreen ? 16 : 18,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          _isCopied ? 'ID copié avec succès!' : 'Appuyez pour copier l\'ID',
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 12,
            color: _isCopied ? const Color(0xFF10B981) : const Color(0xFF6B7280),
            fontWeight: _isCopied ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    return Column(
      children: [
        Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: isSmallScreen ? 12 : 16,
          mainAxisSpacing: isSmallScreen ? 12 : 16,
          childAspectRatio: 3.0,
          children: _actions.map((action) {
            return _buildActionItem(action, isSmallScreen);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionItem(Map<String, dynamic> action, bool isSmallScreen) {
    final isSelected = _selectedAction == action['id'];

    return GestureDetector(
      onTap: () => _handleAction(action['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: isSelected ? action['color'] : action['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? action['color'] : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: action['color'].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action['icon'],
              color: isSelected ? Colors.white : action['color'],
              size: isSmallScreen ? 16 : 18,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              action['label'],
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : action['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeModal() {
    _animationController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  void _copyPaymentId() {
    FlutterClipboard.copy(_paymentId).then((_) {
      setState(() {
        _isCopied = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isCopied = false;
          });
        }
      });
    });
  }

  void _handleAction(String actionId) {
    setState(() {
      _selectedAction = actionId;
    });

    switch (actionId) {
      case 'share':
        _shareQRCode();
        break;
      case 'download':
        _downloadQRCode();
        break;
      case 'copy':
        _copyPaymentId();
        break;
      case 'save':
        _saveQRCode();
        break;
    }
  }

  void _shareQRCode() {
    _showSnackBar('QR Code partagé avec succès');
  }

  void _downloadQRCode() {
    _showSnackBar('QR Code téléchargé dans votre galerie');
  }

  void _saveQRCode() {
    _showSnackBar('QR Code sauvegardé dans vos favoris');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Updated usage example with data saving
class QRCodeScreen extends StatelessWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  // Method to save user data to SharedPreferences (call this after login/registration)
  static Future<void> saveUserDataToPrefs({
    required String userName,
    required String walletId,
    required double balance,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userName);
      await prefs.setString('walletId', walletId);
      await prefs.setDouble('balance', balance);
      
      print('✅ User data saved to SharedPreferences:');
      print('👤 Name: $userName');
      print('💰 Wallet ID: $walletId');
      print('💳 Balance: $balance');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  // Method to update balance in SharedPreferences
  static Future<void> updateBalance(double newBalance) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('balance', newBalance);
      print('✅ Balance updated: $newBalance DT');
    } catch (e) {
      print('❌ Error updating balance: $e');
    }
  }

  void _showEnhancedQRModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return QRCodeModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mon QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: Color(0xFF8B5CF6),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre QR Code Personnel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Partagez votre QR code pour recevoir\n des paiements instantanément',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _showEnhancedQRModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Afficher Mon QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}