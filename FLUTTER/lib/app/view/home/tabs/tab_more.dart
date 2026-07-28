import 'package:flutter/material.dart';
import 'package:impactai/app/routes/app_routes.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/constant.dart';
import 'package:impactai/base/pref_data.dart';
import 'package:impactai/base/restart_controller.dart';
import '../../../../base/resizer/fetch_pixels.dart';
import '../../../../base/widget_utils.dart';

class TabMore extends StatefulWidget {
  const TabMore({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabMore();
  }
}

class _TabMore extends State<TabMore> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    PrefData.getISDarkMode().then((value) {
      setState(() {
        isDarkMode = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double horSpace = FetchPixels.getDefaultHorSpace(context);

    return Column(
      children: [
        getVerSpace(FetchPixels.getPixelHeight(10)),
        topHeader(horSpace, "More Options", context, showProfile: false),
        getVerSpace(FetchPixels.getPixelHeight(27)),
        buildExpanded(context),
        buildButton(context),
        getVerSpace(FetchPixels.getPixelHeight(30))
      ],
    );
  }

  Widget buildButton(BuildContext context) {
    return getButton(
        context,
        getAccentColor(context),
        true,
        "Log out",
        Colors.white,
            () {
          PrefData.setLogIn(false);
          Constant.sendToNext(context, Routes.homeRoute);
        },
        EdgeInsets.symmetric(
            horizontal: FetchPixels.getPixelWidth(20),
            vertical: FetchPixels.getPixelHeight(10)
        )
    );
  }

  Expanded buildExpanded(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: true,
        children: [
          getSettingRow(context, "user.svg", "Profile", () {
            Constant.sendToNext(context, Routes.editProfileScreenRoute);
          }),
          getSettingRow(context, "location.svg", "Location", () {
            Constant.sendToNext(context, Routes.editLocationScreenRoute);
          }),
          getSettingRow(
              context,
              "dark.svg",
              "Dark Mode",
                  () {},
              withSwitch: true,
              onToggle: (boolVal) {
                setState(() {
                  isDarkMode = boolVal;
                });
                PrefData.setDarkMode(boolVal);
                RestartController.rebirth(context);
              },
              checked: isDarkMode
          ),
        ],
      ),
    );
  }

  Widget getTitles(String string) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
      child: getCustomFont(
          string,
          15,
          getFontColor(context),
          1,
          fontWeight: FontWeight.w400
      ),
    );
  }
}
