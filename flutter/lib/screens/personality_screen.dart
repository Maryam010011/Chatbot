import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({Key? key}) : super(key: key);

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen> {
  int _selectedPersonality = 0;
  final TextEditingController _customNameController = TextEditingController();

  final List<Map<String, dynamic>> _personalities = [
    {
      'name': 'Buddy',
      'description': 'Friendly and casual, like chatting with a friend',
      'icon': Icons.emoji_emotions,
      'color': Color(0xFF9C27B0),
      'avatar': '🤗',
      'greeting': 'Hey there! What\'s up?',
    },
    {
      'name': 'Professor',
      'description': 'Formal and educational, focuses on detailed explanations',
      'icon': Icons.school,
      'color': Color(0xFF6A1B9A),
      'avatar': '🎓',
      'greeting': 'Good day! How may I assist you with your learning today?',
    },
    {
      'name': 'Assistant',
      'description': 'Professional and efficient, straight to the point',
      'icon': Icons.work,
      'color':Color(0xFF6A1B9A),
      'avatar': '💼',
      'greeting': 'Hello! How can I help you today?',
    },
    {
      'name': 'Creative',
      'description': 'Imaginative and playful, loves exploring ideas',
      'icon': Icons.brush,
      'color': Colors.purple,
      'avatar': '🎨',
      'greeting': 'Hi there, creative soul! Let\'s explore some ideas!',
    },
    {
      'name': 'Tech Guru',
      'description': 'Technical and precise, loves diving into code',
      'icon': Icons.code,
      'color':Color(0xFF6A1B9A),
      'avatar': '💻',
      'greeting': 'Greetings, developer! Ready to write some code?',
    },
    {
      'name': 'Zen Master',
      'description': 'Calm and thoughtful, mindful communication',
      'icon': Icons.self_improvement,
      'color': Color(0xFF9C27B0),
      'avatar': '🧘',
      'greeting': 'Peace be with you. How may I guide you today?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPersonality();
  }

  @override
  void dispose() {
    _customNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonality() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPersonality = prefs.getInt('personality') ?? 0;
      _customNameController.text = prefs.getString('botCustomName') ?? '';
    });
  }

  Future<void> _savePersonality() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('personality', _selectedPersonality);
    await prefs.setString('botCustomName', _customNameController.text.trim());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personality applied!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentPersonality = _personalities[_selectedPersonality];
    
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
                      'Bot Personality',
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
                      // Preview Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: currentPersonality['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  currentPersonality['avatar'],
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _customNameController.text.isNotEmpty
                                  ? _customNameController.text
                                  : currentPersonality['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF8F5FF) ,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: currentPersonality['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                currentPersonality['description'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: currentPersonality['color'],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.chat_bubble, color: currentPersonality['color'], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '"${currentPersonality['greeting']}"',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Custom Name
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            Text(
                              'Custom Name (Optional)',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _customNameController,
                              onChanged: (_) => setState(() {}),
                              style: GoogleFonts.poppins(),
                              decoration: InputDecoration(
                                hintText: 'Enter a custom name for your bot',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                                prefixIcon: Icon(Icons.edit, color: Color(0xFF6A1B9A)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:Color(0xFFF8F5FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Personality Options
                      Text(
                        'Choose Personality',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...List.generate(_personalities.length, (index) {
                        Map<String, dynamic> personality = _personalities[index];
                        bool isSelected = _selectedPersonality == index;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: personality['color'], width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: personality['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  personality['avatar'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            title: Text(
                              personality['name'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            subtitle: Text(
                              personality['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: personality['color'])
                                : Icon(Icons.circle_outlined, color: Colors.grey.shade300),
                            onTap: () => setState(() => _selectedPersonality = index),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _savePersonality,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: currentPersonality['color'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Apply Personality',
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
}
