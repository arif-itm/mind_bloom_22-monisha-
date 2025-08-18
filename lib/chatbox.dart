import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_service.dart';

class ChatboxPage extends StatefulWidget {
  const ChatboxPage({super.key});

  @override
  State<ChatboxPage> createState() => _ChatboxPageState();
}

class _ChatboxPageState extends State<ChatboxPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  /// We store messages as { "role": "user"/"assistant", "content": "..." }
  final List<Map<String, String>> _history = [];

  bool _isSending = false;
  bool _warmStarted = false;

  static const _prefsKey = 'emo_chat_history_v1';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw);
      _history.clear();
      _history.addAll(decoded.map((e) => {
        'role': e['role'] as String,
        'content': e['content'] as String,
      }));
    }

    // Add a gentle first message if empty
    if (_history.isEmpty) {
      _history.add({
        'role': 'assistant',
        'content':
        'Hi, I’m EmoCare 💙\nThis is a safe space. How are you feeling today?',
      });
      await _saveHistory();
    }

    setState(() {
      _warmStarted = true;
    });
    _scrollToBottom();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_history));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    setState(() {
      _history.add({'role': 'user', 'content': trimmed});
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();
    await _saveHistory();

    try {
      // Build full context with a supportive system prompt
      final List<Map<String, String>> payload = [
        {
          'role': 'system',
          'content':
          'You are EmoCare, a warm, validating mental-wellness companion. '
              'You listen with empathy, never diagnose, and offer gentle tips like breathing, grounding, journaling, or small, doable actions. '
              'Keep replies short, kind, and non-judgmental. If crisis is mentioned, recommend contacting local emergency services or a trusted person.'
        },
        ..._history,
      ];

      final reply = await ChatService.send(payload);

      setState(() {
        _history.add({'role': 'assistant', 'content': reply});
        _isSending = false;
      });
      _scrollToBottom();
      await _saveHistory();
    } catch (e) {
      setState(() {
        _isSending = false;
        _history.add({
          'role': 'assistant',
          'content':
          'Sorry, I had trouble connecting. Please check your internet and try again. 🌱',
        });
      });
      _scrollToBottom();
      await _saveHistory();
    }
  }

  Widget _bubble(Map<String, String> m) {
    final isUser = m['role'] == 'user';
    final text = m['content'] ?? '';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFDFF5E1) : const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(6),
            bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Color(0xFF2F2F2F),
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Dot(), SizedBox(width: 4),
            _Dot(), SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: No bottomNavigationBar here — this should sit inside your MainNavigation.
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFF0FFF4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: const [
                    Icon(Icons.favorite_rounded, color: Colors.teal, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'EmoCare Chat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                  ],
                ),
              ),

              // Chat list
              Expanded(
                child: _warmStarted
                    ? ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _history.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isSending && index == _history.length) {
                      return _typingIndicator();
                    }
                    return _bubble(_history[index]);
                  },
                )
                    : const SizedBox(),
              ),

              // Input bar
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                          decoration: const InputDecoration(
                            hintText: 'Share what’s on your mind…',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _sendMessage(_controller.text),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Little animated typing dots
class _Dot extends StatefulWidget {
  const _Dot({Key? key}) : super(key: key);

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  late final Animation<double> _a =
  Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: const CircleAvatar(radius: 3, backgroundColor: Color(0xFF1E3A8A)),
    );
  }
}