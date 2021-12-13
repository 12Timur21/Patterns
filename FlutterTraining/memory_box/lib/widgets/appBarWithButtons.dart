import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

PreferredSizeWidget appBarWithButtons({
  required Function leadingOnPress,
  required Widget title,
  required Function actionsOnPress,
}) {
  return AppBar(
    primary: true,
    toolbarHeight: 70,
    backgroundColor: Colors.transparent,
    centerTitle: true,
    leading: Container(
      margin: EdgeInsets.only(left: 6),
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/Burger.svg',
        ),
        onPressed: () {
          leadingOnPress();
        },
      ),
    ),
    title: title,
    actions: [
      Container(
        margin: const EdgeInsets.only(
          right: 15,
        ),
        child: IconButton(
          onPressed: actionsOnPress(),
          icon: SvgPicture.asset(
            'assets/icons/More.svg',
          ),
        ),
      )
    ],
    elevation: 0,
  );
}