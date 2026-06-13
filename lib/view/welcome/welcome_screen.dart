import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  static String routeName = "/WelcomeScreen";

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset("assets/images/welcome_promo.png",
                  width: media.width * 0.75, fit: BoxFit.fitWidth),
              SizedBox(height: media.width * 0.05),
              Text(
                "Welcome, Stefani",
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: media.width * 0.01),
              Text(
                "You are all set now, let's reach your\ngoals together with us",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.subFg,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              RoundGradientButton(
                title: "Go To Home",
                onPressed: () {
                  Navigator.pushNamed(context, DashboardScreen.routeName);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
