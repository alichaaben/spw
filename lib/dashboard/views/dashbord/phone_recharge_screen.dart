import 'package:flutter/material.dart';

class PhoneRechargeScreen extends StatefulWidget {
  const PhoneRechargeScreen({Key? key}) : super(key: key);

  @override
  State<PhoneRechargeScreen> createState() => _PhoneRechargeScreenState();
}

class _PhoneRechargeScreenState extends State<PhoneRechargeScreen> {
  String _selectedOperator = 'ooredoo';
  String _phoneNumber = '';
  double _selectedAmount = 10.0;
  final List<double> _quickAmounts = [5.0, 10.0, 15.0, 20.0, 30.0, 50.0];
  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<Map<String, dynamic>> _operators = [
    {
      'id': 'ooredoo',
      'name': 'Ooredoo',
      'color': Color(0xFFF59E0B),
    },
    {
      'id': 'orange',
      'name': 'Orange',
      'color': Color(0xFFFF6B00),
    },
    {
      'id': 'telecom',
      'name': 'Tunisie Telecom',
      'color': Color(0xFF06B6D4),
    },
  ];

  final List<Map<String, dynamic>> _recentNumbers = [
    {'number': '+216 12 345 678', 'operator': 'ooredoo'},
    {'number': '+216 98 765 432', 'operator': 'orange'},
    {'number': '+216 55 123 456', 'operator': 'telecom'},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final isLargeScreen = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recharge téléphonique',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white, size: isSmallScreen ? 20 : 24),
            onPressed: _showRechargeHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Operator Selection
            _buildOperatorSection(isSmallScreen),

            // Phone Number Input
            _buildPhoneInputSection(isSmallScreen),

            // Amount Selection
            _buildAmountSection(isSmallScreen),

            // Recharge Methods
            Expanded(
              child: _buildRechargeMethods(isSmallScreen, isLargeScreen),
            ),

            // Action Button
            _buildActionButton(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorSection(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
          Text(
            'Opérateur',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: _operators.map((operator) {
              final isSelected = _selectedOperator == operator['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedOperator = operator['id']),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: isSelected ? operator['color'] : operator['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? operator['color'] : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 2 : 4),
                        Text(
                          operator['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : operator['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputSection(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
          Text(
            'Numéro de téléphone',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: '+216 XX XXX XXX',
              prefixIcon: Icon(Icons.phone, color: const Color(0xFF6B7280), size: isSmallScreen ? 20 : 24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => setState(() => _phoneNumber = value),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          if (_recentNumbers.isNotEmpty) ...[
            Text(
              'Numéros récents',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _recentNumbers.map((recent) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _phoneController.text = recent['number'];
                      _phoneNumber = recent['number'];
                      _selectedOperator = recent['operator'];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12, vertical: isSmallScreen ? 4 : 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      recent['number'],
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountSection(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
          Text(
            'Montant de recharge',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Quick Amounts
          SizedBox(
            height: isSmallScreen ? 45 : 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickAmounts.length,
              itemBuilder: (context, index) {
                final amount = _quickAmounts[index];
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAmount = amount;
                      _customAmountController.text = amount.toInt().toString();
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      '${amount.toInt()} DT',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Custom Amount
          TextField(
            controller: _customAmountController,
            decoration: InputDecoration(
              hintText: 'Montant personnalisé',
              prefixIcon: Icon(Icons.attach_money, color: const Color(0xFF6B7280), size: isSmallScreen ? 20 : 24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _selectedAmount = double.tryParse(value) ?? 0.0;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeMethods(bool isSmallScreen, bool isLargeScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Méthode de recharge',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Expanded(
            child: ListView(
              children: [
                _buildRechargeMethodCard(
                  title: 'Transfert direct',
                  description: 'Une recharge téléphonique simple, et récompensée ! C\'est avec SPW.',
                  icon: Icons.phone_android,
                  color: const Color(0xFFF59E0B),
                  onTap: () => _processDirectRecharge(),
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                _buildRechargeMethodCard(
                  title: 'Cartes de recharge',
                  description: 'Utilisez une carte de recharge prépayée',
                  icon: Icons.credit_card,
                  color: const Color(0xFF06B6D4),
                  onTap: () => _showRechargeCardDialog(),
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),

          // Operator Services
          _buildOperatorServices(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildRechargeMethodCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
              width: isSmallScreen ? 48 : 56,
              height: isSmallScreen ? 48 : 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF9CA3AF),
              size: isSmallScreen ? 20 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorServices(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF374151),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'Autres services des opérateurs',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOperatorService(
                'Forfait internet',
                Icons.wifi,
                const Color(0xFFEC4899),
                onTap: () => _showInternetPackages(),
                isSmallScreen: isSmallScreen,
              ),
              _buildOperatorService(
                'Mon numéro',
                Icons.phone,
                const Color(0xFF10B981),
                onTap: _showMyNumber,
                isSmallScreen: isSmallScreen,
              ),
              _buildOperatorService(
                'Transférer solde',
                Icons.swap_horiz,
                const Color(0xFF3B82F6),
                onTap: () => _showBalanceTransfer(),
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorService(String title, IconData icon, Color color, {
    VoidCallback? onTap,
    required bool isSmallScreen,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                width: isSmallScreen ? 32 : 40,
                height: isSmallScreen ? 32 : 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isSmallScreen ? 16 : 20,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isSmallScreen) {
    final isValid = _phoneNumber.isNotEmpty && _selectedAmount > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Recharge pour ${_getOperatorName()}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _phoneNumber.isEmpty ? 'Saisir un numéro' : _phoneNumber,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            ElevatedButton(
              onPressed: isValid ? _processDirectRecharge : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Recharger ${_selectedAmount.toStringAsFixed(3)} DT',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOperatorName() {
    final operator = _operators.firstWhere(
          (op) => op['id'] == _selectedOperator,
      orElse: () => _operators.first,
    );
    return operator['name'];
  }

  void _processDirectRecharge() {
    if (_phoneNumber.isEmpty || _selectedAmount <= 0) {
      _showErrorDialog('Veuillez saisir un numéro et un montant valides');
      return;
    }

    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la recharge',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width < 375 ? 16 : 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opérateur: ${_getOperatorName()}'),
            Text('Numéro: $_phoneNumber'),
            Text('Montant: ${_selectedAmount.toStringAsFixed(3)} DT'),
            const SizedBox(height: 16),
            const Text('Frais: 0.100 DT'),
            Text('Total: ${(_selectedAmount + 0.1).toStringAsFixed(3)} DT'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: MediaQuery.of(context).size.width < 375 ? 20 : 24),
            SizedBox(width: 8),
            Text(
              'Recharge réussie',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width < 375 ? 16 : 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Numéro: $_phoneNumber'),
            Text('Montant: ${_selectedAmount.toStringAsFixed(3)} DT'),
            Text('Opérateur: ${_getOperatorName()}'),
            const SizedBox(height: 8),
            const Text(
              'Votre recharge a été effectuée avec succès!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRechargeCardDialog() {
    _showComingSoon('Cartes de recharge');
  }

  void _showInternetPackages() {
    _showComingSoon('Forfaits internet');
  }

  void _showMyNumber() {
    _showComingSoon('Mon numéro');
  }

  void _showBalanceTransfer() {
    _showComingSoon('Transfert de solde');
  }

  void _showRechargeHistory() {
    _showComingSoon('Historique des recharges');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: MediaQuery.of(context).size.width < 375 ? 20 : 24),
            SizedBox(width: 8),
            Text(
              'Erreur',
              style: TextStyle(fontSize: MediaQuery.of(context).size.width < 375 ? 16 : 18),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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