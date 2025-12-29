import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  
  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _textController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final String _appName = 'E Money Well';
  
  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _mainController.forward();
    
    // Start text animation after icon appears
    Future.delayed(const Duration(milliseconds: 400), () {
      _textController.forward();
    });

    Future.delayed(const Duration(seconds: 2), () {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B2E20),
              Color(0xFF283D2F),
              Color(0xFF344E41),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // EMW Logo Animation
              AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF84A98C),
                              Color(0xFF52796F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF84A98C).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // Animated Text - Letter by Letter
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_appName.length, (index) {
                      // Calculate staggered animation for each letter
                      final letterProgress = (_textController.value * _appName.length - index).clamp(0.0, 1.0);
                      final curve = Curves.elasticOut.transform(letterProgress);
                      
                      // Color scheme: E=accent, space, Money=white, space, Well=accent
                      Color letterColor;
                      if (index == 0) {
                        letterColor = const Color(0xFF84A98C); // E
                      } else if (index >= 2 && index <= 6) {
                        letterColor = Colors.white; // Money
                      } else if (index >= 8) {
                        letterColor = const Color(0xFF84A98C); // Well
                      } else {
                        letterColor = Colors.white; // Spaces
                      }
                      
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - curve)),
                        child: Opacity(
                          opacity: letterProgress,
                          child: Transform.scale(
                            scale: 0.5 + (0.5 * curve),
                            child: Text(
                              _appName[index],
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: letterColor,
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: letterColor.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Tagline with fade animation
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  final fadeValue = Curves.easeIn.transform(
                    (_textController.value * 1.5 - 0.5).clamp(0.0, 1.0)
                  );
                  return Opacity(
                    opacity: fadeValue,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - fadeValue)),
                      child: Text(
                        'Your Financial Wellness Partner',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Animated dots instead of loading circle
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      // Create a bouncing animation for each dot
                      final dotProgress = ((_textController.value * 3) % 1.0);
                      final isActive = ((_textController.value * 3).floor() % 3) == index;
                      final scale = isActive ? 1.0 + (0.3 * (1 - (dotProgress * 2 - 1).abs())) : 1.0;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? const Color(0xFF84A98C) 
                                  : const Color(0xFF84A98C).withOpacity(0.3),
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF84A98C).withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
