import 'package:flutter/material.dart';

// 🎨 Custom color scheme for empty states
class EmptyStateColors {
  static const Color primary = Color(0xFF6C63FF);     // Modern Purple
  static const Color secondary = Color(0xFFFF6584);   // Coral Pink
  static const Color accent = Color(0xFF00D2FF);      // Cyan
  static const Color background = Color(0xFFF8F9FA);  // Light Gray
  static const Color textPrimary = Color(0xFF2D3436); // Dark Gray
  static const Color textSecondary = Color(0xFF636E72); // Medium Gray
  static const Color iconLight = Color(0xFFD0D3D8);   // Light Gray for icon
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool useGradient;
  final bool animateIcon;
  final double iconSize;
  final Color? iconColor;
  final Color? buttonColor;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
    this.buttonText,
    this.onButtonPressed,
    this.useGradient = true,
    this.animateIcon = true,
    this.iconSize = 80,
    this.iconColor,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with gradient or color
            if (animateIcon)
              _buildAnimatedIcon()
            else
              _buildStaticIcon(),
            
            const SizedBox(height: 24),
            
            // Title with gradient option
            if (useGradient)
              _buildGradientTitle()
            else
              _buildStaticTitle(),
            
            const SizedBox(height: 12),
            
            // Message with better styling
            _buildMessage(),
            
            // Action button with enhanced styling
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              _buildActionButton(),
            ],
            
            // Decorative illustration (optional visual flair)
            const SizedBox(height: 16),
            _buildDecorativeDots(),
          ],
        ),
      ),
    );
  }

  // Animated icon with bounce effect
  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(20 * (1 - value) + 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? EmptyStateColors.primary).withOpacity(0.1),
                  (iconColor ?? EmptyStateColors.secondary).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (iconColor ?? EmptyStateColors.primary).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? EmptyStateColors.primary,
            ),
          ),
        );
      },
    );
  }

  // Static icon with gradient background
  Widget _buildStaticIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            (iconColor ?? EmptyStateColors.primary).withOpacity(0.1),
            (iconColor ?? EmptyStateColors.secondary).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (iconColor ?? EmptyStateColors.primary).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? EmptyStateColors.primary,
      ),
    );
  }

  // Gradient title text
  Widget _buildGradientTitle() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            EmptyStateColors.primary,
            EmptyStateColors.secondary,
            EmptyStateColors.accent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds);
      },
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Will be replaced by gradient
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Static title text
  Widget _buildStaticTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: EmptyStateColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Enhanced message with icon ornament
  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: EmptyStateColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: EmptyStateColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: EmptyStateColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: EmptyStateColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced action button with gradient and shadow
  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor ?? EmptyStateColors.primary,
            (buttonColor ?? EmptyStateColors.secondary),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (buttonColor ?? EmptyStateColors.primary).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onButtonPressed,
        icon: const Icon(Icons.add, size: 18),
        label: Text(
          buttonText!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // Decorative dots for visual interest
  Widget _buildDecorativeDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: EmptyStateColors.primary.withOpacity(0.2 + (index * 0.1)),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// 🎯 Alternative: Illustrated Empty State with Custom Image
class IllustratedEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? illustration;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const IllustratedEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.illustration,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustration != null) ...[
              illustration!,
              const SizedBox(height: 24),
            ] else ...[
              _buildDefaultIllustration(),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: EmptyStateColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: EmptyStateColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: EmptyStateColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultIllustration() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            EmptyStateColors.primary.withOpacity(0.1),
            EmptyStateColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.assignment_outlined,
        size: 70,
        color: EmptyStateColors.primary,
      ),
    );
  }
}
