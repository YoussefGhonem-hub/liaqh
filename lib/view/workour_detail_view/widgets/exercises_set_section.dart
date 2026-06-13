import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/exercises_row.dart';
import 'package:flutter/material.dart';

class ExercisesSetSection extends StatelessWidget {
  final Map sObj;
  final Function(Map obj) onPressed;
  const ExercisesSetSection({Key? key, required this.sObj, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var exercisesArr = sObj["set"] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sObj["name"].toString(),
          style: TextStyle(
              color: colors.fg, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 8,
        ),
        ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: exercisesArr.length,
            itemBuilder: (context, index) {
              var eObj = exercisesArr[index] as Map? ?? {};
              return ExercisesRow(eObj: eObj, onPressed: (){
                onPressed(eObj);
              },);
            }),
      ],
    );
  }
}
