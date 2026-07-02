import 'package:shared_preferences/shared_preferences.dart';

class ProgressData {
  final int totalStars;
  final int totalSessions;
  final int totalFocusSeconds;
  final List<String> unlockedConstellations;
  final String? newConstellation;

  const ProgressData({
    required this.totalStars,
    required this.totalSessions,
    required this.totalFocusSeconds,
    required this.unlockedConstellations,
    this.newConstellation,
  });
}

class ProgressService {
  static const String _starsKey = 'total_stars';
  static const String _sessionsKey = 'total_sessions';
  static const String _focusSecondsKey = 'total_focus_seconds';
  static const String _constellationsKey = 'unlocked_constellations';

  static const List<Map<String, dynamic>> constellations = [
    {'name': 'Triangulum', 'starsRequired': 3},
    {'name': 'Crux', 'starsRequired': 4},
    {'name': 'Lyra', 'starsRequired': 5},
    {'name': 'Cygnus', 'starsRequired': 6},
  ];

  static Future<ProgressData> load() async {
    final prefs = await SharedPreferences.getInstance();

    return ProgressData(
      totalStars: prefs.getInt(_starsKey) ?? 0,
      totalSessions: prefs.getInt(_sessionsKey) ?? 0,
      totalFocusSeconds: prefs.getInt(_focusSecondsKey) ?? 0,
      unlockedConstellations: prefs.getStringList(_constellationsKey) ?? [],
    );
  }

  static Future<ProgressData> completeSession({
    required int durationSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final int newStars = (prefs.getInt(_starsKey) ?? 0) + 1;
    final int newSessions = (prefs.getInt(_sessionsKey) ?? 0) + 1;
    final int newFocusSeconds =
        (prefs.getInt(_focusSecondsKey) ?? 0) + durationSeconds;

    final List<String> unlocked =
        prefs.getStringList(_constellationsKey) ?? [];

    String? newConstellation;

    for (final constellation in constellations) {
      final String name = constellation['name'];
      final int requiredStars = constellation['starsRequired'];

      if (newStars >= requiredStars && !unlocked.contains(name)) {
        unlocked.add(name);
        newConstellation = name;
        break;
      }
    }

    await prefs.setInt(_starsKey, newStars);
    await prefs.setInt(_sessionsKey, newSessions);
    await prefs.setInt(_focusSecondsKey, newFocusSeconds);
    await prefs.setStringList(_constellationsKey, unlocked);

    return ProgressData(
      totalStars: newStars,
      totalSessions: newSessions,
      totalFocusSeconds: newFocusSeconds,
      unlockedConstellations: unlocked,
      newConstellation: newConstellation,
    );
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_starsKey);
    await prefs.remove(_sessionsKey);
    await prefs.remove(_focusSecondsKey);
    await prefs.remove(_constellationsKey);
  }
}