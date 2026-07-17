import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final Color? background;
  final VoidCallback? onBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.bottom,
    this.actions,
    this.background,
    this.onBack
  });

  @override
  Size get preferredSize => Size(
    double.infinity,
    kToolbarHeight + (bottom?.preferredSize.height ?? 0)
  );

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);

    return AppBar(
      leading: (canGoBack || onBack != null) ?
        IconButton(
          onPressed: onBack ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ) : null,
      scrolledUnderElevation: 0,
      backgroundColor: (background == null) ? AppColors.backgroundSecondary : background,
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
      ),
      actions: actions,
      bottom: bottom
    );
  }
}