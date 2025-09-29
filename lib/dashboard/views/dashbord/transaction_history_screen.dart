import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spw/http/api_crypter.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with SingleTickerProviderStateMixin {
  int _selectedFilter = 0;
  final List<String> _filters = ['Tous', 'Reçus', 'Envoyés', 'Recharges'];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _nextToken;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<Transaction> _transactions = [];

  // API Service Methods
  Future<ApiResponse> _fetchTransactions({String? nextToken}) async {
    try {
      const String baseUrl = 'https://spw.demo-tunisie.tn/api/gestiontransaction/historiqueTransaction';
          final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? nextToken = prefs.getString('nextToken');

    print('Token: $token');
    print('NextToken: $nextToken');

    // Check if token exists
    if (token == null || token.isEmpty) {
      print('❌ No token found in SharedPreferences');
      return Future.error('No token found');
    }
 
    // Generate keys
    final String idempotencyKey =ApiCrypter.generateKey();
    final String encryptedKey = ApiCrypter.crypt(idempotencyKey);
       final headers = {
      'token' : token ,
      if (nextToken != null && nextToken.isNotEmpty) 'NextToken': nextToken,
      'idempotencykey': idempotencyKey,
      'key': encryptedKey,
    };

      final Map<String, dynamic> requestBody = {
        'lastTr': 'yes',
        'service' : 'tous',
        'page' : '1',
        'rows' : '5'
        };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return ApiResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _fetchTransactions();
      
      setState(() {
        _transactions.clear();
        _transactions.addAll(_convertApiTransactions(response.list));
        _nextToken = response.nextToken;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur de chargement: $e');
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || _nextToken == null || _nextToken!.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await _fetchTransactions(nextToken: _nextToken);
      
      setState(() {
        _transactions.addAll(_convertApiTransactions(response.list));
        _nextToken = response.nextToken;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      _showErrorSnackBar('Erreur de chargement: $e');
    }
  }

  List<Transaction> _convertApiTransactions(List<ApiTransaction> apiTransactions) {
    return apiTransactions.map((apiTransaction) {
      return Transaction(
        id: apiTransaction.idTransaction,
        title: apiTransaction.service ?? _getTransactionTitle(apiTransaction.abreviation),
        date: _formatDate(apiTransaction.datePaiement),
        amount: double.parse(apiTransaction.montant),
        isPositive: apiTransaction.signe == '+',
        type: _determineTransactionType(apiTransaction.abreviation),
        icon: _getTransactionIcon(apiTransaction.icon),
        iconColor: _getTransactionColor(apiTransaction.abreviation),
        status: apiTransaction.etatws == 's' 
            ? TransactionStatus.completed 
            : TransactionStatus.pending,
        category: _getTransactionCategory(apiTransaction.abreviation),
      );
    }).toList();
  }

  String _getTransactionTitle(String abreviation) {
    switch (abreviation) {
      case 'ts':
        return 'Autre Wallet SF';
      case 'rcv':
        return 'Transfert reçu';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  TransactionType _determineTransactionType(String abreviation) {
    switch (abreviation) {
      case 'ts':
        return TransactionType.transfer;
      case 'rcv':
        return TransactionType.transfer;
      default:
        return TransactionType.transfer;
    }
  }

  IconData _getTransactionIcon(String iconName) {
    switch (iconName) {
      case 'cart-plus':
        return Icons.shopping_cart_rounded;
      case 'info':
        return Icons.info_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color _getTransactionColor(String abreviation) {
    switch (abreviation) {
      case 'ts':
        return const Color(0xFF6C5CE7);
      case 'rcv':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getTransactionCategory(String abreviation) {
    switch (abreviation) {
      case 'ts':
        return 'Transfert';
      case 'rcv':
        return 'Reçu';
      default:
        return 'Transaction';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

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
    
    _loadTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    List<Transaction> filtered = _transactions;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) =>
          transaction.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          transaction.amount.toString().contains(_searchQuery) ||
          transaction.id.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply category filter
    if (_selectedFilter == 0) return filtered;
    if (_selectedFilter == 1) {
      return filtered.where((t) => t.isPositive).toList();
    }
    if (_selectedFilter == 2) {
      return filtered.where((t) => !t.isPositive && t.type != TransactionType.recharge).toList();
    }
    if (_selectedFilter == 3) {
      return filtered.where((t) => t.type == TransactionType.recharge).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final isTablet = size.width >= 768;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildResponsiveAppBar(isSmallScreen, isTablet),
      body: _isLoading
          ? _buildLoadingIndicator()
          : AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: _buildResponsiveSearchBar(isSmallScreen, isTablet),
                        ),
                      ),
                    ),

                    // Filter Chips
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.8),
                          child: _buildResponsiveFilterChips(isSmallScreen, isTablet),
                        ),
                      ),
                    ),

                    // Statistics Card
                    if (!isLandscape || isTablet)
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 0.6),
                            child: _buildResponsiveStatsCard(isSmallScreen, isTablet, isLandscape),
                          ),
                        ),
                      ),

                    // Transactions Header
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.4),
                          child: _buildResponsiveTransactionsHeader(isSmallScreen, isTablet),
                        ),
                      ),
                    ),

                    // Transactions List/Grid
                    _filteredTransactions.isEmpty
                        ? SliverToBoxAdapter(
                            child: _buildResponsiveEmptyState(isSmallScreen, isTablet),
                          )
                        : _buildResponsiveTransactionList(isSmallScreen, isTablet, isLandscape),

                    // Loading more indicator
                    if (_isLoadingMore)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      bottomNavigationBar: _buildResponsiveBottomInfo(isSmallScreen, isTablet),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement des transactions...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTransactionList(bool isSmallScreen, bool isTablet, bool isLandscape) {
    if (isTablet || isLandscape) {
      // Grid layout for tablets and landscape
      final crossAxisCount = isLandscape ? 2 : (isTablet ? 2 : 1);
      return SliverPadding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
            childAspectRatio: isLandscape ? 1.8 : 2.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == _filteredTransactions.length - 5 && _nextToken != null && _nextToken!.isNotEmpty) {
                _loadMoreTransactions();
              }
              
              final transaction = _filteredTransactions[index];
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.2),
                  child: _buildResponsiveTransactionCard(transaction, index, isSmallScreen, isTablet),
                ),
              );
            },
            childCount: _filteredTransactions.length,
          ),
        ),
      );
    } else {
      // List layout for phones
      return SliverPadding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == _filteredTransactions.length - 5 && _nextToken != null && _nextToken!.isNotEmpty) {
                _loadMoreTransactions();
              }
              
              final transaction = _filteredTransactions[index];
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 0.2),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
                    child: _buildResponsiveTransactionCard(transaction, index, isSmallScreen, isTablet),
                  ),
                ),
              );
            },
            childCount: _filteredTransactions.length,
          ),
        ),
      );
    }
  }

  // Keep all your existing UI methods exactly the same
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
        isSmallScreen ? 'Historique' : 'Historique des transactions',
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
              Icons.refresh_rounded, 
              color: Colors.grey.shade700,
              size: isSmallScreen ? 18 : 20,
            ),
            onPressed: _loadTransactions,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveSearchBar(bool isSmallScreen, bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 4 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher une transaction...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded, 
            color: Colors.grey.shade500,
            size: isSmallScreen ? 20 : 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded, 
                    color: Colors.grey.shade500,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      ),
    );
  }

  Widget _buildResponsiveFilterChips(bool isSmallScreen, bool isTablet) {
    return SizedBox(
      height: isSmallScreen ? 45 : 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
        ),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: isSmallScreen ? 6 : 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FilterChip(
                label: Text(
                  _filters[index],
                  style: TextStyle(
                    color: _selectedFilter == index ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 12 : 13,
                  ),
                ),
                selected: _selectedFilter == index,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? index : 0;
                  });
                },
                selectedColor: const Color(0xFF6C5CE7),
                checkmarkColor: Colors.white,
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 4 : 8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveStatsCard(bool isSmallScreen, bool isTablet, bool isLandscape) {
    final totalReceived = _transactions
        .where((t) => t.isPositive)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalSent = _transactions
        .where((t) => !t.isPositive)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalReceived - totalSent;

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C5CE7), Color(0xFF836FFF), Color(0xFFA29BFE)],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResponsiveStatItem('Reçus', '+${totalReceived.toStringAsFixed(3)} DT', Colors.green.shade100, isSmallScreen),
              _buildResponsiveStatItem('Dépensés', '-${totalSent.toStringAsFixed(3)} DT', Colors.red.shade100, isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded, 
                color: Colors.white.withOpacity(0.8), 
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Solde net: ${balance.toStringAsFixed(3)} DT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatItem(String label, String value, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          ),
          child: Icon(
            label == 'Reçus' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color,
            size: isSmallScreen ? 18 : 20,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: isSmallScreen ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveTransactionsHeader(bool isSmallScreen, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredTransactions.length} Transactions',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            _getPeriodLabel(),
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTransactionCard(Transaction transaction, int index, bool isSmallScreen, bool isTablet) {
    return GestureDetector(
      onTap: () => _showEnhancedTransactionDetails(transaction),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: isSmallScreen ? 44 : (isTablet ? 60 : 52),
              height: isSmallScreen ? 44 : (isTablet ? 60 : 52),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [transaction.iconColor, Color.lerp(transaction.iconColor, Colors.white, 0.3)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                boxShadow: [
                  BoxShadow(
                    color: transaction.iconColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                transaction.icon,
                color: Colors.white,
                size: isSmallScreen ? 20 : (isTablet ? 28 : 24),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.title,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: isSmallScreen ? 1 : 2,
                        ),
                      ),
                      if (transaction.status == TransactionStatus.pending)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 8,
                            vertical: isSmallScreen ? 1 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                          ),
                          child: Text(
                            'En attente',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Text(
                    transaction.date,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : (isTablet ? 14 : 13),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 6),
                  Wrap(
                    spacing: isSmallScreen ? 6 : 8,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6 : 8,
                          vertical: isSmallScreen ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(transaction.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                        ),
                        child: Text(
                          _getTypeLabel(transaction.type),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: _getTypeColor(transaction.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!isSmallScreen)
                        Text(
                          transaction.id,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),

            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(3)} DT',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : (isTablet ? 18 : 16),
                    fontWeight: FontWeight.w800,
                    color: transaction.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 5 : 6,
                      height: isSmallScreen ? 5 : 6,
                      decoration: BoxDecoration(
                        color: transaction.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 4 : 6),
                    Text(
                      transaction.isPositive ? 'Reçu' : 'Envoyé',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveEmptyState(bool isSmallScreen, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 80 : (isTablet ? 160 : 120),
            height: isSmallScreen ? 80 : (isTablet ? 160 : 120),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: isSmallScreen ? 30 : (isTablet ? 60 : 50),
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'Aucune transaction trouvée',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : (isTablet ? 24 : 20),
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            _searchQuery.isEmpty
                ? 'Vos transactions apparaîtront ici'
                : 'Aucun résultat pour "$_searchQuery"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          if (_searchQuery.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
              ),
              child: Text(
                'Effacer la recherche',
                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBottomInfo(bool isSmallScreen, bool isTablet) {
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSmallScreen ? 20 : 24),
          topRight: Radius.circular(isSmallScreen ? 20 : 24),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 36 : 40,
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: Color(0xFF6C5CE7),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Historique détaillé',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Toutes vos transactions en un seul endroit',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                width: isSmallScreen ? 36 : 40,
                height: isSmallScreen ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
                child: Icon(
                  Icons.download_rounded, 
                  color: Colors.white, 
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
              onPressed: _exportEnhancedHistory,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return const Color(0xFF6C5CE7);
      case TransactionType.recharge:
        return const Color(0xFF06B6D4);
      case TransactionType.payment:
        return const Color(0xFFEC4899);
      case TransactionType.bill:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfert';
      case TransactionType.recharge:
        return 'Recharge';
      case TransactionType.payment:
        return 'Paiement';
      case TransactionType.bill:
        return 'Facture';
      default:
        return 'Autre';
    }
  }

  String _getPeriodLabel() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  void _showAdvancedFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAdvancedFilterSheet(),
    );
  }

  Widget _buildAdvancedFilterSheet() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Text(
            'Filtres avancés',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          const Text('Options de filtrage avancé...'),
          SizedBox(height: isSmallScreen ? 20 : 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                ),
              ),
              child: Text(
                'Appliquer les filtres',
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEnhancedTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEnhancedTransactionDetails(transaction),
    );
  }

  Widget _buildEnhancedTransactionDetails(Transaction transaction) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            Center(
              child: Container(
                width: isSmallScreen ? 60 : 80,
                height: isSmallScreen ? 60 : 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [transaction.iconColor, Color.lerp(transaction.iconColor, Colors.white, 0.3)!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: transaction.iconColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  transaction.icon,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 32,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Center(
              child: Text(
                '${transaction.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(3)} DT',
                style: TextStyle(
                  fontSize: isSmallScreen ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  color: transaction.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Center(
              child: Text(
                transaction.title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),
            _buildEnhancedDetailRow('Date', transaction.date, Icons.calendar_today_rounded, isSmallScreen),
            _buildEnhancedDetailRow('Type', _getTypeLabel(transaction.type), Icons.category_rounded, isSmallScreen),
            _buildEnhancedDetailRow('Statut', _getStatusLabel(transaction.status), Icons.info_rounded, isSmallScreen),
            _buildEnhancedDetailRow('ID', transaction.id, Icons.fingerprint_rounded, isSmallScreen),
            _buildEnhancedDetailRow('Catégorie', transaction.category, Icons.label_rounded, isSmallScreen),
            SizedBox(height: isSmallScreen ? 20 : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                  ),
                ),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDetailRow(String label, String value, IconData icon, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 32 : 36,
            height: isSmallScreen ? 32 : 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: isSmallScreen ? 16 : 18,
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: isSmallScreen ? 13 : 14,
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

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return 'Complétée';
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.failed:
        return 'Échouée';
      default:
        return 'Inconnu';
    }
  }

  void _exportEnhancedHistory() {
    setState(() {
      _isLoading = true;
    });

    // Simulate export process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Historique exporté avec succès',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    });
  }
}

enum TransactionType { transfer, recharge, payment, bill }
enum TransactionStatus { completed, pending, failed }

class Transaction {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isPositive;
  final TransactionType type;
  final IconData icon;
  final Color iconColor;
  final TransactionStatus status;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.category,
  });
}



  // API Models
  class ApiResponse {
    final String nextToken;
    final String state;
    final String code;
    final List<ApiTransaction> list;
    final int totalItems;

    ApiResponse({
      required this.nextToken,
      required this.state,
      required this.code,
      required this.list,
      required this.totalItems,
    });

    factory ApiResponse.fromJson(Map<String, dynamic> json) {
      return ApiResponse(
        nextToken: json['nextToken'] ?? '',
        state: json['state'] ?? '',
        code: json['code'] ?? '',
        totalItems: json['totalItems'] ?? 0,
        list: (json['list'] as List? ?? [])
            .map((item) => ApiTransaction.fromJson(item))
            .toList(),
      );
    }
  }

  class ApiTransaction {
    final String idTransaction;
    final String montant;
    final String datePaiement;
    final String etatws;
    final String etat;
    final String? service;
    final String abreviation;
    final String signe;
    final String hasTicket;
    final String imageUrl;
    final String icon;

    ApiTransaction({
      required this.idTransaction,
      required this.montant,
      required this.datePaiement,
      required this.etatws,
      required this.etat,
      required this.service,
      required this.abreviation,
      required this.signe,
      required this.hasTicket,
      required this.imageUrl,
      required this.icon,
    });

    factory ApiTransaction.fromJson(Map<String, dynamic> json) {
      return ApiTransaction(
        idTransaction: json['id_transaction']?.toString() ?? '',
        montant: json['montant']?.toString() ?? '0.000',
        datePaiement: json['date_paiement']?.toString() ?? '',
        etatws: json['etatws']?.toString() ?? '',
        etat: json['etat']?.toString() ?? '',
        service: json['service']?.toString(),
        abreviation: json['abreviation']?.toString() ?? '',
        signe: json['signe']?.toString() ?? '+',
        hasTicket: json['hasTicket']?.toString() ?? 'no',
        imageUrl: json['imageUrl']?.toString() ?? '',
        icon: json['icon']?.toString() ?? 'info',
      );
    }
  }
