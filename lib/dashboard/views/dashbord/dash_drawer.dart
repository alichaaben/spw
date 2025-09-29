import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
            height: isSmallScreen ? 180 : 200,
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
                                  'Ali Chaabane',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'ali.chaabane@email.com',
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
                      SizedBox(height: isSmallScreen ? 8 : 12),
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
                              '3,002.000 DT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 12 : 14,
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
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Account Section
                _buildSectionHeader('ACCOUNT'),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile',
                  onTap: () => _navigateTo(context, '/profile'),
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Transaction History',
                  onTap: () => _navigateTo(context, '/history'),
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Account Balance',
                  onTap: () => _navigateTo(context, '/balance'),
                ),
                // Services Section
                _buildSectionHeader('SERVICES'),
                _buildDrawerItem(
                  icon: Icons.phone_android_rounded,
                  title: 'Phone Recharge',
                  onTap: () => _navigateTo(context, '/recharge'),
                ),
                _buildDrawerItem(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Merchant Payment',
                  onTap: () => _navigateTo(context, '/merchant'),
                ),
                _buildDrawerItem(
                  icon: Icons.send_rounded,
                  title: 'Money Transfer',
                  onTap: () => _navigateTo(context, '/transfer'),
                ),
                _buildDrawerItem(
                  icon: Icons.sports_esports_rounded,
                  title: 'Gaming',
                  onTap: () => _navigateTo(context, '/entertainment'),
                ),

                // Settings Section
                _buildSectionHeader('SETTINGS'),
                _buildDrawerItem(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: Implement dark mode toggle
                    },
                    activeColor: const Color(0xFF6C5CE7),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'App Settings',
                  onTap: () => _navigateTo(context, '/settings'),
                ),
                _buildDrawerItem(
                  icon: Icons.security_rounded,
                  title: 'Privacy & Security',
                  onTap: () => _navigateTo(context, '/privacy'),
                ),

                // Support Section
                _buildSectionHeader('SUPPORT'),
                _buildDrawerItem(
                  icon: Icons.help_rounded,
                  title: 'Help Center',
                  onTap: () => _navigateTo(context, '/help'),
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Customer Support',
                  onTap: () => _navigateTo(context, '/support'),
                ),
                _buildDrawerItem(
                  icon: Icons.report_rounded,
                  title: 'Report Issue',
                  onTap: () => _navigateTo(context, '/report'),
                ),
                _buildDrawerItem(
                  icon: Icons.info_rounded,
                  title: 'About App',
                  onTap: () => _navigateTo(context, '/about'),
                ),

                // Actions Section
                _buildSectionHeader('ACTIONS'),
                _buildDrawerItem(
                  icon: Icons.share_rounded,
                  title: 'Share with Friends',
                  iconColor: const Color(0xFF6C5CE7),
                  onTap: () {
                    // TODO: Implement share functionality
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.rate_review_rounded,
                  title: 'Rate App',
                  iconColor: const Color(0xFFFDCB6E),
                  onTap: () {
                    // TODO: Implement rate app functionality
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  iconColor: const Color(0xFFE74C3C),
                  textColor: const Color(0xFFE74C3C),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),

                // App Version
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Text(
                    'Wallet App v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                // TODO: Implement logout logic
                Navigator.pushReplacementNamed(context, '/sign-in');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}