import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chatbot_service.dart';

class StatisticsScreen extends StatefulWidget {
  final String userId;
  
  const StatisticsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ChatbotService _chatbotService = ChatbotService(baseUrl: 'http://127.0.0.1:8081');
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      // Get messages to calculate stats
      final messages = await _chatbotService.getHistory(widget.userId, limit: 1000);
      
      // Calculate statistics
      int totalMessages = messages.length;
      int userMessages = messages.where((m) => m.sender == 'user').length;
      int botMessages = messages.where((m) => m.sender == 'bot').length;
      
      // Group messages by date
      Map<String, int> messagesByDate = {};
      for (var msg in messages) {
        String date = msg.timestamp.split(' ').take(4).join(' ');
        messagesByDate[date] = (messagesByDate[date] ?? 0) + 1;
      }
      
      setState(() {
        _messages = messages;
        _stats = {
          'totalMessages': totalMessages,
          'userMessages': userMessages,
          'botMessages': botMessages,
          'avgPerDay': totalMessages > 0 ? (totalMessages / (messagesByDate.length > 0 ? messagesByDate.length : 1)).toStringAsFixed(1) : '0',
          'messagesByDate': messagesByDate,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
                      'Statistics',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loadStatistics,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Overview Cards
                            Row(
                              children: [
                                Expanded(child: _buildStatCard('Total Messages', '${_stats['totalMessages'] ?? 0}', Icons.message,Color(0xFF6A1B9A))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatCard('Your Messages', '${_stats['userMessages'] ?? 0}', Icons.person,Color(0xFF9C27B0))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildStatCard('Bot Responses', '${_stats['botMessages'] ?? 0}', Icons.smart_toy,Color(0xFF6A1B9A))),
                                const SizedBox(width: 16),
                                Expanded(child: _buildStatCard('Avg per Day', '${_stats['avgPerDay'] ?? 0}', Icons.trending_up,Color(0xFFBA68C8))),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Activity Chart
                            _buildActivityCard(),
                            const SizedBox(height: 24),
                            
                            // Recent Activity
                            _buildRecentActivityCard(),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    Map<String, int> messagesByDate = _stats['messagesByDate'] ?? {};
    List<MapEntry<String, int>> sortedEntries = messagesByDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    List<MapEntry<String, int>> recentDays = sortedEntries.length > 7 
        ? sortedEntries.sublist(sortedEntries.length - 7) 
        : sortedEntries;

    int maxValue = recentDays.isEmpty ? 1 : recentDays.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
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
            'Activity (Last 7 Days)',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: recentDays.isEmpty
                ? Center(
                    child: Text(
                      'No activity yet',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: recentDays.map((entry) {
                      double height = maxValue > 0 ? (entry.value / maxValue) * 80 : 0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value}',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 30,
                            height: height + 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.blue.shade400, Colors.purple.shade400],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key.split(' ')[2],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    List<ChatMessage> recent = _messages.length > 5 ? _messages.sublist(_messages.length - 5) : _messages;

    return Container(
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
            'Recent Messages',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No messages yet',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            ...recent.reversed.map((msg) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: msg.sender == 'user' ? Colors.blue.shade100 : Colors.purple.shade100,
                    child: Icon(
                      msg.sender == 'user' ? Icons.person : Icons.smart_toy,
                      size: 16,
                      color: msg.sender == 'user' ? Colors.blue.shade600 : Colors.purple.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content.length > 40 ? '${msg.content.substring(0, 40)}...' : msg.content,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          msg.timestamp,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
