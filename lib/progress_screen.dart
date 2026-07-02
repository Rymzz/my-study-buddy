import 'package:flutter/material.dart';
import 'progress_service.dart';
import 'app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressData? _progress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final data = await ProgressService.load();

    if (!mounted) return;

    setState(() {
      _progress = data;
    });
  }

  String _formatFocusTime(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    }

    final int minutes = seconds ~/ 60;

    if (minutes < 60) {
      return '$minutes min';
    }

    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    return '${hours}h ${remainingMinutes}min';
  }

  Future<void> _resetProgress() async {
    await ProgressService.resetProgress();
    await _loadProgress();
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outline,
          width: 1.5,
        ),
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
                  value,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _constellationCard({
    required String name,
    required int starsRequired,
    required bool unlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.surfaceSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outline,
          width: unlocked ? 2 : 1.3,
        ),
      ),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.auto_awesome : Icons.lock_outline,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? 'Unlocked' : '$starsRequired stars required',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Progress',
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
        child: progress == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/teddy.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            'Your study journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Every session adds up.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.subtext,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        _statCard(
                          title: 'Stars earned',
                          value: '${progress.totalStars}',
                          icon: Icons.star_border,
                        ),

                        const SizedBox(height: 12),

                        _statCard(
                          title: 'Focus sessions completed',
                          value: '${progress.totalSessions}',
                          icon: Icons.timer_outlined,
                        ),

                        const SizedBox(height: 12),

                        _statCard(
                          title: 'Total focus time',
                          value: _formatFocusTime(progress.totalFocusSeconds),
                          icon: Icons.hourglass_bottom,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          'Constellations',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Unlock constellations as you earn more stars.',
                          style: TextStyle(
                            color: AppColors.subtext,
                            fontSize: 14.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        ...ProgressService.constellations.map((constellation) {
                          final String name = constellation['name'];
                          final int requiredStars =
                              constellation['starsRequired'];

                          final bool unlocked =
                              progress.unlockedConstellations.contains(name);

                          return _constellationCard(
                            name: name,
                            starsRequired: requiredStars,
                            unlocked: unlocked,
                          );
                        }),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _resetProgress,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: BorderSide(
                                color: AppColors.outline,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Reset Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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