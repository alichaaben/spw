import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spw/dashboard/models/dash_models.dart';
import 'package:spw/http/api_crypter.dart';


class MerchantPaymentScreen extends StatefulWidget {
  const MerchantPaymentScreen({Key? key}) : super(key: key);

  @override
  State<MerchantPaymentScreen> createState() => _MerchantPaymentScreenState();
}

class _MerchantPaymentScreenState extends State<MerchantPaymentScreen> 
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  final TextEditingController _orderCodeController = TextEditingController();
  final TextEditingController _merchantCodeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> _recentPayments = [
    {
      'name': 'Supermarket Carrefour',
      'amount': 45.500,
      'date': '28/09/25 14:30',
      'time': 'Il y a 2 heures',
      'icon': Icons.shopping_cart_rounded,
      'color': Color(0xFF3B82F6),
      'status': 'completed',
    },
    {
      'name': 'Restaurant Le Gourmet',
      'amount': 120.000,
      'date': '27/09/25 20:15',
      'time': 'Hier',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFEC4899),
      'status': 'completed',
    },
    {
      'name': 'Station Essence Total',
      'amount': 80.000,
      'date': '26/09/25 09:45',
      'time': 'Il y a 2 jours',
      'icon': Icons.local_gas_station_rounded,
      'color': Color(0xFFF59E0B),
      'status': 'completed',
    },
    {
      'name': 'Orange Recharge',
      'amount': 20.000,
      'date': '25/09/25 16:20',
      'time': 'Il y a 3 jours',
      'icon': Icons.phone_iphone_rounded,
      'color': Color(0xFF10B981),
      'status': 'completed',
    },
  ];

  final List<Map<String, dynamic>> _partnerMerchants = [
    {
      'name': 'Carrefour',
      'category': 'Supermarché',
      'logo': '🛒',
      'color': Color(0xFF3B82F6),
      'rating': 4.5,
    },
    {
      'name': 'Zara',
      'category': 'Mode',
      'logo': '👕',
      'color': Color(0xFFEC4899),
      'rating': 4.3,
    },
    {
      'name': 'McDonald\'s',
      'category': 'Restauration',
      'logo': '🍔',
      'color': Color(0xFFF59E0B),
      'rating': 4.2,
    },
    {
      'name': 'Total',
      'category': 'Station essence',
      'logo': '⛽',
      'color': Color(0xFF10B981),
      'rating': 4.4,
    },
    {
      'name': 'Orange',
      'category': 'Télécommunications',
      'logo': '📱',
      'color': Color(0xFF8B5CF6),
      'rating': 4.6,
    },
    {
      'name': 'Decathlon',
      'category': 'Sport',
      'logo': '⚽',
      'color': Color(0xFF06B6D4),
      'rating': 4.7,
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Supermarchés',
      'icon': Icons.shopping_cart_rounded,
      'count': 24,
      'color': Color(0xFF3B82F6),
    },
    {
      'name': 'Restauration',
      'icon': Icons.restaurant_rounded,
      'count': 18,
      'color': Color(0xFFEC4899),
    },
    {
      'name': 'Mode',
      'icon': Icons.shopping_bag_rounded,
      'count': 15,
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'Électronique',
      'icon': Icons.computer_rounded,
      'count': 12,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Santé',
      'icon': Icons.local_hospital_rounded,
      'count': 8,
      'color': Color(0xFFEF4444),
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car_rounded,
      'count': 6,
      'color': Color(0xFF10B981),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(isSmallScreen),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Column(
            children: [
              // Enhanced Tab Bar
              _buildEnhancedTabBar(isSmallScreen),
              Expanded(
                child: _buildCurrentTab(),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(bool isSmallScreen) {
    return AppBar(
      backgroundColor: const Color(0xFF8B5CF6),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: const Text(
              'Paiement Marchand',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          );
        },
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white, size: 20),
            onPressed: _showPaymentHistory,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTabBar(bool isSmallScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildEnhancedTab('Services', 0, Icons.payment_rounded, isSmallScreen),
              _buildEnhancedTab('Marchands', 1, Icons.store_rounded, isSmallScreen),
              _buildEnhancedTab('Dons', 2, Icons.favorite_rounded, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTab(String title, int index, IconData icon, bool isSmallScreen) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                width: 3,
              ),
            ),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                      const Color(0xFF8B5CF6).withOpacity(0.02),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF9CA3AF),
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF6B7280),
                  fontSize: isSmallScreen ? 11 : 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTab) {
      case 0:
        return _buildEnhancedServicesTab();
      case 1:
        return _buildEnhancedMerchantsTab();
      case 2:
        return _buildEnhancedDonationTab();
      default:
        return _buildEnhancedServicesTab();
    }
  }

  Widget _buildEnhancedServicesTab() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: _buildHeaderSection(),
                ),
              ),
            ),

            // Payment Methods Grid
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.8),
                  child: _buildPaymentMethodsGrid(),
                ),
              ),
            ),

            // Scanner Section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.6),
                  child: _buildEnhancedScannerCard(),
                ),
              ),
            ),

            // Recent Payments
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.4),
                  child: _buildEnhancedRecentPayments(),
                ),
              ),
            ),

            // Partner Merchants
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.2),
                  child: _buildEnhancedPartnerMerchants(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6),
            const Color(0xFFA78BFA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paiements Marchands',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Payez en toute sécurité',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scanner, codes ou sélection directe',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modes de paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildEnhancedPaymentCard(
                title: 'Code Commande',
                subtitle: 'Payer une commande',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF3B82F6),
                onTap: _showOrderCodeDialog,
              ),
              _buildEnhancedPaymentCard(
                title: 'Code Marchand',
                subtitle: 'Payer un marchand',
                icon: Icons.store_rounded,
                color: const Color(0xFFEC4899),
                onTap: _showMerchantCodeDialog,
              ),
              _buildEnhancedPaymentCard(
                title: 'Faire un Don',
                subtitle: 'Soutenir une cause',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFF59E0B),
                onTap: _showDonationDialog,
              ),
              _buildEnhancedPaymentCard(
                title: 'Factures',
                subtitle: 'Payer mes factures',
                icon: Icons.description_rounded,
                color: const Color(0xFF10B981),
                onTap: _showBillsDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, Color.lerp(color, Colors.white, 0.3)!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: const Color(0xFF6B7280),
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedScannerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _showScanner,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6),
                const Color(0xFFA78BFA),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanner QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scannez et payez instantanément',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRecentPayments() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paiements Récents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                'Voir tout',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentPayments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildEnhancedRecentPaymentItem(payment, index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnhancedRecentPaymentItem(Map<String, dynamic> payment, int index) {
    return GestureDetector(
      onTap: () => _showPaymentDetails(payment),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [payment['color'], Color.lerp(payment['color'], Colors.white, 0.3)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                payment['icon'],
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
                    payment['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    payment['date'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${payment['amount'].toStringAsFixed(3)} DT',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPartnerMerchants() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marchands Populaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                'Tout voir',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _partnerMerchants.length,
              itemBuilder: (context, index) {
                final merchant = _partnerMerchants[index];
                return _buildEnhancedPartnerMerchantItem(merchant, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPartnerMerchantItem(Map<String, dynamic> merchant, int index) {
    return GestureDetector(
      onTap: () => _showMerchantDetails(merchant),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400 + (index * 100)),
        width: 100,
        margin: EdgeInsets.only(right: index == _partnerMerchants.length - 1 ? 0 : 12),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [merchant['color'], Color.lerp(merchant['color'], Colors.white, 0.3)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: merchant['color'].withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  merchant['logo'],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              merchant['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 10),
                const SizedBox(width: 2),
                Text(
                  merchant['rating'].toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMerchantsTab() {
    return Column(
      children: [
        // Enhanced Search Bar
        FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un marchand, une catégorie...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.tune_rounded, color: Colors.grey.shade500),
                      onPressed: _showMerchantFilters,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ..._categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value * (1 - index * 0.1)),
                    child: _buildEnhancedCategoryItem(category, index),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedCategoryItem(Map<String, dynamic> category, int index) {
    return GestureDetector(
      onTap: () => _showCategoryMerchants(category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [category['color'], Color.lerp(category['color'], Colors.white, 0.3)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'],
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '${category['count']} marchands',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: category['color'],
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDonationTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: _buildDonationHeader(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value * 0.8),
              child: _buildFeaturedCharities(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value * 0.6),
              child: _buildCharityList(),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildDonationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF34D399),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faire un Don',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Soutenez une cause',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre générosité fait la différence',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCharities() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Urgences en cours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFeaturedCharityCard(
                  'Séisme Maroc',
                  'Aide aux sinistrés',
                  '🚨',
                  Color(0xFFEF4444),
                  85,
                ),
                const SizedBox(width: 12),
                _buildFeaturedCharityCard(
                  'Inondations Libye',
                  'Soutien humanitaire',
                  '🌊',
                  Color(0xFF3B82F6),
                  72,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCharityCard(String title, String subtitle, String emoji, Color color, int progress) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$progress% collecté',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Urgent',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharityList() {
    final charities = [
      {
        'name': 'Croissant Rouge Tunisien',
        'description': 'Aide humanitaire d\'urgence et soutien médical',
        'logo': '❤️',
        'color': Color(0xFFEF4444),
        'category': 'Humanitaire',
      },
      {
        'name': 'Association Tunisie Educative',
        'description': 'Soutien à l\'éducation des enfants défavorisés',
        'logo': '📚',
        'color': Color(0xFF3B82F6),
        'category': 'Éducation',
      },
      {
        'name': 'Protection Animale TN',
        'description': 'Bien-être animal et protection des espèces',
        'logo': '🐾',
        'color': Color(0xFFF59E0B),
        'category': 'Animaux',
      },
      {
        'name': 'Environnement Propre',
        'description': 'Protection de l\'environnement et recyclage',
        'logo': '🌱',
        'color': Color(0xFF10B981),
        'category': 'Environnement',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Organisations Caritatives',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...charities.asMap().entries.map((entry) {
            final index = entry.key;
            final charity = entry.value;
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * (1 - index * 0.1)),
                child: _buildEnhancedCharityCard(charity, index),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnhancedCharityCard(Map<String, dynamic> charity, int index) {
    return GestureDetector(
      onTap: () => _showDonationDialog(charityName: charity['name']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [charity['color'], Color.lerp(charity['color'], Colors.white, 0.3)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  charity['logo'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    charity['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    charity['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: charity['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      charity['category'],
                      style: TextStyle(
                        fontSize: 10,
                        color: charity['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFF8B5CF6),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }


Future<void> _processMerchantPayment() async {
  // Show loading dialog
  _showLoadingDialog('Vérification du code marchand...');

  try {
    // Verify merchant code first
    final verificationResponse = await _verifyMerchantCode(_merchantCodeController.text);

    if (verificationResponse.isSuccess) {
      // If verification successful, proceed to payment
      Navigator.pop(context); // Close loading dialog
      _showPaymentAmountDialog(verificationResponse);
    } else {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog(
        'Code marchand invalide',
        'Le code marchand que vous avez saisi est invalide ou n\'existe pas.'
      );
    }
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    _showErrorDialog(
      'Erreur de connexion',
      'Impossible de vérifier le code marchand. Vérifiez votre connexion internet.'
    );
  }
}

Future<MerchantVerificationResponse> _verifyMerchantCode(String codeBoutique) async {
  const String baseUrl = 'https://spw.demo-tunisie.tn/api/marchand/code/verifCodeBoutique';
  
  try {
    // Get tokens from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? nextToken = prefs.getString('nextToken');

    print('🔑 Token: $token');
    print('🔑 NextToken: $nextToken');

    // Check if token exists
    if (token == null || token.isEmpty) {
      print('❌ No token found in SharedPreferences');
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

    print('🚀 Making merchant verification request...');
    print('📝 Code Boutique: $codeBoutique');
    print('🔐 Headers: $headers');

    // Create form data
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['codeBoutique'] = codeBoutique;
    
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
      print('✅ Merchant verification successful!');
      print('🏪 Merchant Data: $jsonResponse');
      
      final merchantResponse = MerchantVerificationResponse.fromJson(jsonResponse);
      
      // Save nextToken if present in response
      if (merchantResponse.nextToken.isNotEmpty) {
        await prefs.setString('nextToken', merchantResponse.nextToken);
        print('💾 NextToken saved: ${merchantResponse.nextToken}');
      }
      
      return merchantResponse;
    } else {
      print('❌ Merchant verification failed with status: ${response.statusCode}');
      print('❌ Error response: $responseData');
      throw Exception('HTTP ${response.statusCode}: $responseData');
    }

  } catch (e) {
    print('❌ Error verifying merchant code: $e');
    rethrow;
  }
}


// Updated _showPaymentAmountDialog method
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
                        'Code: ${_merchantCodeController.text}',
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
                        _showErrorDialog(
                          'Montant trop faible',
                          'Le montant minimum est de $min DT.'
                        );
                      } else if (amount > max) {
                        _showErrorDialog(
                          'Montant trop élevé',
                          'Le montant maximum est de $max DT.'
                        );
                      } else if (amount > 0) {
                        Navigator.pop(context);
                        await _verifyPaymentAmount(merchant, amount);
                      } else {
                        _showErrorDialog(
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

// New method to verify payment amount with API call
Future<void> _verifyPaymentAmount(MerchantVerificationResponse merchant, double amount) async {
  const String baseUrl = 'https://spw.demo-tunisie.tn/api/marchand/code/verifCodeBoutique';
  
  try {
    _showLoadingDialog('Vérification du paiement...');

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

    print('🚀 Making payment verification request...');
    print('📝 Code Boutique: ${_merchantCodeController.text}');
    print('💰 Amount: $amount');
    print('🔐 Headers: $headers');

    // Create form data
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['codeBoutique'] = _merchantCodeController.text;
    request.fields['montant'] = amount.toString();
    
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
      final paymentResponse = PaymentVerificationResponse.fromJson(jsonResponse);
      
      if (paymentResponse.isSuccess) {
        print('✅ Payment verification successful!');
        print('💰 Payment Data: $jsonResponse');
        
        // Save nextToken if present in response
        if (paymentResponse.nextToken.isNotEmpty) {
          await prefs.setString('nextToken', paymentResponse.nextToken);
          print('💾 NextToken saved: ${paymentResponse.nextToken}');
        }
        
        Navigator.pop(context); // Close loading dialog
        _showPaymentMethodsDialog(paymentResponse);
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog(
          'Erreur de vérification',
          'Impossible de vérifier le paiement: ${paymentResponse.state} - ${paymentResponse.code}'
        );
      }
    } else {
      Navigator.pop(context); // Close loading dialog
      print('❌ Payment verification failed with status: ${response.statusCode}');
      print('❌ Error response: $responseData');
      _showErrorDialog(
        'Erreur de connexion',
        'Impossible de vérifier le paiement. Code: ${response.statusCode}'
      );
    }

  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    print('❌ Error verifying payment: $e');
    _showErrorDialog(
      'Erreur',
      'Une erreur s\'est produite lors de la vérification: $e'
    );
  }
}



// Updated _showPaymentMethodsDialog method
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

// Updated payment method item with onTap functionality
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

// Handle payment method selection
void _handlePaymentMethodSelection(PaymentMethod method, PaymentVerificationResponse payment) {
  if (method.methode == 'sf' || method.methode == 'wallet') {
    // For SPW balance or wallet, we need PIN
    _showPinDialog(method, payment);
  } else if (method.methode == 'cb' || method.methode == 'cbi') {
    // For card payments, show card selection or add new card
    _showCardPaymentDialog(method, payment);
  } else {
    _showErrorDialog(
      'Méthode non supportée',
      'Cette méthode de paiement n\'est pas encore disponible.'
    );
  }
}

// Show PIN dialog for SPW balance and wallet payments
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
                  hintText: 'Ex: Café du matin',
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
                        _showErrorDialog(
                          'PIN invalide',
                          'Le code PIN doit contenir 6 chiffres.'
                        );
                        return;
                      }
                      
                      Navigator.pop(context); // Close PIN dialog
                      await _processPayment(
                        method: method,
                        payment: payment,
                        pin: pinController.text,
                        wallet_idPaiement : method.methode == 'wallet' && method.listWallets.isNotEmpty
                          ? method.listWallets.first['wallet_idPaiement'].toString()
                          : '',
                        etiquette: etiquetteController.text.isEmpty ? 'test' : etiquetteController.text,
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

// Process payment with API call
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

    print('🚀 Making payment validation request...');
    print('📝 Code Boutique: ${_merchantCodeController.text}');
    print('💰 Amount: ${payment.montant}');
    print('🏷️ Etiquette: $etiquette');
    print('💳 Mode Paiement: ${method.methode}');
    print('💳 Wallet id: ${wallet_idPaiement}');
    print('🔐 PIN: ******');
    print('🔐 Headers: $headers');

    // Create form data
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['codeBoutique'] = _merchantCodeController.text;
    request.fields['montant'] = payment.montant;
    request.fields['etiquette'] = etiquette;
    request.fields['modePaiement'] = method.methode;
    request.fields['pin'] = pin;
    request.fields['wallet_idPaiement'] = wallet_idPaiement;
    
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
      final validationResponse = PaymentValidationResponse.fromJson(jsonResponse);
      
      if (validationResponse.isSuccess) {
        print('✅ Payment validation successful!');
        print('💰 Transaction Data: $jsonResponse');
        
        // Save nextToken if present in response
        if (validationResponse.nextToken.isNotEmpty) {
          await prefs.setString('nextToken', validationResponse.nextToken);
          print('💾 NextToken saved: ${validationResponse.nextToken}');
        }
        
        Navigator.pop(context); // Close loading dialog
        _showPaymentSuccessDialog(validationResponse);
      } else {
        Navigator.pop(context); // Close loading dialog
        _showErrorDialog(
          'Échec du paiement',
          'Le paiement a échoué: ${validationResponse.message}'
        );
      }
    } else {
      Navigator.pop(context); // Close loading dialog
      print('❌ Payment validation failed with status: ${response.statusCode}');
      print('❌ Error response: $responseData');
      _showErrorDialog(
        'Erreur de connexion',
        'Impossible de traiter le paiement. Code: ${response.statusCode}'
      );
    }

  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    print('❌ Error processing payment: $e');
    _showErrorDialog(
      'Erreur',
      'Une erreur s\'est produite lors du traitement: $e'
    );
  }
}

// Show payment success dialog
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
                  // Clear controllers for next use
                  _merchantCodeController.clear();
                  // Optionally navigate to transaction history
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

// Placeholder for card payment dialog (to be implemented)
void _showCardPaymentDialog(PaymentMethod method, PaymentVerificationResponse payment) {
  _showErrorDialog(
    'Paiement par carte',
    'Le paiement par carte bancaire sera disponible prochainement.'
  );
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

// Update loading dialog to accept custom message
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

void _processFinalPayment(MerchantVerificationResponse merchant, double amount) {
  _showLoadingDialog('Traitement du paiement...');
  
  // Simulate payment processing
  Future.delayed(const Duration(seconds: 2), () {
    Navigator.pop(context); // Close loading dialog
    
    _showEnhancedSuccessDialog(
      'Paiement effectué avec succès',
      'Vous avez payé ${amount.toStringAsFixed(3)} DT à ${merchant.nomBoutique}',
    );
    
    // Clear the merchant code controller for next use
    _merchantCodeController.clear();
  });
}

 
void _showErrorDialog(String title, String message) {
  showDialog(
    context: context,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Compris',
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

// Update your existing _showEnhancedSuccessDialog to accept a message parameter
void _showEnhancedSuccessDialog(String title, String message) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuer',
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


  // Enhanced Dialog Methods
  void _showOrderCodeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEnhancedPaymentDialog(
        title: 'Paiement par Code Commande',
        subtitle: 'Entrez le code fourni par le marchand',
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF3B82F6),
        hintText: 'Ex: CMD-123456',
        controller: _orderCodeController,
        onConfirm: _processOrderPayment,
      ),
    );
  }

  void _showMerchantCodeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEnhancedPaymentDialog(
        title: 'Paiement Marchand',
        subtitle: 'Entrez le code du marchand',
        icon: Icons.store_rounded,
        color: Color(0xFFEC4899),
        hintText: 'Ex: MCH-789012',
        controller: _merchantCodeController,
        onConfirm: _processMerchantPayment,
      ),
    );
  }

  Widget _buildEnhancedPaymentDialog({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onConfirm,
  }) {
    return Container(
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
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.white, 0.3)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                    onPressed: () {
                      onConfirm();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continuer',
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
    );
  }

  // Keep existing methods with enhanced implementations
  void _showDonationDialog({String? charityName}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDonationDialog(charityName),
    );
  }

  Widget _buildDonationDialog(String? charityName) {
    return Container(
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
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                charityName != null ? 'Don à $charityName' : 'Faire un Don',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Choisissez le montant de votre don',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick amount selection
            Row(
              children: [5, 10, 20, 50].map((amount) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        _amountController.text = amount.toString();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '$amount DT',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'Montant personnalisé',
                  prefixText: 'DT ',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                    onPressed: () {
                      _processDonation(charityName);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Faire le don',
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
    );
  }

  void _showBillsDialog() {
    // Enhanced bills dialog implementation
  }

  void _showScanner() {
    // Enhanced scanner implementation
  }

  void _showPaymentHistory() {
    // Enhanced payment history navigation
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    // Enhanced payment details dialog
  }

  void _showMerchantDetails(Map<String, dynamic> merchant) {
    // Enhanced merchant details dialog
  }

  void _showCategoryMerchants(Map<String, dynamic> category) {
    // Enhanced category merchants view
  }

  void _showMerchantFilters() {
    // Enhanced merchant filters dialog
  }

  void _processOrderPayment() {
    _showEnhancedSuccessDialog('Paiement de commande effectué avec succès' , 'Vous avez payé avec le code ${_orderCodeController.text}');
  }

 

  void _processDonation(String? charityName) {
    _showEnhancedSuccessDialog('Don ${charityName != null ? 'à $charityName' : ''} effectué avec succès' , 'Merci pour votre générosité !');
  }

 
 }