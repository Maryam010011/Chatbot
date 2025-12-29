import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chatbot_service.dart';

class CustomResponsesScreen extends StatefulWidget {
  final String userId;
  
  const CustomResponsesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CustomResponsesScreen> createState() => _CustomResponsesScreenState();
}

class _CustomResponsesScreenState extends State<CustomResponsesScreen> {
  final ChatbotService _chatbotService = ChatbotService(baseUrl: 'http://127.0.0.1:8081');
  final _keywordController = TextEditingController();
  final _responseController = TextEditingController();
  List<Map<String, String>> _responses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _loadResponses() async {
    setState(() => _isLoading = true);
    try {
      // In a real app, you'd fetch from the backend
      // For now, we'll use a placeholder
      setState(() {
        _responses = [
          {'keyword': 'hello', 'response': 'Hi there! How can I help you today?'},
          {'keyword': 'bye', 'response': 'Goodbye! Have a great day!'},
          {'keyword': 'thanks', 'response': 'You\'re welcome! Happy to help!'},
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addResponse() async {
    final keyword = _keywordController.text.trim().toLowerCase();
    final response = _responseController.text.trim();

    if (keyword.isEmpty || response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in both fields', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      await _chatbotService.addCustomResponse(keyword, response, widget.userId);
      
      setState(() {
        _responses.add({'keyword': keyword, 'response': response});
      });
      
      _keywordController.clear();
      _responseController.clear();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Custom response added!', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add response', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Custom Response', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _keywordController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Keyword',
                  hintText: 'e.g., hello, help, info',
                  prefixIcon: Icon(Icons.key, color: Colors.blue.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _responseController,
                style: GoogleFonts.poppins(),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Response',
                  hintText: 'What should the bot reply?',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.message, color: Colors.blue.shade600),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _keywordController.clear();
              _responseController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _addResponse,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Add', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _deleteResponse(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Response?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete this custom response?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _responses.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
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
                    Expanded(
                      child: Text(
                        'Custom Responses',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white.withOpacity(0.9)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add custom keywords and responses to personalize your chatbot experience.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _responses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.question_answer_outlined, size: 64, color: Colors.white.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  'No custom responses yet',
                                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _showAddDialog,
                                  icon: const Icon(Icons.add),
                                  label: Text('Add Your First', style: GoogleFonts.poppins()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _responses.length,
                            itemBuilder: (context, index) {
                              final response = _responses[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.key, color: Colors.blue.shade600),
                                  ),
                                  title: Text(
                                    response['keyword'] ?? '',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      response['response'] ?? '',
                                      style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                                    onPressed: () => _deleteResponse(index),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
