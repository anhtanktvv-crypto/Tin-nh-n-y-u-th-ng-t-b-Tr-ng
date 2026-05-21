import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'love_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heartbeatAnimation;

  final List<String> _splashAssets = [
    'namtayem.png',
    'notification.png',
    'thuonggaubong.png',
  ];

  int _currentAssetIndex = 0;
  Timer? _assetTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _heartbeatAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Auto switch assets
    _assetTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentAssetIndex = (_currentAssetIndex + 1) % _splashAssets.length;
      });
    });

    // Navigate to main app after animation
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LovePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _assetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Stack(
          children: [
            // Floating hearts background - improved
            ...List.generate(20, (index) => _buildFloatingHeart(index, size)),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated heart icon with glow
                          Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.loveGradient,
                                boxShadow: AppTheme.glowShadow(Colors.pink),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Title with heartbeat effect
                          Transform.scale(
                            scale: _heartbeatAnimation.value,
                            child: const Text(
                              '💖 Love Station 💖',
                              style: AppTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Trạm Sạc Tình Yêu',
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFont(context, 16, 20),
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Rotating profile images
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                              key: ValueKey(_currentAssetIndex),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/${_splashAssets[_currentAssetIndex]}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Custom loading indicator
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang kết nối trái tim... 💕',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHeart(int index, Size size) {
    final random = Random(index);
    final left = random.nextDouble() * size.width;
    final duration = Duration(milliseconds: 3000 + index * 400);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      onEnd: () => setState(() {}),
      builder: (context, double value, child) {
        return Positioned(
          left: left,
          top: size.height * (1 - value),
          child: Opacity(
            opacity: (0.2 + index * 0.02) * value,
            child: Transform.scale(
              scale: 0.5 + value * 0.8,
              child: Icon(
                Icons.favorite,
                color: index % 2 == 0 ? Colors.pink : Colors.red,
                size: 12 + (index % 4) * 6,
              ),
            ),
          ),
        );
      },
    );
  }
}