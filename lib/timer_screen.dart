import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'progress_service.dart';
import 'app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int _sessionDurationSeconds = 1800; // Remets 1800 plus tard
  int _secs = _sessionDurationSeconds;

  Timer? _timer;
  bool _running = false;

  int _stars = 0;
  int _sessions = 0;
  List<String> _unlockedConstellations = [];

  final Random _random = Random();

  final List<String> _quotes = [
    "Don't wish for it, work for it.",
    "Dream big. Work hard. Stay focused.",
    "Remember why you started.",
    "One step at a time.",
    "Discipline today, results tomorrow.",
    "Success is a decision.",
    "Consistency beats motivation.",
    "Trust the process.",
    "Keep going. You are building something.",
  ];

  String get _randomQuote => _quotes[_random.nextInt(_quotes.length)];

  double get _timerProgress {
    final elapsed = _sessionDurationSeconds - _secs;
    return elapsed / _sessionDurationSeconds;
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressService.load();

    if (!mounted) return;

    setState(() {
      _stars = progress.totalStars;
      _sessions = progress.totalSessions;
      _unlockedConstellations = progress.unlockedConstellations;
    });
  }

  Future<void> _handleSessionReward() async {
    final progress = await ProgressService.completeSession(
      durationSeconds: _sessionDurationSeconds,
    );

    if (!mounted) return;

    setState(() {
      _stars = progress.totalStars;
      _sessions = progress.totalSessions;
      _unlockedConstellations = progress.unlockedConstellations;
    });

    if (progress.newConstellation != null) {
      _showConstellationPopup(progress.newConstellation!);
    } else {
      _showStarPopup();
    }
  }

  Map<String, dynamic>? _nextConstellation() {
    for (final constellation in ProgressService.constellations) {
      final String name = constellation['name'];

      if (!_unlockedConstellations.contains(name)) {
        return constellation;
      }
    }

    return null;
  }

  int _starsToNextConstellation() {
    final next = _nextConstellation();

    if (next == null) return 0;

    final int required = next['starsRequired'];
    final int remaining = required - _stars;

    if (remaining < 0) return 0;

    return remaining;
  }

  double _constellationProgressValue() {
    final next = _nextConstellation();

    if (next == null) return 1;

    final int required = next['starsRequired'];

    if (required == 0) return 1;

    final value = _stars / required;

    if (value > 1) return 1;

    return value;
  }

  String _fmt(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _start() {
    if (_running) return;

    setState(() {
      _running = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secs <= 0) {
        timer.cancel();

        setState(() {
          _running = false;
          _timer = null;
        });

        _handleSessionReward();
        return;
      }

      setState(() {
        _secs--;
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _running = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _secs = _sessionDurationSeconds;
      _running = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showStarPopup() {
    final String quote = _randomQuote;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (ctx) {
        return _RewardSheet(
          title: 'Session complete!',
          subtitle: 'You just earned a new star.',
          imagePath: 'assets/images/happyTeddy.png',
          quote: quote,
          buttonText: 'Start again',
          onPressed: () {
            Navigator.pop(ctx);
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        _reset();
      }
    });
  }

  void _showConstellationPopup(String constellationName) {
    final String quote = _randomQuote;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (ctx) {
        return _RewardSheet(
          title: 'New constellation!',
          subtitle: 'You unlocked $constellationName.',
          imagePath: 'assets/images/star.png',
          quote: quote,
          buttonText: 'Amazing!',
          onPressed: () {
            Navigator.pop(ctx);
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        _reset();
      }
    });
  }

  Widget _smallStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outline,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextConstellationCard() {
    final next = _nextConstellation();

    if (next == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outline,
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'All constellations unlocked',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You completed this little sky.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      );
    }

    final String name = next['name'];
    final int requiredStars = next['starsRequired'];
    final int remaining = _starsToNextConstellation();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline,
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Next constellation',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            name,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            remaining == 0
                ? 'Ready to unlock.'
                : '$remaining more star${remaining == 1 ? '' : 's'} to unlock.',
            style: TextStyle(
              color: AppColors.subtext,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: _constellationProgressValue(),
              backgroundColor: AppColors.surfaceSoft,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$_stars / $requiredStars stars',
            style: TextStyle(
              color: AppColors.subtext,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerCircle(bool isTablet) {
    final double size = isTablet ? 270 : 260;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size - 26,
            height: size - 26,
            child: CircularProgressIndicator(
              value: _timerProgress,
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _running
                    ? 'assets/images/focusedTeddy.png'
                    : 'assets/images/teddy.png',
                width: isTablet ? 70 : 64,
                height: isTablet ? 70 : 64,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 12),

              Text(
                _fmt(_secs),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 54 : 52,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _running ? 'Stay with it' : 'Ready to begin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.subtext,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButtons(bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: Text(
              _running ? 'Session in progress' : 'Begin Session',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pause,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: BorderSide(
                    color: AppColors.outline,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Pause',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: BorderSide(
                    color: AppColors.outline,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _header(bool isTablet) {
    return Column(
      children: [
        Text(
          'FOCUS TIMER',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
            color: AppColors.subtext,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'One quiet session at a time.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text,
            fontSize: isTablet ? 25 : 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _header(false),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _smallStat(
                      value: '$_stars',
                      label: 'Stars',
                      icon: Icons.star_border,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _smallStat(
                      value: '$_sessions',
                      label: 'Sessions',
                      icon: Icons.timer_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _timerCircle(false),

              const SizedBox(height: 22),

              Text(
                _running ? 'In progress...' : 'Ready to study',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  color: AppColors.subtext,
                ),
              ),

              const SizedBox(height: 24),

              _controlButtons(false),

              const SizedBox(height: 20),

              _nextConstellationCard(),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Column(
            children: [
              _header(true),

              const SizedBox(height: 18),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _timerCircle(true),

                          const SizedBox(height: 18),

                          Text(
                            _running ? 'In progress...' : 'Ready to study',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.5,
                              color: AppColors.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 34),

                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _smallStat(
                                  value: '$_stars',
                                  label: 'Stars',
                                  icon: Icons.star_border,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _smallStat(
                                  value: '$_sessions',
                                  label: 'Sessions',
                                  icon: Icons.timer_outlined,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _controlButtons(true),

                          const SizedBox(height: 18),

                          _nextConstellationCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isTablet) {
    if (isTablet) {
      return _buildTabletContent();
    }

    return _buildPhoneContent();
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
          'Study Session',
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
        child: _buildContent(isTablet),
      ),
    );
  }
}

class _RewardSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final String quote;
  final String buttonText;
  final VoidCallback onPressed;

  const _RewardSheet({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.quote,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
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

              const SizedBox(height: 26),

              Image.asset(
                imagePath,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 18),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.outline,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  '"$quote"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 15,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
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
  }
}