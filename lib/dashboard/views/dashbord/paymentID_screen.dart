import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentIDScreen extends StatefulWidget {
  const PaymentIDScreen({Key? key}) : super(key: key);

  @override
  State<PaymentIDScreen> createState() => _PaymentIDScreenState();
}

class _PaymentIDScreenState extends State<PaymentIDScreen> {
  bool showQRModal = false;
  bool showPaymentDetails = false;
  int _currentIndex = 1;
  String _selectedAction = 'share';

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'name': 'Mohamed Ali',
      'amount': 50.000,
      'date': 'Aujourd\'hui, 14:30',
      'type': 'received',
      'avatar': '👤',
    },
    {
      'name': 'Fatma Ben Ahmed',
      'amount': 25.500,
      'date': 'Hier, 09:15',
      'type': 'sent',
      'avatar': '👩',
    },
    {
      'name': 'Boutique Carrefour',
      'amount': 120.000,
      'date': '28/09/25',
      'type': 'payment',
      'avatar': '🏪',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with Gradient
                  _buildHeader(isSmallScreen),

                  // Wallet Card
                  _buildWalletCard(isSmallScreen),

                  // Payment ID Card
                  _buildPaymentIDCard(isSmallScreen),

                  // Quick Actions
                  _buildQuickActions(isSmallScreen),

                  // Recent Transactions
                  _buildRecentTransactions(isSmallScreen),

                  // Services Grid
                  _buildServicesGrid(isSmallScreen, isLargeScreen),

                  SizedBox(height: isSmallScreen ? 20 : 30),
                ],
              ),
            ),
          ),

          // QR Code Modal
          if (showQRModal) _buildQRModal(isSmallScreen),

          // Payment Details Modal
          if (showPaymentDetails) _buildPaymentDetailsModal(isSmallScreen),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'ID Paiement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: _showNotifications,
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Row(
              children: [
                Container(
                  width: isSmallScreen ? 50 : 60,
                  height: isSmallScreen ? 50 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 3),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFE5E7EB)],
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 30,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ali Chaabane',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Compte vérifié',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(bool isSmallScreen) {
    return Transform.translate(
      offset: Offset(0, isSmallScreen ? -20 : -30),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Solde Wallet',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showQRModal = true;
                    });
                  },
                  child: Container(
                    width: isSmallScreen ? 50 : 60,
                    height: isSmallScreen ? 50 : 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: const Color(0xFF8B5CF6),
                      size: isSmallScreen ? 24 : 30,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              '3,002.000',
              style: TextStyle(
                fontSize: isSmallScreen ? 28 : 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            Text(
              'DT',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentIDCard(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: 16),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre ID Paiement',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => showPaymentDetails = true),
                child: Text(
                  'Détails',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '5194297304',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton('Partager', Icons.share, 'share'),
                    SizedBox(width: 8),
                    _buildActionButton('Copier', Icons.content_copy, 'copy'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Partagez cet ID pour recevoir des paiements instantanément',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, String action) {
    final isSelected = _selectedAction == action;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedAction = action);
        if (action == 'share') _sharePaymentID();
        if (action == 'copy') _copyPaymentID();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              size: 16,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    final actions = [
      {'icon': Icons.send, 'label': 'Envoyer', 'color': Color(0xFF8B5CF6)},
      {'icon': Icons.request_quote, 'label': 'Demander', 'color': Color(0xFF06B6D4)},
      {'icon': Icons.download, 'label': 'Recevoir', 'color': Color(0xFF10B981)},
      {'icon': Icons.history, 'label': 'Historique', 'color': Color(0xFFF59E0B)},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) {
          return _buildQuickAction(
            action['label'] as String,
            action['icon'] as IconData,
            action['color'] as Color,
            isSmallScreen,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _handleQuickAction(label),
      child: Column(
        children: [
          Container(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Voir tout',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: const Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ..._recentTransactions.map((transaction) => _buildTransactionItem(transaction, isSmallScreen)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 36 : 40,
            height: isSmallScreen ? 36 : 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                transaction['avatar'],
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['name'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction['type'] == 'sent' || transaction['type'] == 'payment' ? '-' : '+'}${transaction['amount'].toStringAsFixed(3)} DT',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: transaction['type'] == 'sent' || transaction['type'] == 'payment'
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(bool isSmallScreen, bool isLargeScreen) {
    final services = [
      {'title': 'Scanner et payer', 'icon': Icons.qr_code_scanner, 'color': Color(0xFF06B6D4)},
      {'title': 'Nos boutiques', 'icon': Icons.store, 'color': Color(0xFFEC4899)},
      {'title': 'Carte bancaire', 'icon': Icons.credit_card, 'color': Color(0xFF8B5CF6)},
      {'title': 'Test', 'icon': Icons.science, 'color': Color(0xFF10B981)},
      {'title': 'Carte de recharge', 'icon': Icons.card_giftcard, 'color': Color(0xFFF59E0B)},
      {'title': 'Transfert', 'icon': Icons.send, 'color': Color(0xFF8B5CF6)},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 3 : 2,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
            childAspectRatio: 1.1,
            children: services.map((service) {
              return _buildServiceCard(
                service['title'] as String,
                service['icon'] as IconData,
                service['color'] as Color,
                isSmallScreen,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _handleServiceTap(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isSmallScreen ? 40 : 48,
                height: isSmallScreen ? 40 : 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRModal(bool isSmallScreen) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(isSmallScreen ? 20 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mon QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showQRModal = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Modal Content
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
                child: Column(
                  children: [
                    Text(
                      'Scannez pour payer',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    // QR Code
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: QrImageView(
                        data: '5194297304',
                        version: QrVersions.auto,
                        size: isSmallScreen ? 150 : 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Text(
                      'ID Paiement: 5194297304',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModalAction('Partager', Icons.share, _shareQRCode),
                        _buildModalAction('Enregistrer', Icons.download, _saveQRCode),
                        _buildModalAction('Copier', Icons.content_copy, _copyPaymentID),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsModal(bool isSmallScreen) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(isSmallScreen ? 20 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Détails du compte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showPaymentDetails = false;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
                child: Column(
                  children: [
                    _buildDetailRow('ID Paiement', '5194297304'),
                    _buildDetailRow('Nom complet', 'Ali Chaabane'),
                    _buildDetailRow('Email', 'ali.chaabane@email.com'),
                    _buildDetailRow('Téléphone', '+216 12 345 678'),
                    _buildDetailRow('Statut du compte', 'Vérifié'),
                    _buildDetailRow('Date de création', '15 Jan 2024'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
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

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: const Color(0xFF9CA3AF),
        currentIndex: _currentIndex,
        elevation: 0,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'ID Paiement',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'Scanner',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.support),
            label: 'Support',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _sharePaymentID() {
    _showComingSoon('Partage de l\'ID de paiement');
  }

  void _copyPaymentID() {
    _showComingSoon('Copie de l\'ID de paiement');
  }

  void _shareQRCode() {
    _showComingSoon('Partage du QR Code');
  }

  void _saveQRCode() {
    _showComingSoon('Sauvegarde du QR Code');
  }

  void _showNotifications() {
    _showComingSoon('Notifications');
  }

  void _refreshData() {
    _showComingSoon('Actualisation des données');
  }

  void _handleQuickAction(String action) {
    _showComingSoon('Action: $action');
  }

  void _handleServiceTap(String service) {
    _showComingSoon('Service: $service');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Bientôt disponible!'),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}