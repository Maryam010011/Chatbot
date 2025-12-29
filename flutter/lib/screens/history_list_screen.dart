import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chatbot_service.dart';

class HistoryListScreen extends StatefulWidget {
  final String userId;
  
  const HistoryListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  final ChatbotService _chatbotService = ChatbotService(baseUrl: 'http://127.0.0.1:8081');
  final TextEditingController _searchController = TextEditingController();
  List<ChatMessage> _allMessages = [];
  List<ChatMessage> _filteredMessages = [];
  Map<String, List<ChatMessage>> _groupedMessages = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final messages = await _chatbotService.getHistory(widget.userId, limit: 500);
      setState(() {
        _allMessages = messages;
        _filteredMessages = messages;
        _groupMessages();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _groupMessages() {
    _groupedMessages.clear();
    for (var msg in _filteredMessages) {
      // Extract date from timestamp
      String date = _extractDate(msg.timestamp);
      if (!_groupedMessages.containsKey(date)) {
        _groupedMessages[date] = [];
      }
      _groupedMessages[date]!.add(msg);
    }
  }

  String _extractDate(String timestamp) {
    try {
      // Assuming format like "Fri Dec 26 00:43:49 2025"
      List<String> parts = timestamp.split(' ');
      if (parts.length >= 4) {
        return '${parts[0]} ${parts[1]} ${parts[2]}'; // e.g., "Fri Dec 26"
      }
    } catch (e) {
      // ignore
    }
    return 'Unknown Date';
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredMessages = _allMessages;
      } else {
        _filteredMessages = _allMessages
            .where((msg) => msg.content.toLowerCase().contains(_searchQuery))
            .toList();
      }
      _groupMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> sortedDates = _groupedMessages.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Recent first

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
          colors: [
  Color(0xFF6A1B9A),
  Color(0xFF9C27B0),
],
  end: Alignment.bottomRight,
          
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
                      'Chat History',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadHistory,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Results count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredMessages.length} messages found',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _filteredMessages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history, size: 64, color: Colors.white.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty ? 'No history yet' : 'No results found',
                                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              String date = sortedDates[index];
                              List<ChatMessage> messages = _groupedMessages[date]!;
                              
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12, top: index > 0 ? 16 : 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            date,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${messages.length} messages',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Messages for this date
                                  ...messages.map((msg) => _buildMessageTile(msg)),
                                ],
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

  Widget _buildMessageTile(ChatMessage message) {
    bool isUser = message.sender == 'user';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isUser ? Colors.blue.shade100 : Colors.purple.shade100,
          child: Icon(
            isUser ? Icons.person : Icons.smart_toy,
            color: isUser ? Colors.blue.shade600 : Colors.purple.shade600,
            size: 20,
          ),
        ),
        title: Text(
          message.content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          message.timestamp.split(' ').skip(3).take(1).join(),
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue.shade50 : Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isUser ? 'You' : 'Bot',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isUser ? Colors.blue.shade600 : Colors.purple.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
