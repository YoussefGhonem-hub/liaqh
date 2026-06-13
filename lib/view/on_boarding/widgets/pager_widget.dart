import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';

class PagerWidget extends StatelessWidget {

  final Map obj;

  const PagerWidget({Key? key, required this.obj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      height: media.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(obj["image"], width: media.width, fit: BoxFit.fitWidth),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    obj["title"],
                    style: TextStyle(color: colors.fg, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 315,
                    child: Text(
                      obj["subtitle"],
                      style: TextStyle(
                        color: colors.subFg,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}
