import 'package:flutter/material.dart';
import 'homepage.dart';
import 'chatbox.dart';
import 'community.dart';
import 'profile.dart';
import 'wellness_single_page.dart'; // 👈 add this import

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 👇 now 5 pages, with Wellness page in the middle
  final List<Widget> _pages = const [
    HomePage(),
    ChatboxPage(),
    WellnessSinglePage(),// 👈 attached here
    CommunityPage(),
    ProfilePage(),
  ];

  final List<String> _labels = [
    "Home",
    "Chat",
    "Wellness", // 👈 renamed to match the single-page wellness section
    "Community",
    "Profile",
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.chat_bubble_rounded,
    Icons.self_improvement_rounded,
    Icons.groups_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.teal.shade600,
            unselectedItemColor: Colors.grey.shade500,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            backgroundColor: Colors.white,
            onTap: (index) => setState(() => _currentIndex = index),
            items: List.generate(_labels.length, (index) {
              final isActive = _currentIndex == index;
              return BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.teal.shade50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _icons[index],
                    color: isActive ? Colors.teal.shade600 : Colors.grey.shade500,
                  ),
                ),
                label: _labels[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}