import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.amber,
      brightness: Brightness.light,
      surface: AppColors.cream,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.warmBrown),
    ),
  );
}
