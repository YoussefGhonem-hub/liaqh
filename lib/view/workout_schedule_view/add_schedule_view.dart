import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/common.dart';
import '../workour_detail_view/widgets/icon_title_next_row.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  const AddScheduleView({super.key, required this.date});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.bg,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: colors.listTile,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Add Schedule",
          style: TextStyle(
              color: colors.fg,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: colors.listTile,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: colors.bg,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "assets/icons/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                dateToString(widget.date, formatStr: "E, dd MMMM yyyy"),
                style: TextStyle(color: colors.subFg, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Time",
            style: TextStyle(
                color: colors.fg,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {},
              initialDateTime: DateTime.now(),
              use24hFormat: false,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Details Workout",
            style: TextStyle(
                color: colors.fg,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/icons/choose_workout.png",
              title: "Choose Workout",
              time: "Upperbody",
              color: colors.listTile,
              onPressed: () {}),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/icons/difficulity_icon.png",
              title: "Difficulity",
              time: "Beginner",
              color: colors.listTile,
              onPressed: () {}),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/icons/repetitions.png",
              title: "Custom Repetitions",
              time: "",
              color: colors.listTile,
              onPressed: () {}),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/icons/repetitions.png",
              title: "Custom Weights",
              time: "",
              color: colors.listTile,
              onPressed: () {}),
          const Spacer(),
          RoundGradientButton(title: "Save", onPressed: () {}),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
