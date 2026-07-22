import 'package:flutter/material.dart';
import 'package:rg_gym/config/theme/app_colors.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.white,
      surface: AppColors.background,
      onSurface: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        )
      )
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: AppColors.primary,
      selectionHandleColor: AppColors.primary,
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStatePropertyAll(AppColors.backgroundSecondary),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(
        color: AppColors.backgroundSecondary,
        width: 2,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.background,
      headerBackgroundColor: AppColors.primary,

      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.6);
        }

        return Colors.transparent;
      }),

      todayForegroundColor: WidgetStateProperty.all(
        AppColors.primary,
      ),

      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.6);
        }
        return null;
      }),

      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return null;
      }),

      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),
  );
}