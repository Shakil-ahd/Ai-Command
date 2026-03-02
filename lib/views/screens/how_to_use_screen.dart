import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.bgCard,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back_rounded,
                    color: AppTheme.textPrimary, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'How to Use',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppTheme.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF66BB6A).withValues(alpha: 0.3),
                      AppTheme.bgDeep,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 56,
                    color: const Color(0xFF66BB6A).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    title: '🎤 Voice Commands',
                    subtitle: 'Tap the mic button and speak',
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 12),
                  _CommandCategory(
                    title: 'Open Apps',
                    emoji: '📱',
                    commands: [
                      _CommandExample(
                          en: 'Open Facebook',
                          bn: 'ফেসবুক খোলো',
                          banglish: 'Facebook kholo'),
                      _CommandExample(
                          en: 'Launch WhatsApp',
                          bn: 'হোয়াটসঅ্যাপ চালু করো',
                          banglish: 'WhatsApp open koro'),
                    ],
                    color: const Color(0xFF42A5F5),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  _CommandCategory(
                    title: 'Make Calls',
                    emoji: '📞',
                    commands: [
                      _CommandExample(
                          en: 'Call Mom',
                          bn: 'মম কে কল করো',
                          banglish: 'Mom ke call koro'),
                    ],
                    color: const Color(0xFF66BB6A),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                  _CommandCategory(
                    title: 'Device Controls',
                    emoji: '🔧',
                    commands: [
                      _CommandExample(
                          en: 'Turn on flashlight',
                          bn: 'টর্চ জ্বালাও',
                          banglish: 'Torch on koro'),
                      _CommandExample(
                          en: 'WiFi on',
                          bn: 'ওয়াইফাই চালু',
                          banglish: 'Wifi on koro'),
                      _CommandExample(
                          en: 'Bluetooth off',
                          bn: 'ব্লুটুথ বন্ধ',
                          banglish: 'Bluetooth off koro'),
                      _CommandExample(
                          en: 'Open camera',
                          bn: 'ক্যামেরা খোলো',
                          banglish: 'Camera kholo'),
                    ],
                    color: const Color(0xFFFF6D00),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  _CommandCategory(
                    title: 'YouTube Search',
                    emoji: '▶️',
                    commands: [
                      _CommandExample(
                          en: 'Search sad songs on YouTube',
                          bn: '',
                          banglish: 'YouTube e sad songs search koro'),
                      _CommandExample(
                          en: 'Play funny videos',
                          bn: '',
                          banglish: 'Funny video play koro'),
                    ],
                    color: const Color(0xFFFF4081),
                  ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                  _CommandCategory(
                    title: 'AI Chat',
                    emoji: '🤖',
                    commands: [
                      _CommandExample(
                          en: 'What is the capital of Japan?',
                          bn: '',
                          banglish: 'Japan er capital ki?'),
                      _CommandExample(
                          en: 'Write a poem',
                          bn: '',
                          banglish: 'Ekta kobita lekho'),
                    ],
                    color: const Color(0xFFAB47BC),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  _CommandCategory(
                    title: 'Settings',
                    emoji: '⚙️',
                    commands: [
                      _CommandExample(
                          en: 'Location settings', bn: '', banglish: ''),
                      _CommandExample(
                          en: 'Airplane mode', bn: '', banglish: ''),
                      _CommandExample(
                          en: 'Brightness settings', bn: '', banglish: ''),
                    ],
                    color: const Color(0xFF78909C),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: '💡 Tips',
                    subtitle: 'Get the most out of SakoAI',
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),
                  _TipCard(
                    tip:
                        'You can use English, Bengali (বাংলা), or Banglish - SakoAI understands all!',
                    icon: Icons.language_rounded,
                    color: const Color(0xFF42A5F5),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                  _TipCard(
                    tip:
                        'Device controls like flashlight, WiFi, Bluetooth work without internet!',
                    icon: Icons.wifi_off_rounded,
                    color: const Color(0xFF66BB6A),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  _TipCard(
                    tip:
                        'Tap the speaker icon to toggle voice responses on/off.',
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFFFF6D00),
                  ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1),
                  _TipCard(
                    tip:
                        'Use suggestion chips below the chat for quick commands!',
                    icon: Icons.tips_and_updates_rounded,
                    color: const Color(0xFFE040FB),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CommandExample {
  final String en;
  final String bn;
  final String banglish;
  const _CommandExample(
      {required this.en, required this.bn, required this.banglish});
}

class _CommandCategory extends StatelessWidget {
  final String title;
  final String emoji;
  final List<_CommandExample> commands;
  final Color color;

  const _CommandCategory({
    required this.title,
    required this.emoji,
    required this.commands,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...commands.map((cmd) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CommandChip(text: cmd.en, label: 'EN', color: color),
                    if (cmd.bn.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _CommandChip(
                          text: cmd.bn,
                          label: 'বাং',
                          color: color.withValues(alpha: 0.8)),
                    ],
                    if (cmd.banglish.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _CommandChip(
                          text: cmd.banglish,
                          label: 'BN',
                          color: color.withValues(alpha: 0.6)),
                    ],
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _CommandChip extends StatelessWidget {
  final String text;
  final String label;
  final Color color;
  const _CommandChip(
      {required this.text, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '"$text"',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final IconData icon;
  final Color color;
  const _TipCard({required this.tip, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
