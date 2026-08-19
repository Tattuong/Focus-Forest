import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_strings.dart';
import '../providers/focus_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/app_ui.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _fade;
  late final AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _slide = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final shop = context.read<ShopProvider>();
    final focus = context.read<FocusProvider>();
    await shop.init();
    focus.bindShop(shop);
    await focus.load();
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('ff_onboarding_seen') ?? false;

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    final next = seenOnboarding ? const MainShell() : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fade.dispose();
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final preset = shop.activeTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [preset.darkBackground, Color.lerp(preset.darkBackground, preset.primary, 0.35)!]
                : [preset.darkBackground, preset.primary, preset.primaryLight],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
                    CurvedAnimation(parent: _slide, curve: Curves.easeOutCubic),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, child) => Transform.scale(
                            scale: 1.0 + _pulse.value * 0.035,
                            child: child,
                          ),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.28),
                                  blurRadius: 48,
                                  spreadRadius: -8,
                                ),
                              ],
                            ),
                            child: Image.asset('assets/logo.png', width: 140, height: 140, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          AppStrings.t(context, 'appName'),
                          style: AppTypography.displayLarge(color: Colors.white).copyWith(
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.t(context, 'appTagline'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 52),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            color: Colors.white.withValues(alpha: 0.92),
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.t(context, 'splashLoading'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
