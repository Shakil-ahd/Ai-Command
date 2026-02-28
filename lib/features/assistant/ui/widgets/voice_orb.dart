import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Decorative pulsing orb (imported but optional for splash/header use).
class VoiceOrb extends StatefulWidget {
  final bool isActive;
  final double size;

  const VoiceOrb({super.key, this.isActive = false, this.size = 80});

  @override
  State<VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends State<VoiceOrb> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _rotateCtrl]),
      builder: (_, __) {
        final pulse = _pulseCtrl.value;
        final rotate = _rotateCtrl.value * 2 * math.pi;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              if (widget.isActive)
                Container(
                  width: widget.size + 20 + pulse * 20,
                  height: widget.size + 20 + pulse * 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          AppTheme.accentColor.withOpacity(0.2 - pulse * 0.1),
                      width: 2,
                    ),
                  ),
                ),

              // Inner orb
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    transform: GradientRotation(rotate),
                    colors: const [
                      Color(0xFF6C63FF),
                      Color(0xFF00D4FF),
                      Color(0xFF6C63FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(
                          widget.isActive ? 0.5 + pulse * 0.3 : 0.3),
                      blurRadius: widget.isActive ? 30 + pulse * 10 : 15,
                      spreadRadius: widget.isActive ? 5 : 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.isActive ? Icons.mic_rounded : Icons.auto_awesome,
                    color: Colors.white,
                    size: widget.size * 0.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
