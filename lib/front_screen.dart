import 'package:flutter/material.dart';

class FrontScreen extends StatelessWidget {
  const FrontScreen({super.key});

  // Mock Google Sign-In (no Firebase, just navigation)
  Future<void> signInWithGoogle(BuildContext context) async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      // or '/homepage' if you want to go straight home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('IMAGE/front_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Logo
                  Center(
                    child: Image.asset(
                      'IMAGE/mind_bloom_logo.png',
                      height: 280,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Intro Text
                  const Text(
                    "Your safe space for\nmind and soul.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Guided meditations, mood tracking, and\ncommunity support — all in one app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 30),

                  // Email Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.email, size: 24),
                      label: const Text("Log in with Email", style: TextStyle(fontSize: 16)),
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text("or", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),

                  // Google Login Button (Mock)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                      label: const Text("Continue with Google"),
                      onPressed: () => signInWithGoogle(context), // dummy
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Apple Login Button (visual only)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.apple, size: 28, color: Colors.white),
                      label: const Text("Continue with Apple"),
                      onPressed: () {}, // inactive
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Terms & Conditions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "By continuing, you agree to Mind Bloom’s Terms & Conditions and Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
