import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I start a conversation?',
      'answer': 'Simply type your message in the text field at the bottom of the chat screen and press send. The chatbot will respond to your queries about Data Structures and Algorithms.',
    },
    {
      'question': 'What topics can the chatbot help with?',
      'answer': 'The DSA Chatbot can help you with various topics including Arrays, LinkedLists, Stacks, Queues, Trees, Graphs, Sorting algorithms, Searching algorithms, Hash Tables, and more!',
    },
    {
      'question': 'How do I add custom responses?',
      'answer': 'Go to the Custom Responses screen from the menu. Click the + button to add a new keyword-response pair. When you type the keyword, the bot will respond with your custom response.',
    },
    {
      'question': 'Is my chat history saved?',
      'answer': 'Yes! Your chat history is automatically saved to Firebase and synced across sessions. You can view your history in the Chat History screen or clear it from the chat screen.',
    },
    {
      'question': 'How do I change the app theme?',
      'answer': 'Go to the Theme screen from the menu. You can choose from various color themes, adjust bubble radius, and select different fonts to personalize your experience.',
    },
    {
      'question': 'Can I use the app offline?',
      'answer': 'The app requires an internet connection to communicate with the backend server and Firebase. However, some settings are stored locally for quick access.',
    },
    {
      'question': 'How do I clear my chat history?',
      'answer': 'In the chat screen, tap the delete icon in the top right corner. You\'ll be asked to confirm before your history is permanently deleted.',
    },
    {
      'question': 'What is the bot personality feature?',
      'answer': 'The Bot Personality feature lets you choose how the chatbot communicates with you. Options include Buddy (casual), Professor (educational), Assistant (professional), and more!',
    },
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'Email Support',
      'subtitle': 'Get help via email',
      'icon': Icons.email,
      'color': Colors.blue,
      'action': 'support@dsachatbot.com',
    },
    {
      'title': 'Report a Bug',
      'subtitle': 'Found an issue? Let us know',
      'icon': Icons.bug_report,
      'color': Colors.orange,
      'action': 'bugs@dsachatbot.com',
    },
    {
      'title': 'Feature Request',
      'subtitle': 'Suggest new features',
      'icon': Icons.lightbulb,
      'color': Colors.green,
      'action': 'features@dsachatbot.com',
    },
    {
      'title': 'Documentation',
      'subtitle': 'Read the full docs',
      'icon': Icons.menu_book,
      'color': Colors.purple,
      'action': 'https://docs.dsachatbot.com',
    },
  ];

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
                      'Help & FAQ',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Actions
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
                            Row(
                              children: [
                                Icon(Icons.support_agent, color: Colors.blue.shade600),
                                const SizedBox(width: 12),
                                Text(
                                  'Get Support',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.5,
                              children: _supportOptions.map((option) {
                                return GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Opening: ${option['action']}', style: GoogleFonts.poppins()),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: option['color'].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(option['icon'], color: option['color'], size: 28),
                                        const SizedBox(height: 8),
                                        Text(
                                          option['title'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: option['color'],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // FAQ Section
                      Text(
                        'Frequently Asked Questions',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...List.generate(_faqs.length, (index) {
                        final faq = _faqs[index];
                        bool isExpanded = _expandedIndex == index;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.help_outline, color: Colors.blue.shade600, size: 20),
                                ),
                                title: Text(
                                  faq['question']!,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                trailing: Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.grey.shade400,
                                ),
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });
                                },
                              ),
                              if (isExpanded)
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.blue.shade600, size: 18),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            faq['answer']!,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      
                      // Tips Section
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
                            Row(
                              children: [
                                Icon(Icons.tips_and_updates, color: Colors.amber.shade600),
                                const SizedBox(width: 12),
                                Text(
                                  'Pro Tips',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTipItem('💡', 'Ask specific questions for better responses'),
                            _buildTipItem('📚', 'Try asking about time complexity of algorithms'),
                            _buildTipItem('🔄', 'Use custom responses to add frequently needed info'),
                            _buildTipItem('🎨', 'Customize your theme in the Theme settings'),
                          ],
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

  Widget _buildTipItem(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
