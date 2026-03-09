import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final bool hasAppBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.hasAppBar = false,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFF141414), // Netflix Deep Black
      appBar: hasAppBar
          ? AppBar(
              backgroundColor: const Color(0xFF141414).withValues(alpha: 0.9),
              surfaceTintColor: Colors.transparent,
              leading: canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
              title: title != null
                  ? Text(
                      title!,
                      style: const TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    )
                  : null,
              actions: actions,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF141414),
                      const Color(0xFF141414).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Subtle red ambient light / shadow in the background
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE50914).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE50914).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          // Foreground content
          SafeArea(child: child),
        ],
      ),
    );
  }
}
