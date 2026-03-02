import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../features/assistant/bloc/assistant_bloc.dart';
import '../../features/assistant/bloc/assistant_event_state.dart';
import '../../features/assistant/bloc/theme_bloc.dart';
import '../../features/assistant/bloc/theme_event_state.dart';
import '../../features/assistant/bloc/connectivity_bloc.dart';
import '../../features/assistant/bloc/connectivity_event_state.dart';
import '../widgets/shimmer_loading.dart';
import 'theme_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                'Settings',
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
                      const Color(0xFF00BCD4).withValues(alpha: 0.3),
                      AppTheme.bgDeep,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.settings_rounded,
                    size: 56,
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<ConnectivityBloc, ConnectivityState>(
              builder: (context, connState) {
                if (!connState.isConnected) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const ShimmerLoading(
                      itemCount: 4,
                      type: ShimmerType.list,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsSection(title: 'APPEARANCE'),
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, themeState) {
                          return _SettingsTile(
                            icon: Icons.palette_rounded,
                            title: 'Theme',
                            subtitle: themeState.currentTheme.name,
                            trailingWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  themeState.currentTheme.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded,
                                    color: AppTheme.textHint, size: 20),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ThemeSelectionScreen(),
                                ),
                              );
                            },
                            gradient: const [
                              Color(0xFFE040FB),
                              Color(0xFF7C4DFF)
                            ],
                          );
                        },
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      _SettingsSection(title: 'ASSISTANT'),
                      BlocBuilder<AssistantBloc, AssistantState>(
                        builder: (context, state) {
                          return _SettingsTile(
                            icon: Icons.volume_up_rounded,
                            title: 'Voice Response',
                            subtitle: state.ttsEnabled
                                ? 'SakoAI will speak responses'
                                : 'SakoAI will only show text',
                            trailingWidget: Switch(
                              value: state.ttsEnabled,
                              onChanged: (_) {
                                context
                                    .read<AssistantBloc>()
                                    .add(TtsToggledEvent());
                              },
                              activeTrackColor: AppTheme.primaryColor,
                            ),
                            onTap: () {
                              context
                                  .read<AssistantBloc>()
                                  .add(TtsToggledEvent());
                            },
                            gradient: const [
                              Color(0xFF66BB6A),
                              Color(0xFF43A047)
                            ],
                          );
                        },
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      _SettingsSection(title: 'DATA'),
                      _SettingsTile(
                        icon: Icons.delete_sweep_rounded,
                        title: 'Clear Chat History',
                        subtitle: 'Delete all messages',
                        trailingWidget: Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textHint, size: 20),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.bgCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                'Clear Chat?',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              content: Text(
                                'This will delete all chat messages. This action cannot be undone.',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.outfit(
                                        color: AppTheme.textSecondary),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<AssistantBloc>()
                                        .add(ClearChatHistoryEvent());
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '🗑️ Chat history cleared!',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: AppTheme.bgSurface,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                  child: Text(
                                    'Clear',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        gradient: [
                          AppTheme.errorColor,
                          const Color(0xFFD32F2F)
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      _SettingsTile(
                        icon: Icons.refresh_rounded,
                        title: 'Refresh App List',
                        subtitle: 'Re-scan installed apps',
                        trailingWidget: Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textHint, size: 20),
                        onTap: () {
                          context.read<AssistantBloc>().add(RefreshAppsEvent());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🔄 Refreshing app list...',
                                style: GoogleFonts.outfit(color: Colors.white),
                              ),
                              backgroundColor: AppTheme.bgSurface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        gradient: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          'SakoAI v1.0.0',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textHint,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailingWidget;
  final VoidCallback onTap;
  final List<Color> gradient;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingWidget,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: gradient.first.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                trailingWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
