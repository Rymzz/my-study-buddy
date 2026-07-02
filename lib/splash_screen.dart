import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _teddyOpacity;
  late Animation<double> _teddyScale;
  late Animation<double> _textOpacity;
  late Animation<double> _homeOpacity;
  late Animation<double> _splashOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Teddy apparaît doucement au début.
    _teddyOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.00,
          0.25,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Petit zoom très subtil, pas de mouvement cheap.
    _teddyScale = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.00,
          0.30,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // Le texte apparaît aussi au début.
    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.10,
          0.35,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Le HomeScreen commence à apparaître pendant que le splash disparaît.
    _homeOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.62,
          1.00,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Tout le splash fade out smoothly.
    _splashOpacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.58,
          1.00,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _softCircle({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSplashLayer() {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -75,
              right: -60,
              child: _softCircle(size: 190, opacity: 0.055),
            ),
            Positioned(
              bottom: -85,
              left: -75,
              child: _softCircle(size: 220, opacity: 0.045),
            ),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _teddyOpacity.value,
                    child: Transform.scale(
                      scale: _teddyScale.value,
                      child: Image.asset(
                        'assets/images/teddy.png',
                        width: 185,
                        height: 185,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Text(
                          'My Study Buddy',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.primary,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'A calm space to focus, reset, and grow.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.subtext,
                              fontSize: 15.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Opacity(
                opacity: _homeOpacity.value,
                child: const HomeScreen(),
              ),

              IgnorePointer(
                ignoring: _splashOpacity.value < 0.05,
                child: Opacity(
                  opacity: _splashOpacity.value,
                  child: _buildSplashLayer(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}