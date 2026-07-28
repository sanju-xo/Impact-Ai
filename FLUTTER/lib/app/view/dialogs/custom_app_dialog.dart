import 'package:flutter/material.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/constant.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';

// ignore: must_be_immutable
class CustomAppDialog extends StatefulWidget {
  BuildContext context;
  Function onChanged;
  String image;
  String title;
  String desc;
  String btnTxt;
  bool withClose;

  @override
  _CustomAppDialog createState() {
    return _CustomAppDialog();
  }

  CustomAppDialog(this.context, this.onChanged, this.image, this.title,
      this.desc, this.btnTxt,
      {this.withClose = false, Key? key})
      : super(key: key);
}

class _CustomAppDialog extends State<CustomAppDialog> {
  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
          ),
          elevation: 0.0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: dialogContent(context, setState),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  dialogContent(BuildContext context, var setState) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
          horizontal: FetchPixels.getDefaultHorSpace(context)),
      padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelWidth(20)),
      decoration: BoxDecoration(
        color: getCurrentTheme(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          getVerSpace(FetchPixels.getPixelHeight(30)),
          buildClose(context),
          getSvgImageWithSize(context, widget.image,
              FetchPixels.getPixelHeight(96), FetchPixels.getPixelHeight(96)),
          getVerSpace(FetchPixels.getPixelHeight(32)),
          buildTitle(context),
          Visibility(
              child: getVerSpace(FetchPixels.getPixelHeight(10)),
              visible: widget.title.isNotEmpty),
          buildDesc(context),
          getVerSpace(FetchPixels.getPixelHeight(30)),
          buildButton(context)
        ],
      ),
    );
  }

  Visibility buildDesc(BuildContext context) {
    return Visibility(
        child: getMultilineCustomFont(widget.desc, 15, getFontColor(context),
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w400,
            txtHeight: 1.46),
        visible: widget.desc.isNotEmpty);
  }

  Visibility buildTitle(BuildContext context) {
    return Visibility(
        child: getCustomFont(widget.title, 22, getFontColor(context), 1,
            textAlign: TextAlign.center, fontWeight: FontWeight.w600),
        visible: widget.title.isNotEmpty);
  }

  Visibility buildClose(BuildContext context) {
    return Visibility(
      visible: widget.withClose,
      child: Align(
        alignment: Alignment.topRight,
        child: getCloseButton(context, () {
          Constant.backToPrev(context);
        }),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return getButton(
        context, getAccentColor(context), true, widget.btnTxt, Colors.white,
        () {
      Constant.backToPrev(context);
      widget.onChanged();
    }, EdgeInsets.only(bottom: FetchPixels.getPixelHeight(40)));
  }
}
