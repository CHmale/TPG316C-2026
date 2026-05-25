// ============================================================
// FILE: cut_app_bar.dart
// DESCRIPTION: Custom AppBar with CUT branding
// ============================================================

import 'package:flutter/material.dart';
import '../../../main.dart';

class CUTAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CUTAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          // CUT Logo placeholder (you can add actual logo image here)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CUTColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'CUT',
                style: TextStyle(
                  color: CUTColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
