import 'package:flutter/material.dart';
import 'package:impactai/app/routes/app_routes.dart';
import 'package:impactai/app/view/home/tabs/tab_home.dart';
import 'package:impactai/app/view/home/tabs/tab_notification.dart';
import 'package:impactai/app/view/home/tabs/tab_more.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';
import '../../../base/Constant.dart';
import '../../../base/custom_animated_bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  int currentPos = 0;

  List<Widget> tabList = [
    const TabHome(),
    const TabHome(),
    const TabHome(),
    const TabNotification(),
    const TabMore(),
  ];

  @override
  void initState() {
    Future.delayed(
      Duration.zero,
          () {
        final arg = ModalRoute
            .of(context)!
            .settings
            .arguments as Map?;
        if (arg != null) {
          setState(() {
            currentPos = arg[Constant.homePos];
          });
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
      child: Scaffold(
        appBar: getInVisibleAppBar(),
        backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
        body: tabList[currentPos],
        bottomNavigationBar: CustomAnimatedBottomBar(
          containerHeight: FetchPixels.getPixelHeight(100),
          backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
          selectedIndex: currentPos,
          showElevation: true,
          itemCornerRadius: 24,
          curve: Curves.easeIn,
          totalItemCount: 5,
          onItemSelected: (index) {
            if (index == 1) {
              // Open support dialog on support button click
              showHomeDialog();
            } else if (index == 2) {
              // Do nothing when middle logo button is clicked
              // Simply return without any change
            } else {
              setState(() => currentPos = index);
            }
          },
          items: <BottomNavyBarItem>[
            BottomNavyBarItem(
              title: 'Home Page',
              activeColor: getAccentColor(context),
              inactiveColor: Colors.transparent,
              textAlign: TextAlign.center,
              iconSize: FetchPixels.getPixelHeight(24),
              imageName: "home.svg",
            ),
            BottomNavyBarItem(
              title: 'Support',
              activeColor: getAccentColor(context),
              inactiveColor: Colors.transparent,
              textAlign: TextAlign.center,
              iconSize: FetchPixels.getPixelHeight(24),
              imageName: "support.svg",
            ),
            BottomNavyBarItem(
              title: 'logo',
              activeColor: getAccentColor(context),
              inactiveColor: Colors.transparent,
              textAlign: TextAlign.center,
              iconSize: FetchPixels.getPixelHeight(24),
              imageName: "logo.svg",
            ),
            BottomNavyBarItem(
              title: 'Notifications Page',
              activeColor: getAccentColor(context),
              inactiveColor: Colors.transparent,
              textAlign: TextAlign.center,
              iconSize: FetchPixels.getPixelHeight(24),
              imageName: "notification.svg",
            ),
            BottomNavyBarItem(
              title: 'More Page',
              activeColor: getAccentColor(context),
              inactiveColor: Colors.transparent,
              textAlign: TextAlign.center,
              iconSize: FetchPixels.getPixelHeight(24),
              imageName: "more.svg",
            ),
          ],
        ),
      ),
      onWillPop: () async {
        Constant.closeApp();
        return false;
      },
    );
  }

  void showHomeDialog() {
    FetchPixels(context);
    double radius = FetchPixels.getPixelHeight(40);
    EdgeInsets edgeInsets = EdgeInsets.symmetric(
        horizontal: FetchPixels.getPixelWidth(20),
        vertical: FetchPixels.getPixelHeight(10));

    List<BoxShadow> shadow = [
      BoxShadow(
          color: getCurrentTheme(context).shadowColor,
          offset: const Offset(-5, 6),
          blurRadius: 40)
    ];

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: FetchPixels.getPixelHeight(327),
              child: Column(
                children: [
                  getVerSpace(FetchPixels.getPixelHeight(10)),
                  Center(child: getDialogDividerTop(context)),
                  getCustomFont(
                    "Please call any of these numbers.",
                    18,
                    getFontColor(context),
                    1,
                    fontWeight: FontWeight.w600,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        getVerSpace(FetchPixels.getPixelHeight(10)),
                        getButton(
                          context,
                          getCurrentTheme(context).dialogBackgroundColor,
                          true,
                          "+91 730 65 35 430",
                          getFontColor(context),
                              () => _launchPhone("+91 730 65 35 430"),
                          edgeInsets,
                          isBorder: false,
                          shadow: shadow,
                          borderColor: getAccentColor(context),
                        ),
                        getButton(
                          context,
                          getCurrentTheme(context).dialogBackgroundColor,
                          true,
                          "+91 948 34 43 452",
                          getFontColor(context),
                              () => _launchPhone("+91 948 34 43 452"),
                          edgeInsets,
                          isBorder: false,
                          shadow: shadow,
                          borderColor: getAccentColor(context),
                        ),
                        getButton(
                          context,
                          Colors.transparent,
                          true,
                          "Cancel",
                          getFontColor(context),
                              () => Constant.backToPrev(context),
                          edgeInsets,
                          isBorder: true,
                          shadow: shadow,
                          borderColor: getFontColor(context),
                        ),
                        getVerSpace(FetchPixels.getPixelHeight(20)),
                      ],
                    ),
                  ),
                  Center(child: getDialogDividerBottom(context)),
                  getVerSpace(FetchPixels.getPixelHeight(15)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _launchPhone(String phoneNumber) async {
    final String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}