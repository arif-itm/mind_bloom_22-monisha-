import 'package:flutter/material.dart';

class EmoCareChat extends StatefulWidget {
  const EmoCareChat({super.key});

  @override
  State<EmoCareChat> createState() => _EmoCareChatState();
}

class _EmoCareChatState extends State<EmoCareChat> {
  final List<Map<String, String>> _messages = [
    {"role": "user", "text": "I feel very low today"},
    {
      "role": "ai",
      "text":
      "I'm really sorry you're feeling that way. Would you like to talk more about it or try a calming exercise?"
    },
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "text": _controller.text.trim()});
      _controller.clear();

      // Simulate AI reply
      _messages.add({
        "role": "ai",
        "text":
        "I hear you. It’s okay to feel this way. Let’s focus on your breathing for a moment—slow, deep breaths."
      });
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUser = message["role"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal[100] : Colors.teal[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message["text"]!,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.teal[50],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black54),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.teal),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3, // Chat tab active
      onTap: (index) {
        // Handle navigation
        if (index == 0) {
          Navigator.pushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/community');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/meditation');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/chat');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
        BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement), label: "Meditation"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Text("🧠", style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              "EmoCare AI Chat",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  _buildMessage(_messages[index]),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }
}