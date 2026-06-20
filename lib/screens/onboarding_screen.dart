import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/app_ui.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _slides = [
    _SlideData(icon: Icons.timer_outlined, titleKey: 'onboardingTitle1', descKey: 'onboardingDesc1', color: AppColors.primary),
    _SlideData(icon: Icons.forest_outlined, titleKey: 'onboardingTitle2', descKey: 'onboardingDesc2', color: AppColors.accent),
    _SlideData(icon: Icons.stars_rounded, titleKey: 'onboardingTitle3', descKey: 'onboardingDesc3', color: AppColors.coin),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ff_onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppDecorations.meshBackground(
        isDark: isDark,
        backgroundGradient: AppColors.heroGradient,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(AppStrings.t(context, 'skip')),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final slide = _slides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: slide.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(slide.icon, size: 56, color: slide.color),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            AppStrings.t(context, slide.titleKey),
                            textAlign: TextAlign.center,
                            style: AppTypography.titleLarge(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.t(context, slide.descKey),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15, height: 1.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_page < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _finish();
                      }
                    },
                    child: Text(
                      _page < _slides.length - 1
                          ? AppStrings.t(context, 'next')
                          : AppStrings.t(context, 'getStarted'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String titleKey;
  final String descKey;
  final Color color;

  const _SlideData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.color,
  });
}
