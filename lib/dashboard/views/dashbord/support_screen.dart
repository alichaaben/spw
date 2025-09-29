import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String selectedSubject = 'Choisir un sujet';
  bool isBold = false;
  int _selectedTab = 0;
  int _selectedFaq = -1;

  final List<String> subjects = [
    'Choisir un sujet',
    'Problème de paiement',
    'Problème de connexion',
    'Question générale',
    'Réclamation',
    'Problème technique',
    'Sécurité du compte',
    'Facturation',
    'Autre',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Comment recharger mon compte?',
      'answer': 'Vous pouvez recharger votre compte via carte bancaire, virement, ou chez nos revendeurs agréés.',
      'category': 'Compte'
    },
    {
      'question': 'Que faire en cas de paiement échoué?',
      'answer': 'Vérifiez votre solde et votre connexion internet. Si le problème persiste, contactez notre support.',
      'category': 'Paiement'
    },
    {
      'question': 'Comment modifier mon mot de passe?',
      'answer': 'Allez dans Paramètres > Sécurité > Modifier le mot de passe.',
      'category': 'Sécurité'
    },
    {
      'question': 'Quels sont les frais de transfert?',
      'answer': 'Les frais de transfert sont de 0.5% avec un minimum de 0.100 DT.',
      'category': 'Frais'
    },
    {
      'question': 'Comment contacter le support?',
      'answer': 'Vous pouvez nous contacter via cette page, par email à support@spw.tn ou par téléphone au 70 000 000.',
      'category': 'Support'
    },
  ];

  final List<Map<String, dynamic>> _supportHistory = [
    {
      'id': '#12345',
      'subject': 'Problème de paiement',
      'status': 'Résolu',
      'date': '28/09/25',
      'priority': 'Haute'
    },
    {
      'id': '#12344',
      'subject': 'Question générale',
      'status': 'En cours',
      'date': '27/09/25',
      'priority': 'Moyenne'
    },
    {
      'id': '#12343',
      'subject': 'Réclamation',
      'status': 'Résolu',
      'date': '25/09/25',
      'priority': 'Haute'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;

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
          'Support & Aide',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showSupportHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTab('Nouveau message', 0, isSmallScreen),
                _buildTab('FAQ', 1, isSmallScreen),
                _buildTab('Contact', 2, isSmallScreen),
              ],
            ),
          ),
          Expanded(
            child: _buildCurrentTab(isSmallScreen),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(3),
    );
  }

  Widget _buildTab(String title, int index, bool isSmallScreen) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF6B7280),
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(bool isSmallScreen) {
    switch (_selectedTab) {
      case 0:
        return _buildNewMessageTab(isSmallScreen);
      case 1:
        return _buildFaqTab(isSmallScreen);
      case 2:
        return _buildContactTab(isSmallScreen);
      default:
        return _buildNewMessageTab(isSmallScreen);
    }
  }

  Widget _buildNewMessageTab(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          // Support illustration
          _buildSupportIllustration(isSmallScreen),
          SizedBox(height: isSmallScreen ? 20 : 24),

          // Subject dropdown
          _buildSubjectDropdown(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // Message input
          _buildMessageInput(isSmallScreen),
          SizedBox(height: isSmallScreen ? 16 : 20),

          // Action buttons
          _buildActionButtons(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildSupportIllustration(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 30 : 40),
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: isSmallScreen ? 70 : 80,
                height: isSmallScreen ? 70 : 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.support_agent,
                  size: isSmallScreen ? 35 : 40,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  width: isSmallScreen ? 35 : 40,
                  height: isSmallScreen ? 35 : 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat,
                    size: isSmallScreen ? 18 : 20,
                    color: const Color(0xFF06B6D4),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Notre équipe est là pour vous aider',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Réponse sous 24 heures',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDropdown(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedSubject,
        decoration: InputDecoration(
          prefixIcon: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.category,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 14 : 16,
            horizontal: 16,
          ),
        ),
        items: subjects.map((String subject) {
          return DropdownMenuItem<String>(
            value: subject,
            child: Text(
              subject,
              style: TextStyle(
                color: subject == 'Choisir un sujet'
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF374151),
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedSubject = newValue!;
          });
        },
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  Widget _buildMessageInput(bool isSmallScreen) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Décrivez votre problème en détail...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                ),
              ),
            ),
            // Text formatting toolbar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 10 : 12,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isBold = !isBold;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isBold ? const Color(0xFF8B5CF6).withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _attachImage,
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: const Color(0xFF6B7280),
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      IconButton(
                        onPressed: _recordVoice,
                        icon: Icon(
                          Icons.mic_outlined,
                          color: const Color(0xFF6B7280),
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      IconButton(
                        onPressed: _attachFile,
                        icon: Icon(
                          Icons.attach_file,
                          color: const Color(0xFF6B7280),
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isSmallScreen) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Envoyer le message',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showMyClaims,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Mes réclamations',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqTab(bool isSmallScreen) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher dans les FAQ...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 14 : 16,
              ),
            ),
            onChanged: (value) {
              // Implement search functionality
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            itemCount: _faqs.length,
            itemBuilder: (context, index) {
              final faq = _faqs[index];
              final isExpanded = _selectedFaq == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    faq['question'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    faq['category'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  trailing: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF8B5CF6),
                  ),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _selectedFaq = expanded ? index : -1;
                    });
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Text(
                        faq['answer'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactTab(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          _buildContactCard(
            'Support téléphonique',
            '70 000 000',
            Icons.phone,
            const Color(0xFF10B981),
            _callSupport,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildContactCard(
            'Email support',
            'support@spw.tn',
            Icons.email,
            const Color(0xFF8B5CF6),
            _emailSupport,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildContactCard(
            'Chat en direct',
            'Disponible 24h/24',
            Icons.chat,
            const Color(0xFF06B6D4),
            _startLiveChat,
            isSmallScreen,
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Container(
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
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: isSmallScreen ? 40 : 48,
                  color: const Color(0xFF8B5CF6),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Horaires de support',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                _buildScheduleItem('Lun - Ven', '08:00 - 18:00', isSmallScreen),
                _buildScheduleItem('Samedi', '09:00 - 16:00', isSmallScreen),
                _buildScheduleItem('Dimanche', 'Fermé', isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, bool isSmallScreen) {
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
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isSmallScreen ? 24 : 28),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF9CA3AF),
              size: isSmallScreen ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String day, String time, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: const Color(0xFF374151),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(int currentIndex) {
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
        currentIndex: currentIndex,
        elevation: 0,
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
  void _sendMessage() {
    if (selectedSubject == 'Choisir un sujet' || _messageController.text.isEmpty) {
      _showErrorDialog('Veuillez sélectionner un sujet et écrire un message');
      return;
    }
    _showSuccessDialog('Votre message a été envoyé avec succès!');
  }

  void _showMyClaims() {
    _showComingSoon('Mes réclamations');
  }

  void _showSupportHistory() {
    _showComingSoon('Historique du support');
  }

  void _attachImage() {
    _showComingSoon('Attacher une image');
  }

  void _recordVoice() {
    _showComingSoon('Enregistrement vocal');
  }

  void _attachFile() {
    _showComingSoon('Attacher un fichier');
  }

  void _callSupport() {
    _showComingSoon('Appel du support');
  }

  void _emailSupport() {
    _showComingSoon('Email du support');
  }

  void _startLiveChat() {
    _showComingSoon('Chat en direct');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Succès'),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erreur'),
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