import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = 'Utilisateur';
  String _userEmail = 'user@email.com';
  double _userBalance = 0.000;
  String _userPhone = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('email') ?? '';
      _userBalance = prefs.getDouble('soldeWallet') ?? 0.0;
      _userPhone = prefs.getString('phone') ?? '';
    });

    print('Loaded user: $_userName ');
    print('Wallet Balance: $_userBalance');
    print('Phone: $_userPhone'); 
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

    return Drawer(
      width: size.width * 0.85,
      child: Column(
        children: [
          // Header with user profile
          Container(
            height: isSmallScreen ? 200 : 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6C5CE7),
                  Color(0xFFA29BFE),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background pattern overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 50 : 60,
                            height: isSmallScreen ? 50 : 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                color: Colors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: const Color(0xFF6C5CE7),
                                  size: isSmallScreen ? 24 : 30,
                                ),
                              ),
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
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _userEmail,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // if (_userPhone.isNotEmpty) ...[
                                //   SizedBox(height: 2),
                                //   Text(
                                //     _userPhone,
                                //     style: TextStyle(
                                //       color: Colors.white.withOpacity(0.7),
                                //       fontSize: isSmallScreen ? 11 : 12,
                                //     ),
                                //   ),
                                // ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      // Balance and ID information
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 6 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: isSmallScreen ? 14 : 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '${_userBalance} DT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_userId.isNotEmpty) ...[
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                                vertical: isSmallScreen ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fingerprint_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                    size: isSmallScreen ? 12 : 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'ID: ${_truncateText(_userId, length: 12)}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: isSmallScreen ? 10 : 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Account Section
                _buildSectionHeader('COMPTE'),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profil',
                  onTap: () => _navigateTo(context, '/profile'),
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Historique des transactions',
                  onTap: () => _navigateTo(context, '/history'),
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Solde du compte',
                  onTap: () => _navigateTo(context, '/balance'),
                ),
                _buildDrawerItem(
                  icon: Icons.qr_code_rounded,
                  title: 'Mon QR Code',
                  onTap: () => _navigateTo(context, '/my-qr'),
                ),

                // Services Section
                _buildSectionHeader('SERVICES'),
                _buildDrawerItem(
                  icon: Icons.phone_android_rounded,
                  title: 'Recharge téléphonique',
                  onTap: () => _navigateTo(context, '/recharge'),
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Paiement marchand',
                  onTap: () => _navigateTo(context, '/merchant'),
                ),
                _buildDrawerItem(
                  icon: Icons.send_rounded,
                  title: 'Transfert d\'argent',
                  onTap: () => _navigateTo(context, '/transfer'),
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Paiement de factures',
                  onTap: () => _navigateTo(context, '/bills'),
                ),
                _buildDrawerItem(
                  icon: Icons.sports_esports_rounded,
                  title: 'Jeux et divertissement',
                  onTap: () => _navigateTo(context, '/entertainment'),
                ),

                // Settings Section
                _buildSectionHeader('PARAMÈTRES'),
                _buildDrawerItem(
                  icon: Icons.dark_mode_rounded,
                  title: 'Mode sombre',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement dark mode toggle
                    },
                    activeColor: const Color(0xFF6C5CE7),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  onTap: () => _navigateTo(context, '/notifications'),
                ),
                _buildDrawerItem(
                  icon: Icons.language_rounded,
                  title: 'Langue',
                  onTap: () => _navigateTo(context, '/language'),
                ),
                _buildDrawerItem(
                  icon: Icons.security_rounded,
                  title: 'Sécurité',
                  onTap: () => _navigateTo(context, '/security'),
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Paramètres de l\'app',
                  onTap: () => _navigateTo(context, '/settings'),
                ),

                // Support Section
                _buildSectionHeader('SUPPORT'),
                _buildDrawerItem(
                  icon: Icons.help_rounded,
                  title: 'Centre d\'aide',
                  onTap: () => _navigateTo(context, '/help'),
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Support client',
                  onTap: () => _navigateTo(context, '/support'),
                ),
                _buildDrawerItem(
                  icon: Icons.report_rounded,
                  title: 'Signaler un problème',
                  onTap: () => _navigateTo(context, '/report'),
                ),
                _buildDrawerItem(
                  icon: Icons.info_rounded,
                  title: 'À propos',
                  onTap: () => _navigateTo(context, '/about'),
                ),

                // Actions Section
                _buildSectionHeader('ACTIONS'),
                _buildDrawerItem(
                  icon: Icons.share_rounded,
                  title: 'Partager l\'app',
                  iconColor: const Color(0xFF6C5CE7),
                  onTap: () {
                    _shareApp(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.rate_review_rounded,
                  title: 'Évaluer l\'app',
                  iconColor: const Color(0xFFFDCB6E),
                  onTap: () {
                    _rateApp(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.refresh_rounded,
                  title: 'Actualiser les données',
                  iconColor: const Color(0xFF00B894),
                  onTap: () {
                    _refreshUserData();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Se déconnecter',
                  iconColor: const Color(0xFFE74C3C),
                  textColor: const Color(0xFFE74C3C),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),

                // App Version
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    children: [
                      Text(
                        'SPW Wallet v1.0.0',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Votre portefeuille numérique sécurisé',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF6C5CE7)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFF6C5CE7),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF374151),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade400,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer first
    Navigator.pushNamed(context, route);
  }

  void _refreshUserData() {
    _loadUserData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Données actualisées'),
        backgroundColor: const Color(0xFF6C5CE7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité de partage à venir'),
        backgroundColor: const Color(0xFF6C5CE7),
      ),
    );
  }

  void _rateApp(BuildContext context) {
    // TODO: Implement rate app functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fonctionnalité d\'évaluation à venir'),
        backgroundColor: const Color(0xFFFDCB6E),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFE74C3C),
              ),
              SizedBox(width: 8),
              Text(
                'Se déconnecter',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _performLogout();
      Navigator.pop(context); // Close drawer
      Navigator.pushReplacementNamed(context, '/sign-in');
    }
  }

  Future<void> _performLogout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Clear all user data from SharedPreferences
      await prefs.remove('token');
      await prefs.remove('nextToken');
      await prefs.remove('nom');
      await prefs.remove('prenom');
      await prefs.remove('email');
      await prefs.remove('telephone');
      await prefs.remove('solde');
      await prefs.remove('idUnique');
      await prefs.remove('userData');
      
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  String _truncateText(String text, {int length = 10}) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}