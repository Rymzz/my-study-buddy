import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'timer_screen.dart';
import 'motivation_screen.dart';
import 'mood_checkin_screen.dart';
import 'progress_screen.dart';
import 'app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.outline,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.subtext,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.subtext,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.outline,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, Object>> _menuItems(BuildContext context) {
    return [
      {
        'title': 'Focus Timer',
        'subtitle': 'Start a focus session and earn stars.',
        'icon': Icons.timer_outlined,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TimerScreen(),
            ),
          );
        },
      },
      {
        'title': 'Motivation',
        'subtitle': 'Get a gentle boost when you need it.',
        'icon': Icons.auto_awesome,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MotivationScreen(),
            ),
          );
        },
      },
      {
        'title': 'Mood Check-In',
        'subtitle': 'Pause and check in with yourself.',
        'icon': Icons.favorite_border,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MoodCheckInScreen(),
            ),
          );
        },
      },
      {
        'title': 'My Progress',
        'subtitle': 'View your stars, sessions, and constellations.',
        'icon': Icons.star_border,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProgressScreen(),
            ),
          );
        },
      },
    ];
  }

  Widget _buildResponsiveMenu(BuildContext context, bool isTablet) {
    final menuItems = _menuItems(context);

    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  mainAxisExtent: 175,
),
        itemBuilder: (context, index) {
          final item = menuItems[index];

          return _buildSquareMenuCard(
            context: context,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            icon: item['icon'] as IconData,
            onTap: item['onTap'] as VoidCallback,
          );
        },
      );
    }

    return Column(
      children: [
        _buildMenuCard(
          context: context,
          title: menuItems[0]['title'] as String,
          subtitle: menuItems[0]['subtitle'] as String,
          icon: menuItems[0]['icon'] as IconData,
          onTap: menuItems[0]['onTap'] as VoidCallback,
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context: context,
          title: menuItems[1]['title'] as String,
          subtitle: menuItems[1]['subtitle'] as String,
          icon: menuItems[1]['icon'] as IconData,
          onTap: menuItems[1]['onTap'] as VoidCallback,
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context: context,
          title: menuItems[2]['title'] as String,
          subtitle: menuItems[2]['subtitle'] as String,
          icon: menuItems[2]['icon'] as IconData,
          onTap: menuItems[2]['onTap'] as VoidCallback,
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context: context,
          title: menuItems[3]['title'] as String,
          subtitle: menuItems[3]['subtitle'] as String,
          icon: menuItems[3]['icon'] as IconData,
          onTap: menuItems[3]['onTap'] as VoidCallback,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 620 : 560,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 24 : 20,
              ),
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 8 : 10),

                  Image.asset(
                    'assets/images/teddy.png',
                    width: isTablet ? 150 : 130,
                    height: isTablet ? 150 : 130,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'My Study Buddy',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: isTablet ? 40 : 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'What do you need today?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 17 : 16,
                      color: AppColors.subtext,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _buildResponsiveMenu(context, isTablet),

                  const SizedBox(height: 30),

                  Text(
                    'One small step is still progress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.subtext,
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