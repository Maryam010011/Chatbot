import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/custom_responses_screen.dart';
import '../screens/about_screen.dart';
import '../screens/history_list_screen.dart';
import '../screens/theme_screen.dart';
import '../screens/personality_screen.dart';
import '../screens/help_screen.dart';
import '../screens/login_screen.dart';

class MenuDrawer extends StatelessWidget {
  final String userId;
  
  const MenuDrawer({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade400,
              Colors.blue.shade500,
              Colors.cyan.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // User Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        (user?.displayName?.isNotEmpty == true
                            ? user!.displayName![0]
                            : user?.email?[0] ?? 'U').toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'User',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.email ?? userId,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              
              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.person_outline,
                      'Profile',
                      () => _navigateTo(context, const ProfileScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.bar_chart,
                      'Statistics',
                      () => _navigateTo(context, StatisticsScreen(userId: userId)),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.history,
                      'Chat History',
                      () => _navigateTo(context, HistoryListScreen(userId: userId)),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.question_answer_outlined,
                      'Custom Responses',
                      () => _navigateTo(context, CustomResponsesScreen(userId: userId)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Divider(color: Colors.white24),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.palette,
                      'Theme',
                      () => _navigateTo(context, const ThemeScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.smart_toy,
                      'Bot Personality',
                      () => _navigateTo(context, const PersonalityScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.settings,
                      'Settings',
                      () => _navigateTo(context, const SettingsScreen()),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Divider(color: Colors.white24),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.help_outline,
                      'Help & FAQ',
                      () => _navigateTo(context, const HelpScreen()),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.info_outline,
                      'About',
                      () => _navigateTo(context, const AboutScreen()),
                    ),
                  ],
                ),
              ),
              
              // Sign Out Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await authService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white24),
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
