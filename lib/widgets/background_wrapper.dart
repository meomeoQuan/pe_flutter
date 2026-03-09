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
      backgroundColor: const Color(0xFF0B0B0B), // Cinematic Deep Black
      appBar: hasAppBar
          ? AppBar(
              backgroundColor: const Color(0xFF0B0B0B).withValues(alpha: 0.9),
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
                      const Color(0xFF0B0B0B),
                      const Color(0xFF0B0B0B).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Edge glow top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE60A15).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Radial glow center
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  colors: [
                    const Color(0xFFE60A15).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Bottom left intense blur
          Positioned(
            bottom: -200,
            left: -200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE60A15).withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE60A15).withValues(alpha: 0.1),
                    blurRadius: 120,
                    spreadRadius: 20,
                  )
                ]
              ),
            ),
          ),

          // Top right intense blur
          Positioned(
            top: -200,
            right: -200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE60A15).withValues(alpha: 0.10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE60A15).withValues(alpha: 0.1),
                    blurRadius: 120,
                    spreadRadius: 20,
                  )
                ]
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
