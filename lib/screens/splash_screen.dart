import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _runSplashSequence();
  }

  Future<void> _runSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Scale in the N logo
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Play ta-dum sound effect (synthesized)
    try {
      await _audioPlayer.setSource(AssetSource('sounds/netflix_intro.mp3'));
      await _audioPlayer.resume();
    } catch (_) {
      // Audio not available, continue without it
    }

    // Glow effect
    _glowController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));

    // Fade out and navigate
    if (mounted) {
      await Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scaleController.dispose();
    _audioPlayer.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.netflixBlack,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_glowController, _scaleController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Red glow behind the N
                  if (_glowAnimation.value > 0)
                    Container(
                      width: 200 * _glowAnimation.value,
                      height: 200 * _glowAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.netflixRed
                                .withOpacity(0.6 * _glowAnimation.value),
                            blurRadius: 80 * _glowAnimation.value,
                            spreadRadius: 30 * _glowAnimation.value,
                          ),
                        ],
                      ),
                    ),
                  // Netflix N Logo
                  _NetflixNLogo(glowValue: _glowAnimation.value),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NetflixNLogo extends StatelessWidget {
  final double glowValue;
  const _NetflixNLogo({required this.glowValue});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 160,
      child: CustomPaint(
        painter: _NetflixLogoPainter(glowValue: glowValue),
      ),
    );
  }
}

class _NetflixLogoPainter extends CustomPainter {
  final double glowValue;
  _NetflixLogoPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeW = w * 0.28;

    // Shadow / glow
    final glowPaint = Paint()
      ..color = AppTheme.netflixRed.withOpacity(0.4 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 20);

    // Left pillar
    final leftPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.netflixRed,
          Color.lerp(AppTheme.netflixRed, const Color(0xFFFF3B30), glowValue)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, strokeW, h))
      ..style = PaintingStyle.fill;

    // Right pillar
    final rightPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.netflixRed,
          Color.lerp(AppTheme.netflixRed, const Color(0xFFFF3B30), glowValue)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w - strokeW, 0, strokeW, h))
      ..style = PaintingStyle.fill;

    // Draw glow
    canvas.drawRect(Rect.fromLTWH(0, 0, strokeW, h), glowPaint);
    canvas.drawRect(Rect.fromLTWH(w - strokeW, 0, strokeW, h), glowPaint);

    // Left pillar
    canvas.drawRect(Rect.fromLTWH(0, 0, strokeW, h), leftPaint);

    // Right pillar
    canvas.drawRect(Rect.fromLTWH(w - strokeW, 0, strokeW, h), rightPaint);

    // Diagonal stroke (N stroke)
    final diagPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.netflixRed,
          Color.lerp(AppTheme.netflixRed, const Color(0xFFD00000), 0.5)!,
          AppTheme.netflixRed,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(strokeW, 0)
      ..lineTo(w, h)
      ..lineTo(w - strokeW, h)
      ..close();
    canvas.drawPath(path, diagPaint);
  }

  @override
  bool shouldRepaint(_NetflixLogoPainter old) => old.glowValue != glowValue;
}
