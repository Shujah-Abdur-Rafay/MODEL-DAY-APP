import 'package:flutter/material.dart';
import 'package:new_flutter/widgets/app_layout.dart';
import 'package:new_flutter/widgets/ui/button.dart' as ui;
import 'package:flutter_animate/flutter_animate.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, required this.timestamp});
}

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      Message(
        text:
            "Hi! I'm Model Day AI, your personal modeling career assistant. I can help you analyze your Model Day data, provide insights about your jobs, events, and agents, calculate earnings, and answer any questions about your modeling career data. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        Message(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _isTyping = true;
      _error = null;
    });

    _scrollToBottom();

    try {
      // Simulate AI response with context-aware replies
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      String aiResponse = _generateAIResponse(text);

      setState(() {
        _messages.add(
          Message(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = 'Failed to get AI response: $e';
        _isTyping = false;
      });
    }
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Context-aware responses based on keywords
    if (message.contains('job') || message.contains('booking')) {
      return "I can help you manage your jobs and bookings! You can create new jobs, track payments, and view your upcoming bookings in the Jobs section. Would you like me to guide you through creating a new job?";
    } else if (message.contains('casting') || message.contains('audition')) {
      return "Great question about castings! You can track all your casting calls, auditions, and their statuses in the Castings section. I can help you organize your casting schedule and prepare for upcoming auditions.";
    } else if (message.contains('test') || message.contains('shoot')) {
      return "Test shoots are important for building your portfolio! In the Tests section, you can manage your test shoots, track photographers you've worked with, and organize your portfolio images.";
    } else if (message.contains('calendar') || message.contains('schedule')) {
      return "Your calendar shows all your upcoming jobs, castings, and tests in one place. You can view them by month or in an agenda format. Would you like tips on managing your modeling schedule?";
    } else if (message.contains('payment') ||
        message.contains('money') ||
        message.contains('rate')) {
      return "I can help you track payments and rates! In your jobs section, you can monitor payment status, calculate totals including agency fees and taxes, and keep track of your earnings.";
    } else if (message.contains('agency') || message.contains('agent')) {
      return "Managing agency relationships is crucial! You can track your agencies, agents, and their contact information in the Network section. This helps you stay organized with your professional contacts.";
    } else if (message.contains('portfolio') || message.contains('photo')) {
      return "Your portfolio is your most important tool! You can organize your photos by shoots, track which images work best for different types of jobs, and maintain a professional gallery.";
    } else if (message.contains('help') || message.contains('how')) {
      return "I'm here to help you navigate Model Day! You can ask me about managing jobs, organizing castings, tracking payments, scheduling, or any other aspect of your modeling career. What would you like to know more about?";
    } else if (message.contains('hello') ||
        message.contains('hi') ||
        message.contains('hey')) {
      return "Hello! I'm your Model Day AI assistant. I'm here to help you manage your modeling career more efficiently. You can ask me about jobs, castings, scheduling, payments, or any other questions about using Model Day!";
    } else if (message.contains('thank')) {
      return "You're very welcome! I'm always here to help you succeed in your modeling career. Feel free to ask me anything about managing your bookings, castings, or using Model Day features!";
    } else {
      return "That's an interesting question! As your Model Day AI assistant, I can help you with managing jobs, castings, tests, scheduling, payments, and organizing your modeling career. Could you tell me more specifically what you'd like help with?";
    }
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy_outlined,
                      size: 24,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Container(
            margin: EdgeInsets.only(
              left: isUser ? 56 : 56,
              right: isUser ? 0 : 56,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: !isUser ? Border.all(color: Colors.grey.shade600) : null,
            ),
            child: Text(
              message.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(
          begin: 0.1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy_outlined,
                size: 24,
                color: Colors.blue,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade600),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat()).scaleXY(
          begin: 0.5,
          end: 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentPage: '/ai',
      title: 'Model Day AI Chat',
      child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(color: Colors.grey[900]),
                  child: Row(
                    children: [
                      ui.Button(
                        onPressed: () => Navigator.of(context).pushNamed('/'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Colors.grey[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Back to Dashboard',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black),
                    child: _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _messages.length) {
                                return _buildTypingIndicator();
                              }
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: TextField(
                            controller: _messageController,
                            maxLines: 5,
                            minLines: 1,
                            style: const TextStyle(color: Colors.white),
                            // Add cursor styling for better visibility
                            cursorColor: const Color(0xFFD4AF37), // Gold color
                            cursorWidth: 2.0,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText:
                                  'Ask anything about your modeling data...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _sendMessage,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
