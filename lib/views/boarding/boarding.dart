import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/views/authentication/login/login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/home1.png",
      "text": "We Provide\nProfessional Home\nservices at a very\nfriendly price"
    },
    {
      "image": "assets/images/home1.png",
      "text": "Easily Book\nCleaners & Services\nin a Few Clicks"
    },
    {
      "image": "assets/images/home1.png",
      "text": "Your Satisfaction\nIs Our Priority"
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.yellow[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EC),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = onboardingData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 120,
                          backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(item["image"]!),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        item["text"]!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => _buildIndicator(index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
