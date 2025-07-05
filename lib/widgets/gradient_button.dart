import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/theme/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final double fontSize;
  final List<Color> colors;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
    this.colors = const [
      Color(0xFF9C6B53), // Nâu nhạt
      Colors.white,      // Trắng nhạt dần
    ],
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.white,
                  fontWeight: fontWeight,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
