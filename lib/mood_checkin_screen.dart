import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'motivation_screen.dart';
import 'app_theme.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;

  _MoodConfig? _selectedMood;
  _ExerciseOption? _selectedExercise;

  double _beforeIntensity = 5;
  double _afterIntensity = 5;

  Timer? _breathingTimer;

  static const int _breathingRounds = 3;
  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 2;
  static const int _exhaleSeconds = 6;
  static const int _breathingCycleSeconds =
      _inhaleSeconds + _holdSeconds + _exhaleSeconds;
  static const int _totalBreathingSeconds =
      _breathingRounds * _breathingCycleSeconds;

  // Ajustement optique du Teddy dans le cercle de respiration.
  // Si ton PNG a du transparent autour, c'est normal de devoir compenser un peu.
  // x négatif = gauche, x positif = droite. y négatif = haut, y positif = bas.
  static const Offset _breathingTeddyOffset = Offset(-5, -2);

  int _breathingSeconds = _totalBreathingSeconds;
  bool _breathingStarted = false;

  int _bodyScanIndex = 0;
  bool _bodyScanFinished = false;

  final TextEditingController _journalController = TextEditingController();
  final TextEditingController _smallStepController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final List<_MoodConfig> _moods = [
    _MoodConfig(
      label: 'Focused',
      assetPath: 'assets/images/focusedTeddy.png',
      haloColor: const Color(0xFF8DBBFF),
      subtitle: 'You feel clear and ready.',
      checkInQuestion: 'What do you want to focus on first?',
      finalMessage:
          'This focus is valuable. You do not need to do everything — just use this clear moment gently.',
      preferredAction: _FinalAction.focus,
      exercises: const [
        _ExerciseOption(
          title: 'Set an intention',
          subtitle: 'Choose one clear thing to work on.',
          icon: Icons.flag_outlined,
          type: _ExerciseType.intention,
        ),
        _ExerciseOption(
          title: 'Protect your focus',
          subtitle: 'Remove one distraction before starting.',
          icon: Icons.shield_outlined,
          type: _ExerciseType.focusShield,
        ),
        _ExerciseOption(
          title: 'Quick journal',
          subtitle: 'Write what feels clear right now.',
          icon: Icons.edit_note,
          type: _ExerciseType.journal,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Calm',
      assetPath: 'assets/images/calmTeddy.png',
      haloColor: const Color(0xFFB9DCCB),
      subtitle: 'You feel steady and peaceful.',
      checkInQuestion: 'What would help you keep this calm feeling?',
      finalMessage:
          'Calm is not something to rush through. You can carry this softness into whatever comes next.',
      preferredAction: _FinalAction.focus,
      exercises: const [
        _ExerciseOption(
          title: 'Savor the calm',
          subtitle: 'Notice what feels peaceful.',
          icon: Icons.self_improvement,
          type: _ExerciseType.savoring,
        ),
        _ExerciseOption(
          title: 'Breathing circle',
          subtitle: 'Follow 3 guided rounds with Teddy.',
          icon: Icons.air,
          type: _ExerciseType.breathing,
        ),
        _ExerciseOption(
          title: 'Gratitude journal',
          subtitle: 'Write three things you appreciate.',
          icon: Icons.favorite_border,
          type: _ExerciseType.gratitude,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Tired',
      assetPath: 'assets/images/tiredTeddy.png',
      haloColor: const Color(0xFFD8C4F0),
      subtitle: 'Your energy feels low.',
      checkInQuestion: 'Is this tiredness physical, mental, or emotional?',
      finalMessage:
          'Tiredness is information. You are allowed to move slowly instead of forcing yourself to act like you are fine.',
      preferredAction: _FinalAction.motivation,
      exercises: const [
        _ExerciseOption(
          title: 'Body check',
          subtitle: 'Notice what your body is asking for.',
          icon: Icons.accessibility_new,
          type: _ExerciseType.bodyScan,
        ),
        _ExerciseOption(
          title: 'Gentle reset',
          subtitle: 'Pick the smallest possible next step.',
          icon: Icons.spa_outlined,
          type: _ExerciseType.tinyStep,
        ),
        _ExerciseOption(
          title: 'Energy journal',
          subtitle: 'Write what drained you today.',
          icon: Icons.edit_note,
          type: _ExerciseType.journal,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Anxious',
      assetPath: 'assets/images/anxiousTeddy.png',
      haloColor: const Color(0xFFAEC9FF),
      subtitle: 'Your mind may feel loud or unsafe.',
      checkInQuestion: 'What feels most urgent in your mind right now?',
      finalMessage:
          'Anxiety can make everything feel urgent. You came back to the present moment, and that already matters.',
      preferredAction: _FinalAction.motivation,
      exercises: const [
        _ExerciseOption(
          title: 'Breathing circle',
          subtitle: 'Follow 3 guided rounds with Teddy.',
          icon: Icons.circle_outlined,
          type: _ExerciseType.breathing,
        ),
        _ExerciseOption(
          title: '5-4-3-2-1 grounding',
          subtitle: 'Come back to the present moment.',
          icon: Icons.touch_app_outlined,
          type: _ExerciseType.grounding,
        ),
        _ExerciseOption(
          title: 'Worry dump',
          subtitle: 'Put the anxious thoughts somewhere.',
          icon: Icons.edit_note,
          type: _ExerciseType.journal,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Overwhelmed',
      assetPath: 'assets/images/overwhelmedTeddy.png',
      haloColor: const Color(0xFFA9D8E8),
      subtitle: 'Everything may feel like too much.',
      checkInQuestion: 'What feels too heavy to hold all at once?',
      finalMessage:
          'You do not have to solve the whole thing right now. Making the moment smaller is already a reset.',
      preferredAction: _FinalAction.motivation,
      exercises: const [
        _ExerciseOption(
          title: 'Brain dump',
          subtitle: 'Empty the mental clutter.',
          icon: Icons.cloud_outlined,
          type: _ExerciseType.brainDump,
        ),
        _ExerciseOption(
          title: 'Choose one thing',
          subtitle: 'Turn chaos into one next step.',
          icon: Icons.filter_1,
          type: _ExerciseType.tinyStep,
        ),
        _ExerciseOption(
          title: 'Grounding reset',
          subtitle: 'Slow down your body first.',
          icon: Icons.spa_outlined,
          type: _ExerciseType.grounding,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Unmotivated',
      assetPath: 'assets/images/unmotivatedTeddy.png',
      haloColor: const Color(0xFFE3D5A8),
      subtitle: 'You may feel disconnected or stuck.',
      checkInQuestion:
          'Do you feel bored, drained, discouraged, or disconnected?',
      finalMessage:
          'Being unmotivated does not mean you are lazy. Sometimes you need meaning, softness, or a smaller beginning.',
      preferredAction: _FinalAction.motivation,
      exercises: const [
        _ExerciseOption(
          title: 'Find the reason',
          subtitle: 'Reconnect with why this matters.',
          icon: Icons.psychology_outlined,
          type: _ExerciseType.findReason,
        ),
        _ExerciseOption(
          title: 'Two-minute start',
          subtitle: 'Make beginning less intimidating.',
          icon: Icons.play_arrow_rounded,
          type: _ExerciseType.tinyStep,
        ),
        _ExerciseOption(
          title: 'No-pressure journal',
          subtitle: 'Write what feels stuck.',
          icon: Icons.edit_note,
          type: _ExerciseType.journal,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Frustrated',
      assetPath: 'assets/images/frustratedTeddy.png',
      haloColor: const Color(0xFFFFC8AE),
      subtitle: 'Something feels blocked, unfair, or irritating.',
      checkInQuestion: 'What is making you feel stuck or irritated?',
      finalMessage:
          'Frustration often means something matters to you. You gave the feeling space without letting it take over.',
      preferredAction: _FinalAction.motivation,
      exercises: const [
        _ExerciseOption(
          title: 'Release tension',
          subtitle: 'Unclench your body first.',
          icon: Icons.front_hand_outlined,
          type: _ExerciseType.tensionRelease,
        ),
        _ExerciseOption(
          title: 'Unsent rant',
          subtitle: 'Write it out without filtering.',
          icon: Icons.edit_note,
          type: _ExerciseType.journal,
        ),
        _ExerciseOption(
          title: 'Reframe the block',
          subtitle: 'Find what is still in your control.',
          icon: Icons.change_circle_outlined,
          type: _ExerciseType.reframe,
        ),
      ],
    ),
    _MoodConfig(
      label: 'Happy',
      assetPath: 'assets/images/happyTeddy.png',
      haloColor: const Color(0xFFFFE8A3),
      subtitle: 'You feel okay, light, or happy.',
      checkInQuestion: 'What do you want to do with this good energy?',
      finalMessage:
          'Good moments deserve attention too. Noticing them helps your brain remember that they exist.',
      preferredAction: _FinalAction.focus,
      exercises: const [
        _ExerciseOption(
          title: 'Gratitude journal',
          subtitle: 'Write three good things.',
          icon: Icons.favorite_border,
          type: _ExerciseType.gratitude,
        ),
        _ExerciseOption(
          title: 'Savor the moment',
          subtitle: 'Let the good feeling last longer.',
          icon: Icons.wb_sunny_outlined,
          type: _ExerciseType.savoring,
        ),
        _ExerciseOption(
          title: 'Carry it forward',
          subtitle: 'Choose how to use this energy.',
          icon: Icons.arrow_forward,
          type: _ExerciseType.intention,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _journalController.dispose();
    _smallStepController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _step = step);
      _fadeController.forward();
    });
  }

  void _selectMood(_MoodConfig mood) {
    setState(() {
      _selectedMood = mood;
      _selectedExercise = null;
      _beforeIntensity = 5;
      _afterIntensity = 5;
      _journalController.clear();
      _smallStepController.clear();
      _resetBreathing();
      _bodyScanIndex = 0;
      _bodyScanFinished = false;
    });

    _goTo(1);
  }

  void _selectExercise(_ExerciseOption exercise) {
    setState(() {
      _selectedExercise = exercise;
      _journalController.clear();
      _smallStepController.clear();
      _resetBreathing();
      _bodyScanIndex = 0;
      _bodyScanFinished = false;
    });

    _goTo(3);
  }

  void _resetBreathing() {
    _breathingTimer?.cancel();
    _breathingStarted = false;
    _breathingSeconds = _totalBreathingSeconds;
  }

  void _startBreathing() {
    if (_breathingStarted) return;

    setState(() {
      _breathingStarted = true;
      _breathingSeconds = _totalBreathingSeconds;
    });

    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_breathingSeconds <= 1) {
        timer.cancel();
        setState(() => _breathingSeconds = 0);
        return;
      }

      setState(() => _breathingSeconds--);
    });
  }

  int get _breathingElapsed => _totalBreathingSeconds - _breathingSeconds;

  int get _breathingRound {
    if (!_breathingStarted) return 1;
    if (_breathingSeconds == 0) return _breathingRounds;

    final round = (_breathingElapsed ~/ _breathingCycleSeconds) + 1;
    if (round > _breathingRounds) return _breathingRounds;
    return round;
  }

  int get _breathingPhaseSecond => _breathingElapsed % _breathingCycleSeconds;

  String get _breathingText {
    if (!_breathingStarted) return 'Ready for 3 slow rounds?';
    if (_breathingSeconds == 0) return 'Done';

    final phase = _breathingPhaseSecond;

    if (phase < _inhaleSeconds) return 'Inhale';
    if (phase < _inhaleSeconds + _holdSeconds) return 'Hold';
    return 'Exhale';
  }

  String get _breathingInstruction {
    if (!_breathingStarted) {
      return 'Tap start and follow the circle with Teddy.';
    }

    if (_breathingSeconds == 0) {
      return 'You completed all 3 rounds.';
    }

    if (_breathingText == 'Inhale') return 'Breathe in slowly through your nose.';
    if (_breathingText == 'Hold') return 'Hold gently. No forcing.';
    return 'Breathe out slowly and let your shoulders drop.';
  }

  double get _circleSize {
    if (!_breathingStarted) return 132;
    if (_breathingSeconds == 0) return 150;

    final phase = _breathingPhaseSecond;

    if (phase < _inhaleSeconds) {
      final progress = (phase + 1) / _inhaleSeconds;
      return 130 + (progress * 62);
    }

    if (phase < _inhaleSeconds + _holdSeconds) {
      return 192;
    }

    final exhaleProgress =
        (phase - _inhaleSeconds - _holdSeconds + 1) / _exhaleSeconds;
    return 192 - (exhaleProgress * 62);
  }

  double get _breathingProgress {
    if (!_breathingStarted) return 0;
    return _breathingElapsed / _totalBreathingSeconds;
  }

  String get _resultText {
    final mood = _selectedMood;

    if (mood == null) return 'You checked in with yourself. That matters.';

    if (_afterIntensity < _beforeIntensity) {
      return '${mood.finalMessage}\n\nYour intensity went down from ${_beforeIntensity.round()}/10 to ${_afterIntensity.round()}/10.';
    }

    if (_afterIntensity == _beforeIntensity) {
      return '${mood.finalMessage}\n\nThe feeling stayed at ${_afterIntensity.round()}/10. That is okay. Processing does not always mean instantly feeling better.';
    }

    return '${mood.finalMessage}\n\nThe feeling went from ${_beforeIntensity.round()}/10 to ${_afterIntensity.round()}/10. Sometimes noticing an emotion makes it feel louder before it softens.';
  }

  String get _primaryFinalButton {
    final action = _selectedMood?.preferredAction;

    if (action == _FinalAction.focus) return 'Start a Focus Session';
    return 'Get a Motivation Boost';
  }

  void _goToFinalAction() {
    final action = _selectedMood?.preferredAction;

    if (action == _FinalAction.focus) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TimerScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MotivationScreen()),
    );
  }

  Widget _header({
    required String title,
    required String subtitle,
    bool center = false,
  }) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 27,
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: AppColors.subtext,
            fontSize: 15.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _progressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final active = index == _step;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
        );
      }),
    );
  }

  Widget _primaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
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
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: BorderSide(color: AppColors.outline, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    Color? background,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline, width: 1.3),
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 4,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.text, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.subtext),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outline, width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _screen(Widget child) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _progressDots(),
            const SizedBox(height: 28),
            child,
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

Widget _buildTeddyWithGlow(_MoodConfig mood, bool isTablet) {
  final double teddySize = isTablet ? 85 : 78;
  final double boxSize = isTablet ? 140 : 125;

  return SizedBox(
    width: boxSize,
    height: boxSize,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.18,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Image.asset(
              mood.assetPath,
              width: teddySize,
              height: teddySize,
              fit: BoxFit.contain,
              color: mood.haloColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
        Opacity(
          opacity: 0.14,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Image.asset(
              mood.assetPath,
              width: teddySize,
              height: teddySize,
              fit: BoxFit.contain,
              color: mood.haloColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
        Opacity(
          opacity: 0.08,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Image.asset(
              mood.assetPath,
              width: teddySize,
              height: teddySize,
              fit: BoxFit.contain,
              color: mood.haloColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
        Image.asset(
          mood.assetPath,
          width: teddySize,
          height: teddySize,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

  Widget _buildMoodTile(_MoodConfig mood, bool isTablet) {
    return InkWell(
      onTap: () => _selectMood(mood),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 10,
          vertical: isTablet ? 14 : 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outline,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTeddyWithGlow(mood, isTablet),
            const SizedBox(height: 8),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: isTablet ? 17 : 15.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodPicker() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 700;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(
              title: 'How are you feeling?',
              subtitle:
                  'Choose the Teddy that feels closest to your mood right now.',
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _moods.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: isTablet ? 205 : 195,
              ),
              itemBuilder: (_, index) {
                final mood = _moods[index];
                return _buildMoodTile(mood, isTablet);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntensityStep() {
    final mood = _selectedMood!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: mood.label,
          subtitle: mood.checkInQuestion,
        ),
        const SizedBox(height: 24),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            children: [
              Text(
                'How strong is this feeling?',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_beforeIntensity.round()}/10',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _beforeIntensity,
                min: 1,
                max: 10,
                divisions: 9,
                label: _beforeIntensity.round().toString(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surface,
                onChanged: (value) {
                  setState(() => _beforeIntensity = value);
                },
              ),
              Text(
                '1 = barely there   •   10 = very strong',
                style: TextStyle(color: AppColors.subtext, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(2)),
      ],
    );
  }

  Widget _buildExercisePicker() {
    final mood = _selectedMood!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'What would help right now?',
          subtitle:
              'Because you chose ${mood.label.toLowerCase()}, here are exercises that actually match that mood.',
        ),
        const SizedBox(height: 22),
        ...mood.exercises.map((exercise) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _selectExercise(exercise),
              borderRadius: BorderRadius.circular(18),
              child: _card(
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
                        exercise.icon,
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
                            exercise.title,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.subtitle,
                            style: TextStyle(
                              color: AppColors.subtext,
                              height: 1.35,
                              fontSize: 13.5,
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
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExerciseStep() {
    final type = _selectedExercise!.type;

    switch (type) {
      case _ExerciseType.breathing:
        return _breathingExercise();
      case _ExerciseType.grounding:
        return _groundingExercise();
      case _ExerciseType.journal:
        return _journalExercise();
      case _ExerciseType.gratitude:
        return _gratitudeExercise();
      case _ExerciseType.bodyScan:
        return _bodyScanExercise();
      case _ExerciseType.tinyStep:
        return _tinyStepExercise();
      case _ExerciseType.brainDump:
        return _brainDumpExercise();
      case _ExerciseType.findReason:
        return _valuesExercise();
      case _ExerciseType.tensionRelease:
        return _tensionReleaseExercise();
      case _ExerciseType.reframe:
        return _reframeExercise();
      case _ExerciseType.savoring:
        return _savoringExercise();
      case _ExerciseType.intention:
        return _intentionExercise();
      case _ExerciseType.focusShield:
        return _focusShieldExercise();
    }
  }

  Widget _exerciseHeader(String title, String subtitle) {
    return _header(title: title, subtitle: subtitle, center: true);
  }

  Widget _centeredBreathingTeddy(String assetPath) {
    return SizedBox(
      width: 98,
      height: 98,
      child: Center(
        child: Transform.translate(
          offset: _breathingTeddyOffset,
          child: Transform.scale(
            scale: 1.08,
            child: Image.asset(
              assetPath,
              width: 84,
              height: 84,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _breathingExercise() {
    final mood = _selectedMood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _exerciseHeader(
          'Breathe with Teddy',
          'Three guided rounds: inhale, hold, exhale. Follow the circle instead of counting alone.',
        ),
        const SizedBox(height: 26),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_breathingRounds, (index) {
                  final active = _breathingStarted &&
                      _breathingSeconds > 0 &&
                      index + 1 == _breathingRound;
                  final completed = _breathingStarted &&
                      (index + 1 < _breathingRound || _breathingSeconds == 0);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: active ? 38 : 28,
                    height: 8,
                    decoration: BoxDecoration(
                      color: completed || active
                          ? AppColors.primary
                          : AppColors.outline,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: 230,
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 224,
                      height: 224,
                      child: CircularProgressIndicator(
                        value: _breathingProgress,
                        strokeWidth: 6,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 950),
                      curve: Curves.easeInOutCubic,
                      width: _circleSize,
                      height: _circleSize,
                      decoration: BoxDecoration(
                        color: mood?.haloColor.withOpacity(0.24) ??
                            AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: mood?.haloColor.withOpacity(0.65) ??
                              AppColors.outline,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (mood?.haloColor ?? AppColors.primary)
                                .withOpacity(0.18),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    _centeredBreathingTeddy(
                      mood?.assetPath ?? 'assets/images/teddy.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                _breathingText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _breathingInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _breathingStarted
                    ? 'Round $_breathingRound of $_breathingRounds • $_breathingSeconds sec left'
                    : 'Inhale 4 sec • Hold 2 sec • Exhale 6 sec',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.subtext,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!_breathingStarted)
          _primaryButton('Start 3 breathing rounds', _startBreathing)
        else if (_breathingSeconds == 0)
          _primaryButton('Continue', () => _goTo(4))
        else
          _secondaryButton('Skip breathing', () => _goTo(4)),
      ],
    );
  }

  Widget _groundingExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _exerciseHeader(
          '5-4-3-2-1 Grounding',
          'This helps bring your mind back to the room you are in.',
        ),
        const SizedBox(height: 24),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _StepText(number: '5', text: 'Name 5 things you can see.'),
              _StepText(number: '4', text: 'Name 4 things you can feel.'),
              _StepText(number: '3', text: 'Name 3 things you can hear.'),
              _StepText(number: '2', text: 'Name 2 things you can smell.'),
              _StepText(
                number: '1',
                text: 'Name 1 thing you can taste or one slow breath.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('I did it', () => _goTo(4)),
      ],
    );
  }

  Widget _journalExercise() {
    final mood = _selectedMood!;

    String hint = 'Write whatever is here. No need to make it pretty.';

    if (mood.label == 'Anxious') {
      hint = 'Write the worry. Then add: “Right now, I can only control...”';
    } else if (mood.label == 'Frustrated') {
      hint = 'Write the uncensored version here. You do not need to send it.';
    } else if (mood.label == 'Tired') {
      hint = 'Write what drained you today, even if it seems small.';
    } else if (mood.label == 'Unmotivated') {
      hint = 'Write what feels stuck or disconnected.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Journal it out',
          subtitle:
              'This is not for grammar. It is just a place to put the feeling somewhere outside your head.',
        ),
        const SizedBox(height: 22),
        _textField(controller: _journalController, hint: hint, maxLines: 6),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Text(
            'Tiny prompt: “The feeling I am having is ___, and it makes sense because ___.”',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              height: 1.5,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _gratitudeExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Three good things',
          subtitle:
              'This is not about pretending everything is perfect. It is about noticing what is still good.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletText('One thing I am grateful for today is...'),
              _BulletText('One small thing that made me smile was...'),
              _BulletText('One thing I want to remember from today is...'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _textField(
          controller: _journalController,
          hint: '1.\n2.\n3.',
          maxLines: 6,
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _bodyScanExercise() {
    final steps = [
      {
        'title': 'Forehead',
        'instruction': 'Relax your forehead.',
        'subtitle':
            'Let your face soften. You do not need to hold tension there.',
        'icon': Icons.face_retouching_natural,
      },
      {
        'title': 'Shoulders',
        'instruction': 'Drop your shoulders.',
        'subtitle': 'Let them move away from your ears.',
        'icon': Icons.accessibility_new,
      },
      {
        'title': 'Jaw',
        'instruction': 'Unclench your jaw.',
        'subtitle': 'Let your teeth separate slightly.',
        'icon': Icons.sentiment_satisfied_alt,
      },
      {
        'title': 'Hands',
        'instruction': 'Notice your hands. Are they tense?',
        'subtitle': 'Open your fingers and let your hands rest.',
        'icon': Icons.pan_tool_alt_outlined,
      },
      {
        'title': 'Breath',
        'instruction': 'Take one slow breath.',
        'subtitle': 'Breathe in slowly, then breathe out even slower.',
        'icon': Icons.air,
      },
    ];

    final currentStep = steps[_bodyScanIndex];

    if (_bodyScanFinished) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            title: 'What did you notice?',
            subtitle:
                'Now that you checked your body, write what feels different or what your body may need.',
          ),
          const SizedBox(height: 22),
          _card(
            background: AppColors.surfaceSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _BulletText('Did anything feel lighter?'),
                _BulletText('Where do you still feel tension?'),
                _BulletText('What would help your body right now?'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _textField(
            controller: _journalController,
            hint: 'My body feels...',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _primaryButton('Continue', () => _goTo(4)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Body check',
          subtitle: 'Let’s check your body one small step at a time.',
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              'Step ${_bodyScanIndex + 1} of ${steps.length}',
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${((_bodyScanIndex + 1) / steps.length * 100).round()}%',
              style: TextStyle(
                color: AppColors.subtext,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: (_bodyScanIndex + 1) / steps.length,
            backgroundColor: AppColors.surfaceSoft,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
child: KeyedSubtree(
  key: ValueKey(_bodyScanIndex),
  child: _card(
    background: AppColors.surfaceSoft,
    child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outline,
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    currentStep['icon'] as IconData,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  currentStep['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStep['instruction'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    height: 1.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentStep['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 15.5,
                    height: 1.45,
            ),
          ),
        ],
      ),
    ),
  ),
),
        const SizedBox(height: 24),
        _primaryButton(
          _bodyScanIndex == steps.length - 1 ? 'Finish body check' : 'I did it',
          () {
            setState(() {
              if (_bodyScanIndex < steps.length - 1) {
                _bodyScanIndex++;
              } else {
                _bodyScanFinished = true;
              }
            });
          },
        ),
        if (_bodyScanIndex > 0) ...[
          const SizedBox(height: 12),
          _secondaryButton(
            'Back',
            () {
              setState(() {
                _bodyScanIndex--;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _tinyStepExercise() {
    final mood = _selectedMood!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: mood.label == 'Overwhelmed'
              ? 'Choose one thing'
              : 'Tiny next step',
          subtitle:
              'Not the whole task. Not the perfect plan. Just the smallest next move.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Text(
            mood.label == 'Overwhelmed'
                ? 'Ask yourself: “If I could only make one thing lighter, what would it be?”'
                : 'Ask yourself: “What can I do for only two minutes?”',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),
        _textField(
          controller: _smallStepController,
          hint: 'My tiny step is...',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _brainDumpExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Brain dump',
          subtitle:
              'When your mind is crowded, do not organize first. Just empty it.',
        ),
        const SizedBox(height: 22),
        _textField(
          controller: _journalController,
          hint: 'Everything on my mind right now is...',
          maxLines: 7,
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Text(
            'After writing, circle only ONE thing that needs attention first. The rest can wait.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _valuesExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Find the reason',
          subtitle:
              'Motivation often comes back when the task reconnects to something meaningful.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletText('Why did this matter to me at first?'),
              _BulletText('Who am I becoming by showing up?'),
              _BulletText('What would future me thank me for?'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _textField(
          controller: _journalController,
          hint: 'This matters because...',
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _tensionReleaseExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Release tension',
          subtitle:
              'Frustration often lives in the body. Let’s release a little bit of it.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletText('Unclench your jaw.'),
              _BulletText('Lower your shoulders.'),
              _BulletText('Press your feet into the floor.'),
              _BulletText('Squeeze your fists for 3 seconds, then release.'),
              _BulletText('Take one slow breath out.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('I did it', () => _goTo(4)),
      ],
    );
  }

  Widget _reframeExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Reframe the block',
          subtitle:
              'This is not about pretending it is fine. It is about finding what is still in your control.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletText('What exactly is blocked?'),
              _BulletText('What part is outside my control?'),
              _BulletText('What part is still inside my control?'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _textField(
          controller: _journalController,
          hint: 'What I can still control is...',
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _savoringExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Savor the moment',
          subtitle:
              'Good feelings can pass quickly. This helps your brain actually register them.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletText('Pause for 10 seconds.'),
              _BulletText('Name what feels good.'),
              _BulletText('Notice where you feel it in your body.'),
              _BulletText('Take a mental picture of this moment.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _intentionExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Set an intention',
          subtitle:
              'An intention is softer than a goal. It gives direction without pressure.',
        ),
        const SizedBox(height: 22),
        _textField(
          controller: _journalController,
          hint: 'Today, I want to move with...',
          maxLines: 3,
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Text(
            'Example: “I want to move with patience.” / “I want to focus on one thing at a time.”',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _focusShieldExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          title: 'Protect your focus',
          subtitle:
              'Focus can disappear fast. Choose one boundary before you begin.',
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletText('Put your phone away or on silent.'),
              _BulletText('Open only the tab or file you need.'),
              _BulletText('Choose one task, not five.'),
              _BulletText('Decide how long you will focus.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton('Continue', () => _goTo(4)),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _header(
          title: 'How does it feel now?',
          subtitle:
              'It does not need to be gone. Just notice whether it changed.',
          center: true,
        ),
        const SizedBox(height: 24),
        _card(
          child: Column(
            children: [
              Text(
                'Now: ${_afterIntensity.round()}/10',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _afterIntensity,
                min: 1,
                max: 10,
                divisions: 9,
                label: _afterIntensity.round().toString(),
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceSoft,
                onChanged: (value) {
                  setState(() => _afterIntensity = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _card(
          background: AppColors.surfaceSoft,
          child: Text(
            _resultText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton(_primaryFinalButton, _goToFinalAction),
        const SizedBox(height: 12),
        _secondaryButton('I feel a little better', () {
          Navigator.pop(context);
        }),
      ],
    );
  }

  Widget _currentStep() {
    if (_step == 0) return _buildMoodPicker();
    if (_step == 1) return _buildIntensityStep();
    if (_step == 2) return _buildExercisePicker();
    if (_step == 3) return _buildExerciseStep();
    return _buildFinalStep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mood Check-In',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  if (_step == 3) {
                    setState(() => _resetBreathing());
                  }
                  _goTo(_step - 1);
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: _screen(_currentStep()),
          ),
        ),
      ),
    );
  }
}

class _MoodConfig {
  final String label;
  final String assetPath;
  final Color haloColor;
  final String subtitle;
  final String checkInQuestion;
  final String finalMessage;
  final _FinalAction preferredAction;
  final List<_ExerciseOption> exercises;

  const _MoodConfig({
    required this.label,
    required this.assetPath,
    required this.haloColor,
    required this.subtitle,
    required this.checkInQuestion,
    required this.finalMessage,
    required this.preferredAction,
    required this.exercises,
  });
}

class _ExerciseOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final _ExerciseType type;

  const _ExerciseOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });
}

enum _ExerciseType {
  breathing,
  grounding,
  journal,
  gratitude,
  bodyScan,
  tinyStep,
  brainDump,
  findReason,
  tensionRelease,
  reframe,
  savoring,
  intention,
  focusShield,
}

enum _FinalAction {
  motivation,
  focus,
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '• $text',
        style: const TextStyle(
          color: Color(0xFF082052),
          fontSize: 15.5,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  final String number;
  final String text;

  const _StepText({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number ',
            style: const TextStyle(
              color: Color(0xFF082052),
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF082052),
                fontSize: 15.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}