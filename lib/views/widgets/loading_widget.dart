import 'package:flutter/material.dart';

// 🎨 Custom color scheme for loading states
class LoadingColors {
  static const Color primary = Color(0xFF6C63FF);     // Modern Purple
  static const Color secondary = Color(0xFFFF6584);   // Coral Pink
  static const Color accent = Color(0xFF00D2FF);      // Cyan
  static const Color background = Color(0xFFF8F9FA);  // Light Gray
  static const Color textPrimary = Color(0xFF2D3436); // Dark Gray
  static const Color textSecondary = Color(0xFF636E72); // Medium Gray
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;
  final bool useGradient;
  final double indicatorSize;
  final Color? indicatorColor;
  final Color? backgroundColor;

  const LoadingWidget({
    super.key,
    this.message,
    this.fullScreen = false,
    this.useGradient = true,
    this.indicatorSize = 48,
    this.indicatorColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: !fullScreen
              ? [
                  BoxShadow(
                    color: LoadingColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator
            useGradient
                ? _buildGradientProgressIndicator()
                : SizedBox(
                    width: indicatorSize,
                    height: indicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        indicatorColor ?? LoadingColors.primary,
                      ),
                    ),
                  ),
            
            const SizedBox(height: 24),
            
            // Animated dots with message
            if (message != null) ...[
              _buildLoadingMessage(),
            ] else ...[
              _buildAnimatedDots(),
            ],
          ],
        ),
      ),
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: backgroundColor ?? LoadingColors.background,
        body: content,
      );
    }
    
    return Material(
      color: Colors.transparent,
      child: content,
    );
  }

  // Gradient circular progress indicator
  Widget _buildGradientProgressIndicator() {
    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1500),
        builder: (context, value, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  LoadingColors.primary,
                  LoadingColors.secondary,
                  LoadingColors.accent,
                  LoadingColors.primary,
                ],
                stops: [0, 0.3, 0.7, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: CircularProgressIndicator(
              value: null,
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      ),
    );
  }

  // Loading message with animated dots
  Widget _buildLoadingMessage() {
    return Column(
      children: [
        Text(
          message!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: LoadingColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _buildAnimatedDots(),
      ],
    );
  }

  // Animated dots effect
  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return _AnimatedDot(
          delay: Duration(milliseconds: index * 200),
          color: LoadingColors.primary,
        );
      }),
    );
  }
}

// Animated dot widget
class _AnimatedDot extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _AnimatedDot({required this.delay, required this.color});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// 🎯 Alternative: Skeleton Loading Widget for content placeholders
class SkeletonLoadingWidget extends StatelessWidget {
  final bool fullScreen;
  
  const SkeletonLoadingWidget({super.key, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSkeletonItem(),
        const SizedBox(height: 12),
        _buildSkeletonItem(),
        const SizedBox(height: 12),
        _buildSkeletonItem(),
        const SizedBox(height: 12),
        _buildSkeletonItem(),
      ],
    );
    
    if (fullScreen) {
      return Scaffold(
        backgroundColor: LoadingColors.background,
        body: content,
      );
    }
    
    return content;
  }
  
  Widget _buildSkeletonItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerContainer(height: 20, width: double.infinity),
          const SizedBox(height: 12),
          _buildShimmerContainer(height: 16, width: 200),
          const SizedBox(height: 8),
          _buildShimmerContainer(height: 14, width: 150),
        ],
      ),
    );
  }
  
  Widget _buildShimmerContainer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: LoadingColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
