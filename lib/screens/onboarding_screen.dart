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

  List<_SlideData> get _slides => [
    const _SlideData(icon: Icons.timer_outlined, titleKey: 'onboardingTitle1', descKey: 'onboardingDesc1'),
    const _SlideData(icon: Icons.park_outlined, titleKey: 'onboardingTitle2', descKey: 'onboardingDesc2'),
    const _SlideData(icon: Icons.star_rounded, titleKey: 'onboardingTitle3', descKey: 'onboardingDesc3'),
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
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(AppStrings.t(context, 'skip'), style: const TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final slide = _slides[i];
                  final slideColor = switch (i) {
                    0 => primary,
                    1 => Theme.of(context).colorScheme.secondary,
                    _ => AppColors.coin,
                  };
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: slideColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(slide.icon, size: 48, color: slideColor),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          AppStrings.t(context, slide.titleKey),
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge(),
                        ),
                        const SizedBox(height: 12),
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
                  width: _page == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? primary : primary.withValues(alpha: 0.2),
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
                height: 50,
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
    );
  }
}

class _SlideData {
  final IconData icon;
  final String titleKey;
  final String descKey;

  const _SlideData({
    required this.icon,
    required this.titleKey,
    required this.descKey,
  });
}
