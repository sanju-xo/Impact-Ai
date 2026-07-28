import 'package:flutter/material.dart';

Color primaryColor = "#7B69EE".toColor();
Color purpleColor = "#7B69EE".toColor();
Color backgroundColor = "#0F172A".toColor();
Color fontPrimary = ("#2A190D".toColor()).withOpacity(0.9);
Color accentColor = "#FE7225".toColor();
Color greyFont = "#616161".toColor();
Color greenColor = "#04B155".toColor();
Color redColor = "#DD3333".toColor();
Color indicatorColor = "#CED0D3".toColor();
Color itemGreyColor = "#E8E6E5".toColor();
Color orangeColor = accentColor.withOpacity(0.3);
Color detailHeaderColor = orangeColor;
Color edtBorderColor = "#525E7B".toColor();

Color cardColor = "#FFFBF8".toColor();
Color shadowColor = Colors.black12;

getFontColor(BuildContext context) {
  return getCurrentTheme(context).textTheme.titleMedium!.color;
}
getFontBlackColor(BuildContext context) {
  return getCurrentTheme(context).textTheme.titleLarge!.color;
}

getCardColor(BuildContext context) {
  return getCurrentTheme(context).cardColor;
}

getAccentColor(BuildContext context) {
  return getCurrentTheme(context).colorScheme.secondary;
}

getFontSkip(BuildContext context) {
  return getCurrentTheme(context).textTheme.titleSmall!.color;
}

getFontHint(BuildContext context) {
  return getCurrentTheme(context).hintColor;
}

ThemeData getCurrentTheme(BuildContext context) {
  return Theme.of(context);
}

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
