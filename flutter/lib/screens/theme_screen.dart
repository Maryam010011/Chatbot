import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  int _selectedFont = 0;
  double _bubbleRadius = 16.0;

  // LOCKED PURPLE THEME
  final Color primaryPurple = const Color(0xFF6A1B9A);
  final Color lightPurple = const Color(0xFFEDE7F6);
  final Color offWhite = const Color(0xFFF8F5FF);

  final List<String> _fonts = [
    'Poppins',
    'Roboto',
    'Lato',
    'Open Sans',
    'Montserrat'
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFont = prefs.getInt('font') ?? 0;
      _bubbleRadius = prefs.getDouble('bubbleRadius') ?? 16.0;
    });
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('font', _selectedFont);
    await prefs.setDouble('bubbleRadius', _bubbleRadius);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Theme Applied Successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Container(
              padding: const EdgeInsets.all(16),
              color: primaryPurple,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Theme Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
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
                    // PREVIEW CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // USER MESSAGE
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: primaryPurple,
                                borderRadius:
                                    BorderRadius.circular(_bubbleRadius),
                              ),
                              child: Text(
                                'Hello! How are you?',
                                style: GoogleFonts.getFont(
                                  _fonts[_selectedFont],
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // BOT MESSAGE
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: lightPurple,
                                borderRadius:
                                    BorderRadius.circular(_bubbleRadius),
                              ),
                              child: Text(
                                'I am doing great, thanks!',
                                style: GoogleFonts.getFont(
                                  _fonts[_selectedFont],
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // BUBBLE RADIUS
                    _buildCard(
                      icon: Icons.chat_bubble,
                      title: 'Bubble Radius',
                      child: Column(
                        children: [
                          Slider(
                            value: _bubbleRadius,
                            min: 0,
                            max: 30,
                            divisions: 6,
                            activeColor: primaryPurple,
                            onChanged: (value) {
                              setState(() => _bubbleRadius = value);
                            },
                          ),
                          Text(
                            '${_bubbleRadius.toInt()} px',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FONT SELECTION
                    _buildCard(
                      icon: Icons.text_fields,
                      title: 'Font Style',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_fonts.length, (index) {
                          bool isSelected = _selectedFont == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFont = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryPurple
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _fonts[index],
                                style: GoogleFonts.getFont(
                                  _fonts[index],
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // APPLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saveTheme,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Apply Theme',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }

  // REUSABLE CARD
  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryPurple),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
