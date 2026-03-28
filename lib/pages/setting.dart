import 'package:flutter/material.dart';
import '../color.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/db/DBHelper.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  final DBHelper _dbHelper = DBHelper();
  Map<String, dynamic>? _userData;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _userEmail = prefs.getString('userEmail');
      Logger().d("sdfsdfsd $_userEmail");
    });
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_userEmail != null) {
      Logger().d("kjfdsjkfbds $_userEmail");
      final user = await _dbHelper.getUserByEmail(_userEmail!);
      setState(() {
        _userData = user;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppThemeColors.primaryGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Settings',
            style: TextStyle(
              color: AppThemeColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppThemeColors.textPrimary),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfileCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Appearance'),
              _buildThemeCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Text & Display'),
              _buildFontSizeCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Notifications'),
              _buildNotificationCard(),
              const SizedBox(height: 20),
              _buildResetButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            AppThemeColors.glassPrimary,
            AppThemeColors.glassSecondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppThemeColors.glassBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppThemeColors.cardShadow,
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: _userData?['profile_image'] != null
                  ? FileImage(File(_userData!['profile_image']))
                  : null,
              child: _userData?['profile_image'] == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData?['name'] ?? 'User Name',
                    style: const TextStyle(
                      color: AppThemeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData?['email'] ?? 'user@example.com',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData?['phone'] ?? 'No contact info',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppThemeColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildThemeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            AppThemeColors.glassPrimary,
            AppThemeColors.glassSecondary,
          ],
        ),
        border: Border.all(
          color: AppThemeColors.glassBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppThemeColors.cardShadow,
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDarkMode ? AppThemeColors.primaryGradientMid : AppThemeColors.primaryGradientStart,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      color: AppThemeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                  _saveSettings();
                });
              },
              activeColor: AppThemeColors.primaryGradientStart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            AppThemeColors.glassPrimary,
            AppThemeColors.glassSecondary,
          ],
        ),
        border: Border.all(
          color: AppThemeColors.glassBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppThemeColors.cardShadow,
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemeColors.primaryGradientStart,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.text_fields, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Font Size',
                  style: TextStyle(
                    color: AppThemeColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              label: _fontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                  _saveSettings();
                });
              },
              activeColor: AppThemeColors.primaryGradientStart,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('A', style: TextStyle(fontSize: 12, color: AppThemeColors.textPrimary)),
                Text(
                  'A',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppThemeColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Sample Text',
                style: TextStyle(
                  fontSize: _fontSize,
                  color: AppThemeColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            AppThemeColors.glassPrimary,
            AppThemeColors.glassSecondary,
          ],
        ),
        border: Border.all(
          color: AppThemeColors.glassBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppThemeColors.cardShadow,
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeColors.primaryGradientEnd,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: AppThemeColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    _notificationsEnabled ? 'Enabled' : 'Disabled',
                    style: TextStyle(
                      color: AppThemeColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  _saveSettings();
                });
              },
              activeColor: AppThemeColors.primaryGradientStart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.red,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            setState(() {
              _fontSize = 16.0;
              _isDarkMode = false;
              _notificationsEnabled = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Settings reset to defaults',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppThemeColors.primaryGradientStart,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Reset to Defaults',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
