import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spw/dashboard/models/dash_models.dart';
import 'package:spw/http/api_crypter.dart';

class MoneyTransferScreen extends StatefulWidget {
  const MoneyTransferScreen({Key? key}) : super(key: key);

  @override
  State<MoneyTransferScreen> createState() => _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends State<MoneyTransferScreen> with SingleTickerProviderStateMixin {
  int _selectedMethod = 0;
  String _recipientType = 'wallet';
  double _amount = 0.0;
  String _recipientInfo = '';
  String _description = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<double> _quickAmounts = [10, 20, 50, 100, 200, 500];
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _transferMethods = [
    {
      'type': 'wallet',
      'title': 'Wallet SPW',
      'description': 'Transfert instantané vers un autre wallet SPW',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFFEC4899),
    },
    {
      'type': 'bank',
      'title': 'Compte bancaire',
      'description': 'Transfert sécurisé vers votre compte bancaire',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF06B6D4),
    },
    {
      'type': 'qr',
      'title': 'QR Code',
      'description': 'Scanner un QR code pour payer',
      'icon': Icons.qr_code_rounded,
      'color': Color(0xFF3B82F6),
    },
  ];

  final List<Map<String, dynamic>> _recentContacts = [
    {
      'name': 'Mohamed Ali',
      'phone': '+216 12 345 678',
      'type': 'wallet',
      'avatar': '👤',
    },
    {
      'name': 'Fatma Ben Ahmed',
      'phone': '+216 98 765 432',
      'type': 'wallet',
      'avatar': '👩',
    },
    {
      'name': 'Société ABC',
      'phone': 'IBAN: TN59 1000 1234 5678',
      'type': 'bank',
      'avatar': '🏢',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    
    _animationController.forward();
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
    final isMediumScreen = size.width >= 375 && size.width < 600;
    final isLargeScreen = size.width >= 600;
    final isTablet = size.width >= 768;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildResponsiveAppBar(isSmallScreen, isTablet),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Transfer Methods
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: _buildEnhancedTransferMethods(isSmallScreen, isTablet),
                  ),
                ),
              ),

              // Amount Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.8),
                    child: _buildEnhancedAmountSection(isSmallScreen, isTablet),
                  ),
                ),
              ),

              // Recipient Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.6),
                    child: _buildEnhancedRecipientSection(isSmallScreen, isTablet),
                  ),
                ),
              ),

              // Description Section
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.4),
                    child: _buildEnhancedDescriptionSection(isSmallScreen, isTablet),
                  ),
                ),
              ),

              // Recent Contacts
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * 0.2),
                    child: _buildEnhancedRecentContacts(isSmallScreen, isTablet),
                  ),
                ),
              ),

              // Spacer
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildEnhancedActionButton(isSmallScreen, isTablet),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(bool isSmallScreen, bool isTablet) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(isSmallScreen ? 6 : 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded, 
            color: Color(0xFF6C5CE7),
            size: isSmallScreen ? 18 : 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        isSmallScreen ? 'Transfert' : 'Transfert d\'argent',
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: isSmallScreen ? 16 : (isTablet ? 22 : 20),
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.history_rounded, 
              color: Colors.grey.shade700,
              size: isSmallScreen ? 18 : 20,
            ),
            onPressed: _showTransferHistory,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTransferMethods(bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Méthode de transfert',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: _transferMethods.asMap().entries.map((entry) {
              final index = entry.key;
              final method = entry.value;
              final isSelected = _selectedMethod == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedMethod = index;
                    _recipientType = method['type'];
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? LinearGradient(
                              colors: [method['color'], Color.lerp(method['color'], Colors.black, 0.1)!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : method['color'].withOpacity(0.08),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                      border: Border.all(
                        color: isSelected ? method['color'] : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: method['color'].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          method['icon'],
                          color: isSelected ? Colors.white : method['color'],
                          size: isSmallScreen ? 18 : (isTablet ? 24 : 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          method['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : (isTablet ? 12 : 11),
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : method['color'],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              _transferMethods[_selectedMethod]['description'],
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAmountSection(bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Montant du transfert',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Amounts Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 3 : (isTablet ? 6 : 3),
              crossAxisSpacing: isSmallScreen ? 8 : 12,
              mainAxisSpacing: isSmallScreen ? 8 : 12,
              childAspectRatio: isSmallScreen ? 1.8 : 2.0,
            ),
            itemCount: _quickAmounts.length,
            itemBuilder: (context, index) {
              final amount = _quickAmounts[index];
              return _buildAmountChip(amount, isSmallScreen);
            },
          ),

          const SizedBox(height: 16),

          // Custom Amount
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              hintText: 'Montant personnalisé',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: Text(
                  'DT',
                  style: TextStyle(
                    color: const Color(0xFF6C5CE7),
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _amount = double.tryParse(value) ?? 0.0;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Fee Information
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded, 
                  size: isSmallScreen ? 16 : 18, 
                  color: const Color(0xFF6B7280)
                ),
                const SizedBox(width: 8),
                Text(
                  'Frais de transfert: ',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '${_calculateFee().toStringAsFixed(3)} DT',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Text(
                  '(${(_calculateFee() / _amount * 100).toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip(double amount, bool isSmallScreen) {
    final isSelected = _amount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _amount = amount;
          _amountController.text = amount.toInt().toString();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF836FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${amount.toInt()}',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
            Text(
              'DT',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedRecipientSection(bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getRecipientLabel(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              hintText: _getRecipientHint(),
              prefixIcon: Icon(
                _getRecipientIcon(), 
                color: const Color(0xFF6B7280),
                size: isSmallScreen ? 20 : 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            keyboardType: _getRecipientKeyboardType(),
            onChanged: (value) => setState(() => _recipientInfo = value),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDescriptionSection(bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Description (optionnel)',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Ajouter une note...',
              prefixIcon: Icon(
                Icons.note_rounded, 
                color: const Color(0xFF6B7280),
                size: isSmallScreen ? 20 : 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            maxLines: 2,
            onChanged: (value) => setState(() => _description = value),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRecentContacts(bool isSmallScreen, bool isTablet) {
    if (_recentContacts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Contacts récents',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentContacts.map((contact) => _buildEnhancedContactItem(contact, isSmallScreen)),
        ],
      ),
    );
  }

  Widget _buildEnhancedContactItem(Map<String, dynamic> contact, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _recipientController.text = contact['phone'];
          _recipientInfo = contact['phone'];
          _selectedMethod = _transferMethods.indexWhere((method) => method['type'] == contact['type']);
          _recipientType = contact['type'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 36 : 44,
              height: isSmallScreen ? 36 : 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 22),
              ),
              child: Center(
                child: Text(
                  contact['avatar'],
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    contact['phone'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF9CA3AF),
              size: isSmallScreen ? 18 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedActionButton(bool isSmallScreen, bool isTablet) {
    final isValid = _amount > 0 && _recipientInfo.isNotEmpty;
    final totalAmount = _amount + _calculateFee();

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total à transférer',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalAmount.toStringAsFixed(3)} DT',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: isValid ? _processTransfer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 14 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Transférer',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: isSmallScreen ? 18 : 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _getRecipientLabel() {
    switch (_recipientType) {
      case 'wallet':
        return 'Numéro de wallet';
      case 'bank':
        return 'IBAN ou numéro de compte';
      case 'qr':
        return 'Scanner QR code';
      default:
        return 'Destinataire';
    }
  }

  String _getRecipientHint() {
    switch (_recipientType) {
      case 'wallet':
        return 'Entrez le numéro de wallet';
      case 'bank':
        return 'Entrez l\'IBAN ou numéro de compte';
      case 'qr':
        return 'Scanner le QR code du destinataire';
      default:
        return 'Informations du destinataire';
    }
  }

  IconData _getRecipientIcon() {
    switch (_recipientType) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'qr':
        return Icons.qr_code_scanner_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  TextInputType _getRecipientKeyboardType() {
    switch (_recipientType) {
      case 'wallet':
        return TextInputType.phone;
      case 'bank':
        return TextInputType.text;
      case 'qr':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  double _calculateFee() {
    if (_amount <= 0) return 0.0;
    // Simple fee calculation - 0.5% with minimum 0.1 DT
    final fee = _amount * 0.005;
    return fee < 0.1 ? 0.1 : fee;
  }

  void _processTransfer() {
    if (_amount <= 0 || _recipientInfo.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs obligatoires');
      return;
    }

    _showEnhancedConfirmationDialog();
  }

  void _showEnhancedConfirmationDialog() {
    final totalAmount = _amount + _calculateFee();
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF6C5CE7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Confirmer le transfert',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildConfirmationDetail('Destinataire', _recipientInfo, isSmallScreen),
              _buildConfirmationDetail('Montant', '${_amount.toStringAsFixed(3)} DT', isSmallScreen),
              _buildConfirmationDetail('Frais', '${_calculateFee().toStringAsFixed(3)} DT', isSmallScreen),
              _buildConfirmationDetail('Total', '${totalAmount.toStringAsFixed(3)} DT', isSmallScreen, isTotal: true),
              if (_description.isNotEmpty) 
                _buildConfirmationDetail('Description', _description, isSmallScreen),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                        ),
                        side: const BorderSide(color: Color(0xFF6C5CE7)),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: const Color(0xFF6C5CE7),
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                        ),
                      ),
                      child: Text(
                        'Confirmer',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
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

  Widget _buildConfirmationDetail(String label, String value, bool isSmallScreen, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              color: const Color(0xFF6B7280),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              color: isTotal ? const Color(0xFF6C5CE7) : const Color(0xFF1F2937),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
  if (_recipientType == 'wallet') {
    _processWalletTransfer();
  } else if (_recipientType == 'bank') {
    _showEnhancedComingSoon('Transfert bancaire');
  } else if (_recipientType == 'qr') {
    _showEnhancedComingSoon('Paiement par QR Code');
  }
}
Future<void> _processWalletTransfer() async {
  const String baseUrl = 'https://spw.demo-tunisie.tn/api/transfertsolde/validationTransfertSolde';
  
  try {
    _showLoadingDialog('Vérification du destinataire...');

    // First verify the recipient wallet
    final verificationResponse = await _verifyWalletRecipient(_recipientInfo  , _amount  , _description);
    
    if (verificationResponse.isSuccess) {
      Navigator.pop(context); // Close loading dialog
      _showWalletTransferConfirmation(verificationResponse);
    } else {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(
        'Destinataire invalide',
       // 'Le numéro de wallet que vous avez saisi est invalide ou n\'existe pas.'
      );
    }
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    _showErrorDialog(
      //'Erreur de vérification',
      'Impossible de vérifier le destinataire: $e'
    );
  }
}

// Verify wallet recipient
Future<TransferRequestResponse> _verifyWalletRecipient(String walletNumber  ,double montant , etiquette)  async {
  const String baseUrl = 'https://spw.demo-tunisie.tn/api/transfertsolde/demandeTransfertSolde';
  
  try {
    // Get tokens from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? nextToken = prefs.getString('nextToken');

    print('🔑 Token: $token');
    print('🔑 NextToken: $nextToken');

    // Check if token exists
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
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

    print('🚀 Making wallet verification request...');
    print('📱 Wallet Number: $walletNumber');
    print('🔐 Headers: $headers');

    // Create form data
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    var uuid = prefs.getString('idUnique');
    request.fields['identifiant'] = _recipientInfo ;
    request.fields['wallet_idPaiement'] = uuid ?? '';
    request.fields['montant'] = montant.toString();
      request.fields['etiquette'] = etiquette;

    
    // Add headers
    request.headers.addAll(headers);

    // Send request
    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    // Print response details
    print('✅ Response Status Code: ${response.statusCode}');
    print('✅ Response Headers: ${response.headers}');
    print('✅ Response Body: $responseData');

    // Check if request was successful
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
      final verificationResponse = TransferRequestResponse.fromJson(jsonResponse);
      
      if (verificationResponse.isSuccess) {
        print('✅ Wallet verification successful!');
        print('👤 Recipient Data: $jsonResponse');
        
        // Save nextToken if present in response
        if (verificationResponse.nextToken.isNotEmpty) {
          await prefs.setString('nextToken', verificationResponse.nextToken);
          print('💾 NextToken saved: ${verificationResponse.nextToken}');
        }
        
        return verificationResponse;
      } else {
        print('❌ Wallet verification failed: ${verificationResponse.state} - ${verificationResponse.code}');
        throw Exception('Wallet verification failed: ${verificationResponse.state}');
      }
    } else {
      print('❌ Wallet verification failed with status: ${response.statusCode}');
      print('❌ Error response: $responseData');
      throw Exception('HTTP ${response.statusCode}: $responseData');
    }

  } catch (e) {
    print('❌ Error verifying wallet: $e');
    rethrow;
  }
}

// Show wallet transfer confirmation with PIN
void _showWalletTransferConfirmation(TransferRequestResponse recipient) {
  final pinController = TextEditingController();

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
                    color: const Color(0xFF6C5CE7).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
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
                        'Confirmer le transfert',
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
            // Transfer Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildTransferDetailItem('Destinataire', recipient.fullName),
                  _buildTransferDetailItem(
                    'Numéro',
                    recipient.paymentMethods.where((m) => m.methode == 'wallet').isNotEmpty
                        ? recipient.paymentMethods
                            .firstWhere((m) => m.methode == 'wallet')
                            .listWallets
                            .first
                            ['wallet_idPaiement']
                        : '',
                  ),
                  _buildTransferDetailItem('Montant', '${_amount.toStringAsFixed(3)} DT'),
                  _buildTransferDetailItem('Frais', '${_calculateFee().toStringAsFixed(3)} DT'),
                  _buildTransferDetailItem('Total', '${(_amount + _calculateFee()).toStringAsFixed(3)} DT', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // PIN Input
            const Text(
              'Code PIN de sécurité',
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
                        _showErrorDialog(
                          'PIN invalide'
                           
                        );
                        return;
                      }
                      
                      Navigator.pop(context); // Close confirmation dialog
                      await _executeWalletTransfer(recipient, pinController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Transférer',
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

// Execute wallet transfer
Future<void> _executeWalletTransfer(TransferRequestResponse recipient, String pin) async {
  const String baseUrl = 'https://spw.demo-tunisie.tn/api/transfertsolde/validationTransfertSolde';
  
  try {
    _showLoadingDialog('Traitement du transfert...');

    // Get tokens from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? nextToken = prefs.getString('nextToken');

    print('🔑 Token: $token');
    print('🔑 NextToken: $nextToken');

    // Check if token exists
    if (token == null || token.isEmpty) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(
        //'Session expirée',
        'Veuillez vous reconnecter pour effectuer le transfert.'
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

    print('🚀 Making wallet transfer request...');
    print('📱 Recipient: ${recipient.paymentMethods.where((m) => m.methode == 'wallet').isNotEmpty
                        ? recipient.paymentMethods
                            .firstWhere((m) => m.methode == 'wallet')
                            .listWallets
                            .first
                            ['wallet_idPaiement']
                        : ''}');
    print('💰 Amount: $_amount');
    print('📝 Description: $_description');
    print('🔐 PIN: ******');
    print('🔐 Headers: $headers');

    // Create form data
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['identifiant'] = _recipientInfo; 
    request.fields['wallet_idPaiement'] = prefs.getString('idUnique') ?? '';
    request.fields['montant'] = _amount.toString();
    request.fields['etiquette'] = _description.isEmpty ? 'Transfert SPW' : _description;
    request.fields['modePaiement'] = 'wallet';
    request.fields['pin'] = pin;
    
    // Add headers
    request.headers.addAll(headers);

    // Send request
    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    // Print response details
    print('✅ Response Status Code: ${response.statusCode}');
    print('✅ Response Headers: ${response.headers}');
    print('✅ Response Body: $responseData');

    // Check if request was successful
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(responseData);
      final transferResponse = WalletTransferResponse.fromJson(jsonResponse);
      
      if (transferResponse.isSuccess) {
        print('✅ Wallet transfer successful!');
        print('💰 Transfer Data: $jsonResponse');
        
        // Save nextToken if present in response
        if (transferResponse.nextToken.isNotEmpty) {
          await prefs.setString('nextToken', transferResponse.nextToken);
          print('💾 NextToken saved: ${transferResponse.nextToken}');
        }
        
        Navigator.pop(context); // Close loading dialog
        _showEnhancedTransferSuccess(transferResponse);
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog(
        //  'Échec du transfert',
          'Le transfert a échoué: ${transferResponse.message}'
        );
      }
    } else {
      Navigator.pop(context); // Close loading dialog
      print('❌ Wallet transfer failed with status: ${response.statusCode}');
      print('❌ Error response: $responseData');
      _showErrorDialog(
       // 'Erreur de connexion',
        'Impossible de traiter le transfert. Code: ${response.statusCode}'
      );
    }

  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    print('❌ Error processing wallet transfer: $e');
    _showErrorDialog(
     // 'Erreur',
      'Une erreur s\'est produite lors du transfert: $e'
    );
  }
}

// Update the success dialog to show real transaction data
void _showEnhancedTransferSuccess(WalletTransferResponse transfer) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 375;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
              'Transfert réussi!',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 22,
                fontWeight: FontWeight.w800,
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
                  _buildTransactionSuccessItem('Transaction', transfer.idTransaction),
                  _buildTransactionSuccessItem('Montant', '${transfer.montant} DT'),
                  _buildTransactionSuccessItem('Destinataire', transfer.numeroDestinataire),
                  _buildTransactionSuccessItem('Date',transfer.datePaiement),
                  _buildTransactionSuccessItem('Nouveau solde', '${transfer.soldeAfterPayment} DT'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  // Clear form for next transfer
                  _amountController.clear();
                  _recipientController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _amount = 0.0;
                    _recipientInfo = '';
                    _description = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                  ),
                ),
                child: Text(
                  'Fermer',
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
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
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

// Add loading dialog method
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  void _showEnhancedSuccessDialog() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
                'Transfert réussi!',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre transfert de ${_amount.toStringAsFixed(3)} DT a été effectué avec succès',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    ),
                  ),
                  child: Text(
                    'Super!',
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
    );
  }

  
Future<void> testUserInfoApi() async {
  try {
    // Get tokens from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? nextToken = prefs.getString('nextToken');

    print('Token: $token');
    print('NextToken: $nextToken');

    // Check if token exists
    if (token == null || token.isEmpty) {
      print('❌ No token found in SharedPreferences');
      return;
    }
 
    // Generate keys
    final String idempotencyKey =ApiCrypter.generateKey();
    final String encryptedKey = ApiCrypter.crypt(idempotencyKey);

    // Add headers to the request
  

    // Create headers
    final headers = {
      'Content-Type': 'application/json',
      'token' : token ,
      if (nextToken != null && nextToken.isNotEmpty) 'NextToken': nextToken,
      'idempotencykey': idempotencyKey,
      'key': encryptedKey,
    };

    // Make API call
    final response = await http.get(
      Uri.parse('https://spw.demo-tunisie.tn/api/general/userinfo'),
      headers: headers,
    );

    // Print response details
    print('✅ Response Status Code: ${response.statusCode}');
    print('✅ Response Headers: ${response.headers}');
    print('✅ Response Body: ${response.body}');

    // Check if request was successful
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('✅ API Call Successful!');
      print('✅ User Data: $responseData');
    } else {
      print('❌ API Call Failed with status: ${response.statusCode}');
    }

  } catch (e) {
    print('❌ Error making API call: $e');
  }
}

// Simple method to call from your widget
void fetchUserInfo() {
  testUserInfoApi();
}
  void _showTransferHistory() {
  fetchUserInfo();
   // _showEnhancedComingSoon('Historique des transferts');
  }

  void _showErrorDialog(String message) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Color(0xFFEF4444),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
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
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
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
    );
  }

  void _showEnhancedComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$feature - Bientôt disponible!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}