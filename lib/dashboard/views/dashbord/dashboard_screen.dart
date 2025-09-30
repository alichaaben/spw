import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spw/dashboard/views/dashbord/qr_scan_screen.dart';
import 'dash_drawer.dart';

class WalletDashboard extends StatefulWidget {
  const WalletDashboard({super.key});

  @override
  State<WalletDashboard> createState() => _WalletDashboardState();
}

class _WalletDashboardState extends State<WalletDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // User data variables
  String _firstName = '';
  String _lastName = '';
  String _userName = '';
  String _email = '';
  double _walletBalance = 0.0;
  String _phone = '';
  String _idUnique = '';
  String _ville = '';
  String _adresse = '';

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
    _loadUserData(); // Load user data when widget initializes
  }

  // Method to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _firstName = prefs.getString('firstName') ?? '';
      _lastName = prefs.getString('lastName') ?? '';
      _userName = prefs.getString('userName') ?? '';
      _email = prefs.getString('email') ?? '';
      _walletBalance = prefs.getDouble('soldeWallet') ?? 0.0;
      _phone = prefs.getString('phone') ?? '';
      _idUnique = prefs.getString('idUnique') ?? '';
      _ville = prefs.getString('ville') ?? '';
      _adresse = prefs.getString('adresse') ?? '';
    });

    print('Loaded user: $_firstName $_lastName');
    print('Wallet Balance: $_walletBalance');
    print('Phone: $_phone');
    print('Unique ID: $_idUnique');
  }

  // Method to refresh data
  Future<void> _refreshData() async {
    await _loadUserData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data refreshed successfully'),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
    final isLargeScreen = size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Enhanced Header Section with Parallax
                SliverAppBar(
                  expandedHeight: isSmallScreen ? 180 : 220,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _buildEnhancedHeader(isSmallScreen),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),

                // Wallet Card with Animation
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: _buildEnhancedWalletCard(isSmallScreen, size),
                    ),
                  ),
                ),

                // Quick Actions Section
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isSmallScreen ? 16 : 20,
                        isSmallScreen ? 16 : 20,
                        isSmallScreen ? 16 : 20,
                        isSmallScreen ? 8 : 12,
                      ),
                      child: _buildQuickActions(isSmallScreen),
                    ),
                  ),
                ),

                // Enhanced Services Grid
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 16 : 20,
                    isSmallScreen ? 8 : 12,
                    isSmallScreen ? 16 : 20,
                    isSmallScreen ? 100 : 120,
                  ),
                  sliver: _buildEnhancedServicesGrid(isSmallScreen, isLargeScreen, size),
                ),
              ],
            );
          },
        ),
      ),

      // Enhanced Bottom Navigation Bar
      bottomNavigationBar: _buildEnhancedBottomNavigationBar(),
    );
  }

  Widget _buildEnhancedHeader(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C5CE7),
            Color(0xFF836FFF),
            Color(0xFFA29BFE),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Top Bar
            _buildEnhancedTopBar(isSmallScreen),
            SizedBox(height: isSmallScreen ? 20 : 24),
            
            // Enhanced Profile Section
            _buildEnhancedProfileSection(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTopBar(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Menu Button with enhanced design
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: isSmallScreen ? 20 : 22,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        
        // Title with improved typography
        Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        
        // Action buttons container
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                _buildEnhancedIconButton(
                  icon: Icons.notifications_outlined,
                  badgeCount: 3,
                  onTap: () => _navigateToNotifications(context),
                  isSmallScreen: isSmallScreen,
                ),
                SizedBox(width: isSmallScreen ? 4 : 6),
                _buildEnhancedIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: _refreshData,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isSmallScreen,
    int? badgeCount,
  }) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.white,
            size: isSmallScreen ? 18 : 20,
          ),
          onPressed: onTap,
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFE74C3C),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedProfileSection(bool isSmallScreen) {
    final fullName = _firstName.isNotEmpty || _lastName.isNotEmpty
        ? '${_firstName} ${_lastName}'.trim()
        : 'Guest User';
    
    final displayName = fullName.isNotEmpty ? fullName : _userName.isNotEmpty ? _userName : 'Guest User';

    return Row(
      children: [
        // Enhanced Profile Avatar
        Container(
          width: isSmallScreen ? 60 : 70,
          height: isSmallScreen ? 60 : 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00B894), Color(0xFF00CEA9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B894).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: const Color(0xFF6C5CE7),
                size: isSmallScreen ? 28 : 32,
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 16 : 20),
        
        // Enhanced Profile Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back! 👋',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _idUnique.isNotEmpty ? 'ID: $_idUnique' : 'Guest Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedWalletCard(bool isSmallScreen, Size size) {
    final formattedBalance = _walletBalance.toStringAsFixed(3);
    final usdEquivalent = (_walletBalance * 0.33).toStringAsFixed(2); // Example conversion rate

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadowColor: const Color(0xFF6C5CE7).withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFF836FFF),
                Color(0xFFA29BFE),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    _buildEnhancedScanButton(isSmallScreen),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Enhanced Balance Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedBalance,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'DT',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: isSmallScreen ? 4 : 6),
                // Text(
                //   '≈ \$$usdEquivalent USD',
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.7),
                //     fontSize: isSmallScreen ? 12 : 14,
                //   ),
                // ),
                SizedBox(height: isSmallScreen ? 20 : 24),

                // Enhanced Stats Section
                _buildEnhancedStatsSection(isSmallScreen, size),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Enhanced Additional Info
                _buildEnhancedAdditionalInfo(isSmallScreen),
              ],
            ),
          ),
        ),
      ),
    );
  }


 
  Widget _buildEnhancedStatsSection(bool isSmallScreen, Size size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedStatItem(
              'Phone',
              _phone.isNotEmpty ? _phone : 'Not set',
              Icons.phone_rounded,
              const Color(0xFF00B894),
              '',
              size,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildEnhancedStatItem(
              'Location',
              _ville.isNotEmpty ? _ville : 'Not set',
              Icons.location_on_rounded,
              const Color(0xFFFD79A8),
              '',
              size,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    String percentage,
    Size size,
  ) {
    final isSmallScreen = size.width < 375;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 12 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: isSmallScreen ? 16 : 18,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (percentage.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedAdditionalInfo(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet ID',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 10 : 11,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _idUnique.isNotEmpty ? _idUnique : 'Not assigned',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Status',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 10 : 11,
                ),
              ),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _walletBalance > 0 ? const Color(0xFF00B894) : const Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    _walletBalance > 0 ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionItem(
              'Send',
              Icons.send_rounded,
              const Color(0xFF6C5CE7),
              () {
                  Navigator.pushNamed(context, '/transfer');
                 _showComingSoonSnackBar(context, 'Send Money');
                 },
            ),
            _buildQuickActionItem(
              'Request',
              Icons.request_quote_rounded,
              const Color(0xFF00B894),
              () => _showComingSoonSnackBar(context, 'Request Money'),
            ),
            _buildQuickActionItem(
              'Top Up',
              Icons.add_circle_rounded,
              const Color(0xFFFD79A8),
              () {
                  Navigator.pushNamed(context, '/topup');
                //_showComingSoonSnackBar(context, 'Top Up');
                },
            ),
            _buildQuickActionItem(
              'History',
              Icons.history_rounded,
              const Color(0xFFFDCB6E),
              () => Navigator.pushNamed(context, '/history'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedServicesGrid(bool isSmallScreen, bool isLargeScreen, Size size) {
    final crossAxisCount = isLargeScreen ? 3 : 2;
    final childAspectRatio = isLargeScreen ? 1.0 : 1.1;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildListDelegate([
        _buildEnhancedServiceCard(
          'Scan & Pay',
          Icons.qr_code_scanner_rounded,
          const Color(0xFF74B9FF),
          'Quick payments',
          size,
          onTap: () => _navigateToScan(context),
        ),
        _buildEnhancedServiceCard(
          'Our Stores',
          Icons.store_rounded,
          const Color(0xFFFD79A8),
          'Find merchants',
          size,
          onTap: () => _navigateToMerchants(context),
        ),
        _buildEnhancedServiceCard(
          'Tickets',
          Icons.confirmation_number_rounded,
          const Color(0xFF6C5CE7),
          'Your tickets',
          size,
          onTap: () => _navigateToTickets(context),
        ),
        _buildEnhancedServiceCard(
          'Settings',
          Icons.settings_rounded,
          const Color(0xFF00B894),
          'App preferences',
          size,
          hasNotification: true,
          onTap: () => _navigateToSettings(context),
        ),
        _buildEnhancedServiceCard(
          'Support',
          Icons.support_agent_rounded,
          const Color(0xFFFDCB6E),
          'Get help',
          size,
          onTap: () => _navigateToSupport(context),
        ),
        _buildEnhancedServiceCard(
          'Analytics',
          Icons.analytics_rounded,
          const Color(0xFFA29BFE),
          'Spending insights',
          size,
          hasNotification: true,
          onTap: () => _navigateToAnalytics(context),
        ),
      ]),
    );
  }

  Widget _buildEnhancedServiceCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    Size size, {
    bool hasNotification = false,
    VoidCallback? onTap,
  }) {
    final isSmallScreen = size.width < 375;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFF3F4F6),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isSmallScreen ? 44 : 52,
                      height: isSmallScreen ? 44 : 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, Color.lerp(color, Colors.white, 0.3)!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: isSmallScreen ? 22 : 26,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasNotification)
                Positioned(
                  top: isSmallScreen ? 12 : 16,
                  right: isSmallScreen ? 12 : 16,
                  child: Container(
                    width: isSmallScreen ? 20 : 24,
                    height: isSmallScreen ? 20 : 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE74C3C).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildEnhancedBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 72,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C5CE7),
                Color(0xFF836FFF),
                Color(0xFFA29BFE),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEnhancedNavItem(Icons.home_rounded, 'Home', 0),
              _buildEnhancedNavItem(Icons.store, 'store', 1),
              _buildEnhancedNavItem(Icons.qr_code_rounded, 'Scan', 2, isScan: true),
              _buildEnhancedNavItem(Icons.history_rounded, 'History', 3),
              _buildEnhancedNavItem(Icons.person_rounded, 'Profile', 4, hasNotification: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNavItem(IconData icon, String label, int index, {
    bool hasNotification = false,
    bool isScan = false,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavItemTapped(index, context),
      child: Container(
        width: isScan ? 70 : 60,
        height: isScan ? 70 : 60,
        decoration: isScan ? BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ) : BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isScan ? const Color(0xFF6C5CE7) : Colors.white,
                  size: isScan ? 28 : (isSelected ? 24 : 22),
                ),
                if (!isScan) SizedBox(height: 2),
                if (!isScan) Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),

            // Notification badge
            if (hasNotification && !isSelected && !isScan)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE74C3C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

            // Selected indicator for non-scan items
            if (isSelected && !isScan)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onNavItemTapped(int index, BuildContext context) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        break;
      case 1: // Store
        _navigateToPaymentID(context);
        break;
      case 2: // Scan
        _navigateToScan(context);
        break;
      case 3: // History
        _navigateToAnalytics(context);
        break;
      case 4: // Profile
        _navigateToSettings(context);
        break;
    }
  }

  void _navigateToPaymentID(BuildContext context) {
    Navigator.pushNamed(context, '/payment-id');
    _showComingSoonSnackBar(context, 'Payment ID');
  }

void _showMyQrModal(){
   Navigator.pushNamed(context, '/scan');
  }
// Update the _navigateToScan method
void _navigateToScan(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const QRScanScreen()),
  );
}

// Also update the scan button in _buildEnhancedScanButton
Widget _buildEnhancedScanButton(bool isSmallScreen) {
  return GestureDetector(
    onTap: () => _showMyQrModal(),
    child: Container(
      width: isSmallScreen ? 50 : 56,
      height: isSmallScreen ? 50 : 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.qr_code_scanner_rounded,
        color: const Color(0xFF6C5CE7),
        size: isSmallScreen ? 24 : 28,
      ),
    ),
  );
}

  void _navigateToSupport(BuildContext context) {
    Navigator.pushNamed(context, '/support');
    _showComingSoonSnackBar(context, 'Support');
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
    _showComingSoonSnackBar(context, 'Notifications');
  }

  void _navigateToMerchants(BuildContext context) {
    Navigator.pushNamed(context, '/merchants');
    _showComingSoonSnackBar(context, 'Our Stores');
  }

  void _navigateToTickets(BuildContext context) {
    Navigator.pushNamed(context, '/tickets');
    _showComingSoonSnackBar(context, 'Tickets');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
    _showComingSoonSnackBar(context, 'Settings');
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.pushNamed(context, '/analytics');
    _showComingSoonSnackBar(context, 'Analytics');
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}