import 'package:flutter/material.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';
import 'package:impactai/base/constant.dart';
import 'package:impactai/base/color_data.dart';

class CallSupportScreen extends StatelessWidget {
  const CallSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return Scaffold(
      backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: getCurrentTheme(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: getSvgImageWithSize(context, "arrow_left.svg", FetchPixels.getPixelHeight(24), FetchPixels.getPixelHeight(24)),
          onPressed: () {
            Constant.backToPrev(context);
          },
        ),
      ),
      body: Center(
        child: getCustomFont("Coming Soon", 20, getFontColor(context), 1, fontWeight: FontWeight.w600),
      ),
    );
  }
}
