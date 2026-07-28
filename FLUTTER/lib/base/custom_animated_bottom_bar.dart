import 'package:flutter/material.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';

// ignore: must_be_immutable
class CustomAnimatedBottomBar extends StatelessWidget {
  CustomAnimatedBottomBar(
      {Key? key,
      this.selectedIndex = 0,
      this.showElevation = true,
      this.iconSize = 24,
      this.backgroundColor,
      this.itemCornerRadius = 50,
      this.containerHeight = 56,
      this.animationDuration = const Duration(milliseconds: 270),
      this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
      required this.items,
      required this.onItemSelected,
      this.curve = Curves.linear,
      this.totalItemCount = 1})
      : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  final int selectedIndex;
  final double iconSize;
  final Color? backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double itemCornerRadius;
  final double containerHeight;
  final Curve curve;
  int totalItemCount;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).splashColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          if (showElevation)
              BoxShadow(
                  color: getCurrentTheme(context).shadowColor,
                  offset: const Offset(0, -13),
                  blurRadius: 44)
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: containerHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items.map((item) {
              var index = items.indexOf(item);
              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: _ItemWidget(
                  item: item,
                  containerHeight: containerHeight,
                  iconSize: iconSize,
                  isSelected: index == selectedIndex,
                  backgroundColor: bgColor,
                  itemCornerRadius: itemCornerRadius,
                  animationDuration: animationDuration,
                  curve: curve,
                  totalItem: totalItemCount,
                  index: index,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final double containerHeight;
  final Duration animationDuration;
  final Curve curve;
  final int totalItem;
  final int index;

  const _ItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.backgroundColor,
    required this.animationDuration,
    required this.itemCornerRadius,
    required this.containerHeight,
    required this.iconSize,
    required this.totalItem,
    required this.index,
    this.curve = Curves.linear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);

    double width = MediaQuery.of(context).size.width / totalItem;

    return Semantics(
      container: true,
      selected: isSelected,
      child: AnimatedContainer(
        height: double.maxFinite,
        duration: animationDuration,
        curve: curve,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            width: width,
            color: backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: FetchPixels.getPixelHeight(44),
                  height: FetchPixels.getPixelHeight(44),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (index == 2)
                          ? getAccentColor(context)
                          : isSelected
                              ? getCardColor(context)
                              : Colors.transparent),
                  child: Center(
                      child: getSvgImageWithSize(context, item.imageName ?? "",
                          item.iconSize ?? 0, item.iconSize ?? 0)),
                ),
                getVerSpace(FetchPixels.getPixelHeight(8)),
                Icon(
                  Icons.circle,
                  size: FetchPixels.getPixelHeight(4),
                  color: (isSelected && index != 2)
                      ? getFontColor(context)
                      : Colors.transparent,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({
    this.activeColor = Colors.blue,
    this.textAlign,
    this.inactiveColor,
    this.imageName,
    this.iconSize,
    this.title,
  });

  final Color activeColor;
  final Color? inactiveColor;
  final TextAlign? textAlign;
  final String? imageName;
  final String? title;
  final double? iconSize;
}
