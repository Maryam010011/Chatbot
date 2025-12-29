import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _hapticFeedback = true;
  String _language = 'English';
  double _fontSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _soundEffects = prefs.getBool('soundEffects') ?? true;
      _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
      _language = prefs.getString('language') ?? 'English';
      _fontSize = prefs.getDouble('fontSize') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('soundEffects', _soundEffects);
    await prefs.setBool('hapticFeedback', _hapticFeedback);
    await prefs.setString('language', _language);
    await prefs.setDouble('fontSize', _fontSize);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved', style: GoogleFonts.poppins()),
          backgroundColor: Color(0xFF9C27B0),  // lightPurple
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache cleared', style: GoogleFonts.poppins()),
         backgroundColor: Color(0xFFBA68C8),  // palePurple
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          colors: [
  Color(0xFF6A1B9A),
  Color(0xFF9C27B0),
],

          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Appearance Section
                      _buildSectionCard(
                        'Appearance',
                        Icons.palette,
                        [
                          _buildSwitchTile(
                            'Dark Mode',
                            'Use dark theme',
                            Icons.dark_mode,
                            _darkMode,
                            (value) => setState(() => _darkMode = value),
                          ),
                          const Divider(height: 1),
                          _buildSliderTile(
                            'Font Size',
                            Icons.text_fields,
                            _fontSize,
                            0.8,
                            1.4,
                            (value) => setState(() => _fontSize = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Notifications Section
                      _buildSectionCard(
                        'Notifications',
                        Icons.notifications,
                        [
                          _buildSwitchTile(
                            'Push Notifications',
                            'Receive message alerts',
                            Icons.notifications_active,
                            _notifications,
                            (value) => setState(() => _notifications = value),
                          ),
                          const Divider(height: 1),
                          _buildSwitchTile(
                            'Sound Effects',
                            'Play sounds for messages',
                            Icons.volume_up,
                            _soundEffects,
                            (value) => setState(() => _soundEffects = value),
                          ),
                          const Divider(height: 1),
                          _buildSwitchTile(
                            'Haptic Feedback',
                            'Vibrate on actions',
                            Icons.vibration,
                            _hapticFeedback,
                            (value) => setState(() => _hapticFeedback = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Language Section
                      _buildSectionCard(
                        'Language',
                        Icons.language,
                        [
                          _buildDropdownTile(
                            'Language',
                            Icons.translate,
                            _language,
                            ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
                            (value) => setState(() => _language = value!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Data Section
                      _buildSectionCard(
                        'Data & Storage',
                        Icons.storage,
                        [
                          _buildActionTile(
                            'Clear Cache',
                            'Free up storage space',
                            Icons.cleaning_services,
                            _clearCache,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:Color(0xFF6A1B9A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Save Settings',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color:Color(0xFF6A1B9A), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color:Color(0xFF6A1B9A), size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor:Color(0xFF6A1B9A),
      ),
    );
  }

  Widget _buildSliderTile(String title, IconData icon, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Color(0xFF6A1B9A), size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('${(value * 100).toInt()}%', style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 6,
            activeColor: Color(0xFF6A1B9A),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, IconData icon, String value, List<String> options, Function(String?) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Color(0xFF6A1B9A), size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: GoogleFonts.poppins()))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Color(0xFF9C27B0), size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
