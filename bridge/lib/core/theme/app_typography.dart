import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Lora serif for calm/elder screens
  static TextStyle heading1Serif = GoogleFonts.lora(
    fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.warmBrown,
  );
  static TextStyle heading2Serif = GoogleFonts.lora(
    fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.warmBrown,
  );
  static TextStyle bodySerif = GoogleFonts.lora(
    fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.charcoal, height: 1.6,
  );

  // Inter sans for action/youth screens
  static TextStyle heading1Sans = GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.charcoal,
  );
  static TextStyle heading2Sans = GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal,
  );
  static TextStyle bodySans = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.charcoal, height: 1.5,
  );
  static TextStyle labelSans = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.charcoal,
  );
  static TextStyle captionSans = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.warmBrown,
  );
}
