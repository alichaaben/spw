import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0; // 0: Tous, 1: Non lus, 2: Transactions, 3: Sécurité
  bool _showArchived = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Argent reçu de Haithem Benali',
      'description': 'Vous avez reçu 150.000 DT de Haithem Benali',
      'timestamp': '2025-09-28 23:56:17',
      'isRead': false,
      'type': 'transaction',
      'icon': Icons.account_balance_wallet,
      'iconColor': Color(0xFF10B981),
      'amount': 150.000,
      'sender': 'Haithem Benali',
    },
    {
      'id': '2',
      'title': 'Compte vérifié',
      'description': 'Votre compte a été vérifié avec succès',
      'timestamp': '2025-09-27 14:24:57',
      'isRead': true,
      'type': 'security',
      'icon': Icons.verified_user,
      'iconColor': Color(0xFF06B6D4),
    },
    {
      'id': '3',
      'title': 'Paiement effectué avec succès',
      'description': 'Paiement de 45.500 DT chez Carrefour',
      'timestamp': '2025-09-26 18:30:45',
      'isRead': true,
      'type': 'transaction',
      'icon': Icons.payment,
      'iconColor': Color(0xFF8B5CF6),
      'amount': -45.500,
      'merchant': 'Carrefour',
    },
    {
      'id': '4',
      'title': 'Nouvelle mise à jour disponible',
      'description': 'Version 2.1.0 avec de nouvelles fonctionnalités',
      'timestamp': '2025-09-25 10:15:22',
      'isRead': true,
      'type': 'system',
      'icon': Icons.system_update,
      'iconColor': Color(0xFFF59E0B),
    },
    {
      'id': '5',
      'title': 'Recharge téléphonique réussie',
      'description': 'Recharge de 10.000 DT pour le numéro +216 12 345 678',
      'timestamp': '2025-09-24 16:42:18',
      'isRead': true,
      'type': 'transaction',
      'icon': Icons.phone_android,
      'iconColor': Color(0xFFEC4899),
      'amount': -10.000,
    },
    {
      'id': '6',
      'title': 'Tentative de connexion suspecte',
      'description': 'Nouvelle connexion détectée depuis un appareil inconnu',
      'timestamp': '2025-09-23 22:10:33',
      'isRead': true,
      'type': 'security',
      'icon': Icons.security,
      'iconColor': Color(0xFFEF4444),
    },
    {
      'id': '7',
      'title': 'Promotion spéciale',
      'description': '20% de réduction sur les recharges ce week-end',
      'timestamp': '2025-09-22 09:30:15',
      'isRead': true,
      'type': 'promotion',
      'icon': Icons.local_offer,
      'iconColor': Color(0xFFEC4899),
    },
    {
      'id': '8',
      'title': 'Transfert envoyé avec succès',
      'description': 'Transfert de 200.000 DT vers Mohamed Ali',
      'timestamp': '2025-09-21 11:20:44',
      'isRead': true,
      'type': 'transaction',
      'icon': Icons.send,
      'iconColor': Color(0xFF3B82F6),
      'amount': -200.000,
      'recipient': 'Mohamed Ali',
    },
  ];

  final List<Map<String, dynamic>> _archivedNotifications = [
    {
      'id': '9',
      'title': 'Maintenance programmée',
      'description': 'Maintenance système le 20 septembre de 02:00 à 04:00',
      'timestamp': '2025-09-19 08:00:00',
      'isRead': true,
      'type': 'system',
      'icon': Icons.build,
      'iconColor': Color(0xFF6B7280),
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    List<Map<String, dynamic>> allNotifications = [..._notifications];
    if (_showArchived) {
      allNotifications.addAll(_archivedNotifications);
    }

    switch (_selectedFilter) {
      case 1: // Non lus
        return allNotifications.where((notification) => !notification['isRead']).toList();
      case 2: // Transactions
        return allNotifications.where((notification) => notification['type'] == 'transaction').toList();
      case 3: // Sécurité
        return allNotifications.where((notification) => notification['type'] == 'security').toList();
      default: // Tous
        return allNotifications;
    }
  }

  int get _unreadCount {
    return _notifications.where((notification) => !notification['isRead']).length;
  }

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
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handlePopupMenuSelect,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    const Icon(Icons.mark_email_read, color: Color(0xFF374151)),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    const Text('Marquer tout comme lu'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    const Text('Supprimer tout'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Color(0xFF374151)),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    const Text('Paramètres notifications'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          _buildHeaderStats(isSmallScreen),

          // Filter Chips
          _buildFilterChips(isSmallScreen),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState(isSmallScreen)
                : _buildNotificationsList(isSmallScreen),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(4),
    );
  }

  Widget _buildHeaderStats(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Non lus',
            _unreadCount.toString(),
            const Color(0xFFEF4444),
            isSmallScreen,
          ),
          _buildStatItem(
            'Total',
            _notifications.length.toString(),
            const Color(0xFF8B5CF6),
            isSmallScreen,
          ),
          _buildStatItem(
            'Aujourd\'hui',
            _getTodayCount().toString(),
            const Color(0xFF10B981),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isSmallScreen) {
    final filters = ['Tous', 'Non lus', 'Transactions', 'Sécurité'];

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = _selectedFilter == index;

            return Container(
              margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
              child: FilterChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? index : 0;
                  });
                },
                selectedColor: const Color(0xFF8B5CF6),
                checkmarkColor: Colors.white,
                backgroundColor: const Color(0xFFF3F4F6),
                showCheckmark: true,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(bool isSmallScreen) {
    return ListView.separated(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: _filteredNotifications.length,
      separatorBuilder: (context, index) => SizedBox(height: isSmallScreen ? 8 : 12),
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _buildNotificationCard(notification, isSmallScreen);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, bool isSmallScreen) {
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(notification);
      },
      onDismissed: (direction) {
        _archiveNotification(notification);
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetails(notification),
        child: Container(
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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: isSmallScreen ? 40 : 48,
                      height: isSmallScreen ? 40 : 48,
                      decoration: BoxDecoration(
                        color: notification['iconColor'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        notification['icon'],
                        color: notification['iconColor'],
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: notification['isRead'] ? FontWeight.w500 : FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 6),
                          Text(
                            notification['description'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Text(
                            _formatTimestamp(notification['timestamp']),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),

                          // Transaction Amount (if applicable)
                          if (notification['amount'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${notification['amount'] > 0 ? '+' : ''}${notification['amount'].toStringAsFixed(3)} DT',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: notification['amount'] > 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Read indicator and menu
                    Column(
                      children: [
                        if (!notification['isRead'])
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        GestureDetector(
                          onTap: () => _showNotificationMenu(notification),
                          child: Icon(
                            Icons.more_vert,
                            color: const Color(0xFF9CA3AF),
                            size: isSmallScreen ? 16 : 20,
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
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: isSmallScreen ? 60 : 80,
            color: const Color(0xFF9CA3AF),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            _selectedFilter == 1
                ? 'Vous n\'avez pas de notifications non lues'
                : 'Vous êtes à jour avec toutes vos notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 32),
          if (_showArchived)
            ElevatedButton(
              onPressed: () => setState(() => _showArchived = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 32,
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
              child: const Text('Masquer les archives'),
            )
          else if (_archivedNotifications.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _showArchived = true),
              child: const Text(
                'Voir les notifications archivées',
                style: TextStyle(color: Color(0xFF8B5CF6)),
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
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // Helper Methods
  String _formatTimestamp(String timestamp) {
    final now = DateTime.now();
    final notificationTime = DateTime.parse(timestamp);
    final difference = now.difference(notificationTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return '${notificationTime.day}/${notificationTime.month}/${notificationTime.year}';
    }
  }

  int _getTodayCount() {
    final today = DateTime.now();
    return _notifications.where((notification) {
      final notificationTime = DateTime.parse(notification['timestamp']);
      return notificationTime.year == today.year &&
          notificationTime.month == today.month &&
          notificationTime.day == today.day;
    }).length;
  }

  // Action Methods
  void _handlePopupMenuSelect(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_all':
        _clearAllNotifications();
        break;
      case 'settings':
        _openNotificationSettings();
        break;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    _showSnackBar('Toutes les notifications marquées comme lues');
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer toutes les notifications'),
        content: const Text('Êtes-vous sûr de vouloir supprimer toutes les notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              _showSnackBar('Toutes les notifications ont été supprimées');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _openNotificationSettings() {
    _showComingSoon('Paramètres des notifications');
  }

  void _showNotificationMenu(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: Color(0xFF374151)),
              title: const Text('Marquer comme lu'),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(notification);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Color(0xFF374151)),
              title: const Text('Archiver'),
              onTap: () {
                Navigator.pop(context);
                _archiveNotification(notification);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              title: const Text('Supprimer', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markAsRead(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });
  }

  void _archiveNotification(Map<String, dynamic> notification) {
    setState(() {
      _notifications.remove(notification);
      _archivedNotifications.add(notification);
    });
    _showSnackBar('Notification archivée');
  }

  void _deleteNotification(Map<String, dynamic> notification) {
    setState(() {
      _notifications.remove(notification);
    });
    _showSnackBar('Notification supprimée');
  }

  Future<bool> _showDeleteConfirmation(Map<String, dynamic> notification) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver la notification'),
        content: const Text('Voulez-vous archiver cette notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    setState(() {
      notification['isRead'] = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification['description']),
            const SizedBox(height: 16),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            if (notification['amount'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Montant: ${notification['amount'] > 0 ? '+' : ''}${notification['amount'].toStringAsFixed(3)} DT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: notification['amount'] > 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
      ),
    );
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