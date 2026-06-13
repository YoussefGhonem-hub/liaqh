import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class RoundGradientButton extends StatelessWidget {
  final String title;

  /// Pass null to render the button disabled (non-tappable, dimmed).
  final VoidCallback? onPressed;
  const RoundGradientButton({Key? key, required this.title, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: enabled
                  ? AppColors.primaryG
                  : const [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: enabled
                ? const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))]
                : null,
          ),
          child: MaterialButton(
            minWidth: double.maxFinite,
            height: 50,
            onPressed: onPressed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            textColor: AppColors.primaryColor1,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.whiteColor,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
