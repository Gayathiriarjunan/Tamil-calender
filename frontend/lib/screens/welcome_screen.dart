
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleGetStarted() {
    if (_isNavigating) return;

    _isNavigating = true;

    debugPrint('தொடங்கலாம் button tapped');

    widget.onGetStarted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Original image, including the existing button.
                FadeTransition(
                  opacity: _fade,
                  child: Image.asset(
                    'assets/images/welcome_background.png',
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                  ),
                ),

                // Transparent clickable area over the existing button.
                Positioned(
                  left: constraints.maxWidth * 0.10,
                  width: constraints.maxWidth * 0.80,
                  bottom: constraints.maxHeight * 0.075,
                  height: constraints.maxHeight * 0.09,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: _handleGetStarted,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
