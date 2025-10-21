import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textFade;
  late Animation<double> _backgroundPulse;
  
  // Shape animations
  late List<AnimationController> _shapeControllers;
  late List<Animation<Offset>> _shapeAnimations;
  late List<Animation<double>> _shapeScales;
  late List<Animation<double>> _shapeRotations;

  @override
  void initState() {
    super.initState();
    
    // Main timeline controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 6000), // Increased from 3000ms to 4000ms
      vsync: this,
    );
    
    // Logo formation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000), // Increased from 1500ms to 2000ms
      vsync: this,
    );
    
    // Text appearance controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Increased from 800ms to 1000ms
      vsync: this,
    );
    
    // Background pulse controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Initialize shape controllers and animations
    _initializeShapeAnimations();
    
    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    // Text animation
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
    
    // Background pulse
    _backgroundPulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );
    
    _startAnimationSequence();
  }
  
  void _initializeShapeAnimations() {
    const int shapeCount = 8;
    _shapeControllers = [];
    _shapeAnimations = [];
    _shapeScales = [];
    _shapeRotations = [];
    
    for (int i = 0; i < shapeCount; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1200 + (i * 150)), // Increased base from 800 to 1200, increment from 100 to 150
        vsync: this,
      );
      _shapeControllers.add(controller);
      
      // Calculate entry positions (from different edges)
      Offset startPosition;
      Offset endPosition;
      
      switch (i % 4) {
        case 0: // From top
          startPosition = Offset(0.5 + (i * 0.1), -0.5);
          break;
        case 1: // From right
          startPosition = Offset(1.5, 0.5 + (i * 0.1));
          break;
        case 2: // From bottom
          startPosition = Offset(0.5 - (i * 0.1), 1.5);
          break;
        case 3: // From left
          startPosition = Offset(-0.5, 0.5 - (i * 0.1));
          break;
        default:
          startPosition = const Offset(0.5, 0.5);
      }
      
      // All shapes converge to form logo in center
      endPosition = _getLogoPosition(i);
      
      _shapeAnimations.add(
        Tween<Offset>(begin: startPosition, end: endPosition).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutBack,
          ),
        ),
      );
      
      _shapeScales.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        ),
      );
      
      _shapeRotations.add(
        Tween<double>(begin: 0.0, end: math.pi * 2).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
  }
  
  Offset _getLogoPosition(int index) {
    // Arrange shapes to form a chat bubble-like logo
    const center = Offset(0.5, 0.45);
    const radius = 0.08;
    
    switch (index) {
      case 0: return center + Offset(-radius, -radius); // Top-left circle
      case 1: return center + Offset(radius, -radius);  // Top-right circle
      case 2: return center + Offset(-radius, radius);  // Bottom-left circle
      case 3: return center + Offset(radius, radius);   // Bottom-right circle
      case 4: return center + const Offset(0, -radius * 1.5); // Top center
      case 5: return center + const Offset(0, radius * 1.5);  // Bottom center
      case 6: return center + Offset(-radius * 1.5, 0);       // Left center
      case 7: return center + Offset(radius * 1.5, 0);        // Right center
      default: return center;
    }
  }
  
  void _startAnimationSequence() async {
    // Start background pulse immediately
    _backgroundController.repeat(reverse: true);
    
    // Stagger shape entries (slower)
    for (int i = 0; i < _shapeControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () { // Increased from 150ms to 200ms
        if (mounted) _shapeControllers[i].forward();
      });
    }
    
    // Start logo formation after shapes are positioned (longer wait)
    await Future.delayed(const Duration(milliseconds: 1600)); // Increased from 1200ms to 1600ms
    if (mounted) _logoController.forward();
    
    // Show text after logo forms (longer wait)
    await Future.delayed(const Duration(milliseconds: 1000)); // Increased from 800ms to 1000ms
    if (mounted) _textController.forward();
    
    // Navigate after complete animation (longer wait)
    await Future.delayed(const Duration(milliseconds: 1500)); // Increased from 1000ms to 1500ms
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/chat');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    for (final controller in _shapeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _logoController,
          _textController,
          _backgroundController,
          ..._shapeControllers,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: _backgroundPulse.value,
                colors: [
                  Colors.blue.shade900.withOpacity(0.3),
                  Colors.purple.shade900.withOpacity(0.2),
                  Colors.black,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                ...List.generate(20, (index) => _buildBackgroundParticle(index)),
                
                // Main logo formation area
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LogoPainter(
                      shapeAnimations: _shapeAnimations,
                      shapeScales: _shapeScales,
                      shapeRotations: _shapeRotations,
                      logoScale: _logoScale.value,
                      logoRotation: _logoRotation.value,
                    ),
                  ),
                ),
                
                // App title
                Positioned(
                  bottom: 200,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _textFade,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFade.value,
                        child: Transform.scale(
                          scale: 0.8 + (_textFade.value * 0.2),
                          child: Column(
                            children: [
                              Text(
                                'LM Studio Chat',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 20,
                                      color: Colors.blue.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'AI-Powered Conversations',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Loading indicator
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _textFade,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFade.value,
                        child: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBackgroundParticle(int index) {
    final random = math.Random(index);
    final size = 2.0 + random.nextDouble() * 4;
    
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final progress = (_backgroundController.value + index * 0.1) % 1.0;
        final x = random.nextDouble();
        final y = (progress * 1.2 - 0.1) % 1.2;
        
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1 + random.nextDouble() * 0.2),
            ),
          ),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final List<Animation<Offset>> shapeAnimations;
  final List<Animation<double>> shapeScales;
  final List<Animation<double>> shapeRotations;
  final double logoScale;
  final double logoRotation;
  
  _LogoPainter({
    required this.shapeAnimations,
    required this.shapeScales,
    required this.shapeRotations,
    required this.logoScale,
    required this.logoRotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw each animated shape
    for (int i = 0; i < shapeAnimations.length; i++) {
      _drawShape(canvas, size, i);
    }
    
    // Draw central logo glow effect
    if (logoScale > 0.5) {
      _drawLogoGlow(canvas, center);
    }
  }
  
  void _drawShape(Canvas canvas, Size size, int index) {
    final position = shapeAnimations[index].value;
    final scale = shapeScales[index].value;
    final rotation = shapeRotations[index].value;
    
    if (scale <= 0) return;
    
    final center = Offset(size.width * position.dx, size.height * position.dy);
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(scale * logoScale);
    
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        Offset.zero,
        20,
        [
          _getShapeColor(index).withOpacity(0.8),
          _getShapeColor(index).withOpacity(0.3),
        ],
      );
    
    // Draw different shapes based on index
    switch (index % 4) {
      case 0: // Circle
        canvas.drawCircle(Offset.zero, 15, paint);
        break;
      case 1: // Square
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -12, 24, 24),
            const Radius.circular(4),
          ),
          paint,
        );
        break;
      case 2: // Triangle
        final path = Path()
          ..moveTo(0, -15)
          ..lineTo(-13, 12)
          ..lineTo(13, 12)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 3: // Diamond
        final path = Path()
          ..moveTo(0, -15)
          ..lineTo(15, 0)
          ..lineTo(0, 15)
          ..lineTo(-15, 0)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
    
    canvas.restore();
  }
  
  void _drawLogoGlow(Canvas canvas, Offset center) {
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.radial(
        center,
        50 * logoScale,
        [
          Colors.blue.withOpacity(0.3),
          Colors.purple.withOpacity(0.1),
          Colors.transparent,
        ],
      );
    
    canvas.drawCircle(center, 50 * logoScale, glowPaint);
  }
  
  Color _getShapeColor(int index) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.indigo,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
