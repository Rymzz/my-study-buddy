import 'package:flutter/material.dart';
import 'app_theme.dart';

class MotivationScreen extends StatelessWidget {
  const MotivationScreen({super.key});

  List<_MotivationOption> get _options {
    return const [
      _MotivationOption(
        title: 'I can’t start',
        subtitle: 'Get a tiny first step.',
        icon: Icons.play_arrow_rounded,
        message:
            'You do not need to feel ready before starting. Motivation often comes after the first small action.',
        action:
            'Open your notes and study for only 5 minutes. No pressure to finish everything.',
      ),
      _MotivationOption(
        title: 'I feel overwhelmed',
        subtitle: 'Break things down gently.',
        icon: Icons.spa_outlined,
        message:
            'You do not have to solve the whole problem right now. You only need to choose the next small piece.',
        action:
            'Pick one tiny task: one page, one exercise, one paragraph, or one concept.',
      ),
      _MotivationOption(
        title: 'I feel discouraged',
        subtitle: 'Remember your progress.',
        icon: Icons.favorite_border,
        message:
            'A difficult moment does not erase your effort. You are still building discipline, one session at a time.',
        action:
            'Write down one thing you already did today, even if it feels small.',
      ),
      _MotivationOption(
        title: 'I need confidence',
        subtitle: 'Get a calm reminder.',
        icon: Icons.auto_awesome,
        message:
            'You do not need to feel perfectly confident to begin. Confidence grows when you keep showing up.',
        action:
            'Start with the easiest part first. Let yourself build momentum slowly.',
      ),
    ];
  }

  void _showMotivationMessage({
    required BuildContext context,
    required String title,
    required String message,
    required String action,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Image.asset(
                    'assets/images/teddy.png',
                    width: 135,
                    height: 135,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.outline,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tiny action',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 15.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'I can do this',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationSquare({
    required BuildContext context,
    required _MotivationOption option,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: () {
        _showMotivationMessage(
          context: context,
          title: option.title,
          message: option.message,
          action: option.action,
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outline,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? 62 : 56,
              height: isTablet ? 62 : 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                option.icon,
                color: AppColors.primary,
                size: isTablet ? 32 : 29,
              ),
            ),

            SizedBox(height: isTablet ? 18 : 14),

            Text(
              option.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontSize: isTablet ? 18 : 15.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              option.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: isTablet ? 13.5 : 12.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(BuildContext context, bool isTablet) {
    final options = _options;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: isTablet ? 18 : 14,
        mainAxisSpacing: isTablet ? 18 : 14,
        mainAxisExtent: isTablet ? 185 : 165,
      ),
      itemBuilder: (context, index) {
        return _buildMotivationSquare(
          context: context,
          option: options[index],
          isTablet: isTablet,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Motivation',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: AppColors.primary,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 720 : 560,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 18 : 20,
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/teddy.png',
                    width: isTablet ? 125 : 115,
                    height: isTablet ? 125 : 115,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Need a little push?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: isTablet ? 31 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Choose what feels closest to you right now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontSize: isTablet ? 16 : 15.5,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: isTablet ? 26 : 24),

                  _buildOptionsGrid(context, isTablet),

                  SizedBox(height: isTablet ? 26 : 24),

                  Text(
                    'Small steps still count.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MotivationOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String message;
  final String action;

  const _MotivationOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.message,
    required this.action,
  });
}