import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/your_goal/your_goal_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class CompleteProfileScreen extends StatelessWidget {
  static String routeName = "/CompleteProfileScreen";
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15,left: 15),
            child: Column(
              children: [
                Image.asset("assets/images/complete_profile.png",width: media.width),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  l10n.completeProfileTitle,
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w700
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.completeProfileSubtitle,
                  style: TextStyle(
                    color: colors.subFg,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                      color: colors.listTile,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Image.asset(
                            "assets/icons/gender_icon.png",
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            color: colors.subFg,
                          )),
                      Expanded(child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: ["Male","Female"].map((name) => DropdownMenuItem(value:name,child: Text(
                            name == "Male" ? l10n.male : l10n.female,style: TextStyle(color: colors.subFg,fontSize: 14),
                          ))).toList(), onChanged: (value) {  },isExpanded: true,
                          hint: Text(l10n.chooseGender,style: TextStyle(color: colors.subFg,fontSize: 12)),
                        ),
                      )),
                      const SizedBox(width: 8,)
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: l10n.dateOfBirth,
                  icon: "assets/icons/calendar_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: l10n.yourWeight,
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: l10n.yourHeight,
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundGradientButton(
                  title: l10n.next,
                  onPressed: () {
                    Navigator.pushNamed(context, YourGoalScreen.routeName);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
