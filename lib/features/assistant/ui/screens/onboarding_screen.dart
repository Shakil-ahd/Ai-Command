import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/repositories/context_repository.dart';
import 'assistant_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ContextRepository _contextRepository = sl<ContextRepository>();
  int _currentPage = 0;
  String _selectedLang = 'bn'; // 'bn' details to bangla since user prefers it

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    await _contextRepository.setPreferredLanguage(_selectedLang);
    await _contextRepository.setOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AssistantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text('Skip',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                children: [
                  _buildPage(
                    title: 'Welcome to SakoAI',
                    description:
                        'Control your phone completely by voice or text.\n\n📱 Launch Apps & Call Contacts\n🌐 Search Web & YouTube\n🔦 Control Flashlight\n⚙️ Manage Wi-Fi & Bluetooth\n📷 Open Camera',
                    icon: Icons.auto_awesome,
                  ),
                  _buildLanguageSelectionPage(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 32),
          Text(
            'Language / ভাষা',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'আপনি কি বাংলায় কথা বলবেন নাকি English এ? \nWhich language do you prefer to speak?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _LanguageCard(
                  title: 'English',
                  isSelected: _selectedLang == 'en',
                  onTap: () => setState(() => _selectedLang = 'en'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LanguageCard(
                  title: 'বাংলা',
                  isSelected: _selectedLang == 'bn',
                  onTap: () => setState(() => _selectedLang = 'bn'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
      {required String title,
      required String description,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
            child: Icon(icon, size: 80, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              2,
              (index) => Container(
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppTheme.primaryColor
                      : AppTheme.textHint,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              if (_currentPage == 1) {
                _finishOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            child: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
