import 'package:flutter/material.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/constant.dart';
import 'package:impactai/base/pref_data.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';

import '../../../base/flutter_pin_code_fields.dart';
import '../../routes/app_routes.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VerifyCodeScreen();
  }
}

class _VerifyCodeScreen extends State<VerifyCodeScreen> {
  void finish() {
    Constant.backToPrev(context);
  }

  TextEditingController newTextEditingController =
      TextEditingController(text: "123");
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: FetchPixels.getDefaultHorSpace(context)),
            primary: true,
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                buildWidgetBackButton(context),
                buildWidgetTitle(context),
                buildWidgetSubTitle(context),
                buildWidgetInputFields(context),
                buildWidgetVerifyButton(context),
                buildButtonResend(context)
              ],
            ),
          ),
        ),
        onWillPop: () async {
          finish();
          return false;
        });
  }

  Container buildButtonResend(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: FetchPixels.getPixelHeight(470)),
      child: InkWell(
        onTap: () {},
        child: getCustomFont("Resend", 16, getFontColor(context), 1,
            fontWeight: FontWeight.w400, textAlign: TextAlign.center),
      ),
    );
  }

  Widget buildWidgetVerifyButton(BuildContext context) {
    return getPaddingWidget(
        EdgeInsets.only(top: FetchPixels.getPixelHeight(370)),
        getButton(
            context, getAccentColor(context), true, "Verify", Colors.white, () {
          PrefData.setLogIn(true);
          Constant.sendToNext(context, Routes.homeScreenRoute);
        }, EdgeInsets.zero));
  }

  Widget buildWidgetInputFields(BuildContext context) {
    return getPaddingWidget(
      EdgeInsets.only(top: FetchPixels.getPixelHeight(230)),
      PinCodeFields(
        length: 4,
        fieldBorderStyle: FieldBorderStyle.square,
        controller: newTextEditingController,
        activeBorderColor: getFontSkip(context),
        padding: EdgeInsets.zero,
        responsive: false,
        focusNode: focusNode,
        textStyle: TextStyle(
          color: getFontColor(context),
          fontSize: 24,
          fontFamily: Constant.fontsFamily,
          fontWeight: FontWeight.w600,
        ),
        borderWidth: 1,
        borderColor: getFontSkip(context),
        borderRadius:
            BorderRadius.all(Radius.circular(FetchPixels.getPixelHeight(12))),
        fieldWidth: FetchPixels.getPixelHeight(70),
        fieldHeight: FetchPixels.getPixelHeight(70),
        onComplete: (result) {
        },
      ),
    );
  }

  Widget buildWidgetSubTitle(BuildContext context) {
    return getPaddingWidget(
        EdgeInsets.only(top: FetchPixels.getPixelHeight(160)),
        getCustomFont("Please enter verify code that we've sent to your email.",
            15, getFontColor(context), 2,
            fontWeight: FontWeight.w400));
  }

  Widget buildWidgetTitle(BuildContext context) {
    return getPaddingWidget(
        EdgeInsets.only(top: FetchPixels.getPixelHeight(121)),
        getCustomFont("Verify Code", 22, getFontColor(context), 1,
            fontWeight: FontWeight.w600));
  }

  Widget buildWidgetBackButton(BuildContext context) {
    return getPaddingWidget(
        EdgeInsets.only(top: FetchPixels.getPixelHeight(67)),
        getBackIcon(context, finish));
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
