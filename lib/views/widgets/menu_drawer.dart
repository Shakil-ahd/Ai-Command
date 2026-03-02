import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../screens/about_screen.dart';
import '../screens/how_to_use_screen.dart';
import '../screens/theme_selection_screen.dart';
import '../screens/settings_screen.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.bgDeep.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            border: Border(
              right: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _DrawerHeader(),
                Divider(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    children: [
                      _MenuSection(title: 'GENERAL'),
                      _MenuItem(
                        icon: Icons.palette_rounded,
                        title: 'Themes',
                        gradient: const [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              _pageRoute(const ThemeSelectionScreen()));
                        },
                      ).animate().fadeIn(delay: 80.ms).slideX(begin: -0.08),
                      _MenuItem(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        gradient: const [Color(0xFF00BCD4), Color(0xFF0097A7)],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context, _pageRoute(const SettingsScreen()));
                        },
                      ).animate().fadeIn(delay: 120.ms).slideX(begin: -0.08),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'How to Use',
                        gradient: const [Color(0xFF66BB6A), Color(0xFF43A047)],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context, _pageRoute(const HowToUseScreen()));
                        },
                      ).animate().fadeIn(delay: 160.ms).slideX(begin: -0.08),
                      const SizedBox(height: 4),
                      _MenuSection(title: 'INFO'),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About',
                        gradient: const [Color(0xFFFF6D00), Color(0xFFFF9100)],
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context, _pageRoute(const AboutScreen()));
                        },
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.08),
                      _MenuItem(
                        icon: Icons.star_rounded,
                        title: 'Rate Us',
                        gradient: const [Color(0xFFFFD700), Color(0xFFFFB300)],
                        onTap: () {
                          Navigator.pop(context);
                          _showSnack(
                              context, '⭐ Thank you! Rate us on Play Store.');
                        },
                      ).animate().fadeIn(delay: 240.ms).slideX(begin: -0.08),
                      _MenuItem(
                        icon: Icons.share_rounded,
                        title: 'Share App',
                        gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
                        onTap: () {
                          Navigator.pop(context);
                          _showSnack(context, '📤 Share feature coming soon!');
                        },
                      ).animate().fadeIn(delay: 280.ms).slideX(begin: -0.08),
                    ],
                  ),
                ),
                _DrawerFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: AppTheme.bgSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  PageRouteBuilder _pageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(delay: 2000.ms, duration: 2000.ms),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SakoAI',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Your Personal AI Assistant',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.1);
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  const _MenuSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textHint,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: gradient.first.withValues(alpha: 0.1),
          highlightColor: gradient.first.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppTheme.textHint, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'SakoAI v1.0.0',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Made with ❤️ in Bangladesh',
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: AppTheme.textHint.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }
}
