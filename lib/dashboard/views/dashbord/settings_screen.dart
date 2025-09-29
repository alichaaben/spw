import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricAuth = false;
  bool _pinVerification = true;
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _transactionAlerts = true;
  bool _promotionalEmails = false;
  String _selectedLanguage = 'Français';
  String _selectedCurrency = 'TND - Dinar Tunisien';
  String _selectedTheme = 'Auto';

  final List<String> _languages = [
    'Français',
    'English',
    'العربية',
    'Español'
  ];

  final List<String> _currencies = [
    'TND - Dinar Tunisien',
    'EUR - Euro',
    'USD - Dollar US',
    'GBP - Livre Sterling'
  ];

  final List<String> _themes = [
    'Auto',
    'Clair',
    'Sombre'
  ];

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
          'Paramètres',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(),
            const SizedBox(height: 24),

            // Security Section
            _buildSectionHeader('SÉCURITÉ'),
            _buildSecuritySettings(),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('NOTIFICATIONS'),
            _buildNotificationSettings(),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader('PRÉFÉRENCES'),
            _buildPreferenceSettings(),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('SUPPORT'),
            _buildSupportOptions(),

            const SizedBox(height: 24),

            // Legal Section
            _buildSectionHeader('LÉGAL'),
            _buildLegalOptions(),

            const SizedBox(height: 32),

            // App Info
            _buildAppInfo(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF6C5CE7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
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
                  'Ali Chaabane',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ali.chaabane@email.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _editProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Modifier le profil',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2, size: 24),
            onPressed: _showQRCode,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
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
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Modifier le mot de passe',
            subtitle: 'Dernière modification: 15/08/2024',
            onTap: _changePassword,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.pin_outlined,
            title: 'Modifier le PIN',
            subtitle: 'Dernière modification: 20/09/2024',
            onTap: _changePIN,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.fingerprint,
            title: 'Authentification biométrique',
            subtitle: 'Déverrouiller avec empreinte digitale',
            trailing: Switch(
              value: _biometricAuth,
              onChanged: (value) => setState(() => _biometricAuth = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.verified_user,
            title: 'Vérification PIN pour transactions',
            subtitle: 'Exiger PIN pour chaque opération',
            trailing: Switch(
              value: _pinVerification,
              onChanged: (value) => setState(() => _pinVerification = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.security,
            title: 'Sécurité avancée',
            subtitle: 'Options de sécurité supplémentaires',
            onTap: _showSecuritySettings,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
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
          _buildSettingItem(
            icon: Icons.notifications_active,
            title: 'Notifications push',
            subtitle: 'Alertes et mises à jour',
            trailing: Switch(
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.email_outlined,
            title: 'Notifications email',
            subtitle: 'Reçus et rapports',
            trailing: Switch(
              value: _emailNotifications,
              onChanged: (value) => setState(() => _emailNotifications = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.sms_outlined,
            title: 'Notifications SMS',
            subtitle: 'Alertes importantes',
            trailing: Switch(
              value: _smsNotifications,
              onChanged: (value) => setState(() => _smsNotifications = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.payment,
            title: 'Alertes de transaction',
            subtitle: 'Notifications pour chaque opération',
            trailing: Switch(
              value: _transactionAlerts,
              onChanged: (value) => setState(() => _transactionAlerts = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.local_offer,
            title: 'Emails promotionnels',
            subtitle: 'Offres et promotions',
            trailing: Switch(
              value: _promotionalEmails,
              onChanged: (value) => setState(() => _promotionalEmails = value),
              activeColor: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSettings() {
    return Container(
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
          _buildSettingItem(
            icon: Icons.language,
            title: 'Langue',
            subtitle: _selectedLanguage,
            onTap: _showLanguagePicker,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.currency_exchange,
            title: 'Devise',
            subtitle: _selectedCurrency,
            onTap: _showCurrencyPicker,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Thème',
            subtitle: _selectedTheme,
            onTap: _showThemePicker,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.speed,
            title: 'Limites de transaction',
            subtitle: 'Gérer les limites quotidiennes',
            onTap: _showTransactionLimits,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.storage,
            title: 'Stockage et données',
            subtitle: 'Gérer le cache et les données',
            onTap: _showStorageSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return Container(
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
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Centre d\'aide',
            onTap: _showHelpCenter,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.support_agent,
            title: 'Support client',
            subtitle: 'Contactez-nous 24/7',
            onTap: _contactSupport,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.bug_report,
            title: 'Signaler un problème',
            onTap: _reportIssue,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.feedback,
            title: 'Donner votre avis',
            onTap: _giveFeedback,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalOptions() {
    return Container(
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
          _buildSettingItem(
            icon: Icons.description,
            title: 'Conditions d\'utilisation',
            onTap: _showTerms,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Politique de confidentialité',
            onTap: _showPrivacyPolicy,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.credit_card,
            title: 'Frais et tarifs',
            onTap: _showFees,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: 'Clôturer le compte',
            textColor: Colors.red,
            onTap: _closeAccount,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: textColor ?? const Color(0xFF8B5CF6),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? const Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      )
          : null,
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: Color(0xFF9CA3AF),
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Text(
          'Wallet App v1.2.0',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Build 2024.09.29',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              onPressed: _shareApp,
              color: const Color(0xFF8B5CF6),
            ),
            IconButton(
              icon: const Icon(Icons.star_border, size: 20),
              onPressed: _rateApp,
              color: const Color(0xFF8B5CF6),
            ),
            IconButton(
              icon: const Icon(Icons.update, size: 20),
              onPressed: _checkForUpdates,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ],
    );
  }

  // Action Methods
  void _editProfile() {
    _showComingSoon('Modification du profil');
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mon QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scannez ce code pour recevoir des paiements',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    _showComingSoon('Changement de mot de passe');
  }

  void _changePIN() {
    _showComingSoon('Changement de PIN');
  }

  void _showSecuritySettings() {
    _showComingSoon('Paramètres de sécurité avancés');
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildPickerBottomSheet(
        title: 'Choisir la langue',
        options: _languages,
        selectedValue: _selectedLanguage,
        onSelected: (value) => setState(() => _selectedLanguage = value),
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildPickerBottomSheet(
        title: 'Choisir la devise',
        options: _currencies,
        selectedValue: _selectedCurrency,
        onSelected: (value) => setState(() => _selectedCurrency = value),
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildPickerBottomSheet(
        title: 'Choisir le thème',
        options: _themes,
        selectedValue: _selectedTheme,
        onSelected: (value) => setState(() => _selectedTheme = value),
      ),
    );
  }

  Widget _buildPickerBottomSheet({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) => ListTile(
            title: Text(option),
            trailing: option == selectedValue
                ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                : null,
            onTap: () {
              onSelected(option);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  void _showTransactionLimits() {
    _showComingSoon('Limites de transaction');
  }

  void _showStorageSettings() {
    _showComingSoon('Paramètres de stockage');
  }

  void _showHelpCenter() {
    _showComingSoon('Centre d\'aide');
  }

  void _contactSupport() {
    _showComingSoon('Support client');
  }

  void _reportIssue() {
    _showComingSoon('Signaler un problème');
  }

  void _giveFeedback() {
    _showComingSoon('Donner votre avis');
  }

  void _showTerms() {
    _showComingSoon('Conditions d\'utilisation');
  }

  void _showPrivacyPolicy() {
    _showComingSoon('Politique de confidentialité');
  }

  void _showFees() {
    _showComingSoon('Frais et tarifs');
  }

  void _closeAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clôturer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir clôturer votre compte? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Clôture du compte');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clôturer'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    _showComingSoon('Partager l\'application');
  }

  void _rateApp() {
    _showComingSoon('Évaluer l\'application');
  }

  void _checkForUpdates() {
    _showComingSoon('Vérifier les mises à jour');
  }

  void _showHelp() {
    _showComingSoon('Aide');
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Bientôt disponible!'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
    );
  }
}