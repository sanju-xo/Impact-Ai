import 'package:flutter/material.dart';
import 'package:impactai/app/data/data_file.dart';
import 'package:impactai/app/models/model_intro.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/generated/l10n.dart';

import '../../base/constant.dart';
import '../../base/resizer/fetch_pixels.dart';
import '../../base/widget_utils.dart';
import '../routes/app_routes.dart';

class IntroView extends StatefulWidget {
  const IntroView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IntroView();
  }
}

class _IntroView extends State<IntroView> {
  void backClick() {
    Constant.backToPrev(context);
  }

  ValueNotifier selectedPage = ValueNotifier(0);
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
        child: Scaffold(
          backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
          body: Stack(children: [
            buildPageView(),
            buildIndicator(),
            buildNextButton(context),
            buildLoginButton(),
          ]),
        ),
        onWillPop: () async {
          backClick();
          return false;
        });
  }

  ValueListenableBuilder<dynamic> buildLoginButton() {
    return ValueListenableBuilder(
      builder: (context, value, child) {
        return (selectedPage.value != DataFile.introList.length - 1)
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: FetchPixels.getPixelHeight(796)),
                child: InkWell(
                  onTap: () {
                    Constant.sendToNext(context, Routes.loginRoute);
                  },
                  child: getCustomFont(
                      S.of(context).skip, 16, getFontSkip(context), 1,
                      fontWeight: FontWeight.w400, textAlign: TextAlign.center),
                ))
            : Padding(
                padding: EdgeInsets.only(
                    left: FetchPixels.getPixelWidth(20),
                    right: FetchPixels.getPixelWidth(20),
                    top: FetchPixels.getPixelHeight(778)),
                child: getButton(
                  context,
                  Colors.transparent,
                  true,
                  S.of(context).login,
                  getFontColor(context),
                  () {
                    Constant.sendToNext(context, Routes.loginRoute);
                  },
                  EdgeInsets.zero,
                  isBorder: true,
                  borderColor: getFontColor(context),
                ));
      },
      valueListenable: selectedPage,
    );
  }

  ValueListenableBuilder buildNextButton(BuildContext context) {
    return ValueListenableBuilder(
      builder: (context, value, child) {
        return (selectedPage.value != DataFile.introList.length - 1)
            ? Padding(
                padding: EdgeInsets.only(
                    left: FetchPixels.getPixelWidth(20),
                    right: FetchPixels.getPixelWidth(20),
                    top: FetchPixels.getPixelHeight(698)),
                child: getButton(context, getAccentColor(context), true,
                    S.of(context).next, Colors.white, () {
                  selectedPage.value = selectedPage.value + 1;
                  _controller.jumpToPage(selectedPage.value);
                }, EdgeInsets.zero),
              )
            : Padding(
                padding: EdgeInsets.only(
                    left: FetchPixels.getPixelWidth(20),
                    right: FetchPixels.getPixelWidth(20),
                    top: FetchPixels.getPixelHeight(698)),
                child: getButton(context, getAccentColor(context), true,
                    S.of(context).signUp, Colors.white, () {
                  Constant.sendToNext(context, Routes.loginRoute,
                      arguments: {Constant.fromLogin: false});
                }, EdgeInsets.zero),
              );
      },
      valueListenable: selectedPage,
    );
  }

  Padding buildIndicator() {
    return Padding(
      padding: EdgeInsets.only(
          left: FetchPixels.getPixelWidth(183),
          right: FetchPixels.getPixelWidth(183),
          top: FetchPixels.getPixelHeight(650)),
      child: ValueListenableBuilder(
        valueListenable: selectedPage,
        builder: (context, value, child) {
          return SizedBox(
            height: FetchPixels.getPixelHeight(8),
            child: DotsIndicator(
              controller: _controller,
              selectedColor: getAccentColor(context),
              itemCount: DataFile.introList.length,
              selectedPos: selectedPage.value,
              color: indicatorColor,
              onPageSelected: (int page) {},
            ),
          );
        },
      ),
    );
  }

  TextStyle getFontStyleWithColor({bool isSubTitle = false}) {
    return TextStyle(
        fontFamily: Constant.fontsFamily,
        fontSize: 28,
        color: (isSubTitle) ? "#C6C3FF".toColor() : getFontColor(context),
        fontWeight: FontWeight.bold,
        height: 1.46,
        fontStyle: FontStyle.normal);
  }

  getTitle1() {
    return Text.rich(
      TextSpan(
          text: '🔴 Detect, Alert & Save',
          style: getFontStyleWithColor(),
          children: <InlineSpan>[
            TextSpan(
              text: ' Lives',
              style: getFontStyleWithColor(isSubTitle: true),
            )
          ]),
      textScaleFactor: FetchPixels.getTextScale(),
      textAlign: TextAlign.center,
    );
  }

  getTitle2() {
    return Text.rich(
      TextSpan(
          text: '🟢 Smart Crash Detection,',
          style: getFontStyleWithColor(),
          children: <InlineSpan>[
            TextSpan(
              text: '\nInstant',
              style: getFontStyleWithColor(isSubTitle: true),
            ),
            TextSpan(
              text: ' Alerts',
              style: getFontStyleWithColor(),
            )
          ]),
      textScaleFactor: FetchPixels.getTextScale(),
      textAlign: TextAlign.center,
    );
  }

  getTitle3() {
    return Text.rich(
      TextSpan(
          text: '🔵 AI That Watches Over',
          style: getFontStyleWithColor(),
          children: <InlineSpan>[
            TextSpan(
              text: ' You',
              style: getFontStyleWithColor(isSubTitle: true),
            )
          ]),
      textScaleFactor: FetchPixels.getTextScale(),
      textAlign: TextAlign.center,
    );
  }

  PageView buildPageView() {
    List<Widget> widgetList = [getTitle1(), getTitle2(), getTitle3()];
    return PageView.builder(
      controller: _controller,
      onPageChanged: (value) {
        selectedPage.value = value;
      },
      itemCount: DataFile.introList.length,
      itemBuilder: (context, index) {
        ModelIntro _introModel = DataFile.introList[index];
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: FetchPixels.getPixelWidth(330),
              height: FetchPixels.getPixelHeight(330),
              margin: EdgeInsets.only(
                  top: FetchPixels.getPixelHeight(90),
                  left: FetchPixels.getPixelWidth(42),
                  right: FetchPixels.getPixelWidth(42)),
              decoration: BoxDecoration(
                  image: getDecorationAssetImage(
                      context, _introModel.image ?? "")),
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: FetchPixels.getPixelWidth(20),
                    right: FetchPixels.getPixelWidth(20),
                    top: FetchPixels.getPixelHeight(450)),
                child: widgetList[index]
                ),
            Padding(
                padding: EdgeInsets.only(
                    left: FetchPixels.getPixelWidth(20),
                    right: FetchPixels.getPixelWidth(20),
                    top: FetchPixels.getPixelHeight(548)),
                // top: 548 / mockupHeight * height),
                child: getCustomFont(
                    _introModel.description ?? "", 15, getFontColor(context), 2,
                    fontWeight: FontWeight.w400, textAlign: TextAlign.center)),
          ],
        );
      },
    );
  }
}

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({Key? key,
    this.controller,
    this.itemCount,
    this.selectedPos,
    this.onPageSelected,
    this.selectedColor = Colors.black,
    this.color= Colors.white,
  }) : super(key: key, listenable: controller!);

  /// The PageController that this DotsIndicator is representing.
  final PageController? controller;

  /// The number of items managed by the PageController
  final int? itemCount;
  final int? selectedPos;

  /// Called when a dot is tapped
  final ValueChanged<int>? onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;
  final Color selectedColor;

  Widget _buildDot(int index) {
    return Expanded(
      child: SizedBox(
        width: FetchPixels.getPixelWidth(2),
        child: Center(
          child: Material(
            color: (selectedPos == index) ? selectedColor : color,
            type: MaterialType.circle,
            child: SizedBox(
              width: FetchPixels.getPixelHeight(8),
              height: FetchPixels.getPixelHeight(8),
              child: InkWell(
                onTap: () => onPageSelected!(index),
              ),
            ),
          ),
        ),
      ),
      flex: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount!, _buildDot),
    );
  }
}
