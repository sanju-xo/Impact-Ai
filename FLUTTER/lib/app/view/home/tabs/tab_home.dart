import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:impactai/app/data/news_service.dart';
import 'package:impactai/app/models/model_trending.dart';
import 'package:impactai/base/color_data.dart';
import 'package:impactai/base/device_util.dart';
import 'package:impactai/base/resizer/fetch_pixels.dart';
import 'package:impactai/base/widget_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:impactai/app/view/home/news_list_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class TabHome extends StatefulWidget {
  const TabHome({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabHome();
  }
}

class _TabHome extends State<TabHome> {
  List<ModelTrending> trendingList = [];
  bool isLoading = true;
  int activeAccidents = 0;
  int resolvedAccidents = 0;
  int oneDayCrashes = 0;
  int oneWeekCrashes = 0;
  int oneMonthCrashes = 0;


  @override
  void initState() {
    super.initState();
    fetchNews();
    fetchCrashData();
  }

  Future<void> fetchNews() async {
    try {
      List<ModelTrending> news = await NewsService.fetchNews();
      setState(() {
        trendingList = news;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCrashData() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('crash').get();

      print("📌 Total documents found: ${snapshot.docs.length}"); // Debug print

      int active = 0;
      int resolved = 0;

      int past1Day = 0;
      int past1Week = 0;
      int past1Month = 0;

      DateTime now = DateTime.now();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('resolved')) {
          String resolvedStatus = data['resolved'].toString().toLowerCase();

          if (resolvedStatus == "yes") {
            resolved++;
          } else {
            active++;
          }
        }

        /// ✅ **Categorizing based on `crash_date`**
        if (data.containsKey('crash_date')) {
          try {
            DateTime crashDate = DateTime.parse(data['crash_date']); // Convert to DateTime
            Duration difference = now.difference(crashDate);

            if (difference.inDays == 0) {
              past1Day++;
            } else if (difference.inDays <= 7) {
              past1Week++;
            } else if (difference.inDays <= 30) {
              past1Month++;
            }
          } catch (e) {
            print("⚠️ Error parsing crash_date for document ${doc.id}: $e");
          }
        }
      }

      setState(() {
        activeAccidents = active;
        resolvedAccidents = resolved;
        oneDayCrashes = past1Day;
        oneWeekCrashes = past1Week;
        oneMonthCrashes = past1Month;
      });

      print("🔥 Updated Crash Data -> 1 Day: $oneDayCrashes, 1 Week: $oneWeekCrashes, 1 Month: $oneMonthCrashes");
    } catch (e) {
      print("⚠️ Error fetching crash data: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
    double horSpace = FetchPixels.getDefaultHorSpace(context);
    double verSpace = FetchPixels.getPixelHeight(20);
    int minVal = kIsWeb ? 8 : (DeviceUtil.isTablet ? 6 : 3);

    return ListView(
      primary: true,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        getVerSpace(FetchPixels.getPixelHeight(10)),
        buildTopHeader(horSpace, "Welcome Back", context), // ✅ Profile picture added
        getVerSpace(verSpace),
        buildRow(horSpace, context),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : trendingList.isEmpty
            ? Center(child: Text("No news available"))
            : widgetTrendingList(verSpace, minVal, horSpace),
        buildStatisticsSection(),
      ],
    );
  }

  /// ✅ **Top Header with Profile Picture**
  Row buildTopHeader(double horSpace, String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horSpace),
          child: getCustomFont(title, 24, getFontColor(context), 1, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: EdgeInsets.only(right: horSpace),
          child: CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage("assets/images/Profile.png"),
          ),
        ),
      ],
    );
  }

  Row buildRow(double horSpace, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        getHorSpace(horSpace),
        getCustomFont("Trending News", 20, getFontColor(context), 1, fontWeight: FontWeight.w600),
        Expanded(child: getHorSpace(0)),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsListScreen()));
          },
          child: getCustomFont("View All", 13, getFontSkip(context), 1, fontWeight: FontWeight.w600),
        ),
        getHorSpace(FetchPixels.getDefaultHorSpace(context)),
      ],
    );
  }


  Column buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getVerSpace(FetchPixels.getPixelHeight(20)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: FetchPixels.getDefaultHorSpace(context)),
          child: getCustomFont("Statistics", 20, getFontColor(context), 1, fontWeight: FontWeight.w600),
        ),
        getVerSpace(FetchPixels.getPixelHeight(10)),

        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: [
                oneDayCrashes,
                oneWeekCrashes,
                oneMonthCrashes,
              ].reduce(max).toDouble() + 2, // Add padding for visual space
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return Text("1 Day");
                        case 1:
                          return Text("1 Week");
                        case 2:
                          return Text("1 Month");
                        default:
                          return Text('');
                      }
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(toY: oneDayCrashes.toDouble(), color: Colors.red, width: 18),
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(toY: oneWeekCrashes.toDouble(), color: Colors.orange, width: 18),
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(toY: oneMonthCrashes.toDouble(), color: Colors.blue, width: 18),
                ]),
              ],
            ),
          ),
        ),


        getVerSpace(FetchPixels.getPixelHeight(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            indicatorBox(Colors.red, "1 Day"),
            indicatorBox(Colors.orange, "1 Week"),
            indicatorBox(Colors.blue, "1 Month"),
          ],
        ),

        getVerSpace(FetchPixels.getPixelHeight(20)),


        buildTransparentStatistics(),
      ],
    );
  }

  /// ✅ **Helper Widget for Pie Chart Labels**
  Widget indicatorBox(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }


  /// ✅ **Transparent Statistics Boxes with Dynamic Data**
  Widget buildTransparentStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        transparentBox(Colors.red, "Active Accidents: $activeAccidents"),
        transparentBox(Colors.green, "Resolved Accidents: $resolvedAccidents"),
      ],
    );
  }

  /// 📌 **Helper Widget for Transparent Boxes with Colored Borders**
  Widget transparentBox(Color borderColor, String label) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(color: borderColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
  SizedBox widgetTrendingList(double verSpace, int minVal, double horSpace) {
    return SizedBox(
      width: double.infinity,
      height: FetchPixels.getPixelHeight(250) + (verSpace * 2),
      child: ListView.builder(
        itemCount: min(minVal, trendingList.length),
        shrinkWrap: true,
        primary: false,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          ModelTrending news = trendingList[index];

          return Container(
            width: FetchPixels.getPixelHeight(320),
            padding: EdgeInsets.symmetric(horizontal: FetchPixels.getPixelHeight(14)),
            margin: EdgeInsets.symmetric(horizontal: horSpace / 2, vertical: verSpace),
            decoration: getButtonDecoration(
              getCurrentTheme(context).dialogBackgroundColor,
              withCorners: true,
              corner: FetchPixels.getPixelHeight(12),
              withBorder: false,
              shadow: [
                BoxShadow(
                    color: getCurrentTheme(context).shadowColor,
                    offset: const Offset(-5, 6),
                    blurRadius: 40)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(FetchPixels.getPixelHeight(12))),
                  child: Image.network(
                    news.image,
                    width: double.infinity,
                    height: FetchPixels.getPixelHeight(191),
                    fit: BoxFit.cover,
                  ),
                ),
                getVerSpace(FetchPixels.getPixelHeight(10)),
                getCustomFont(news.headline, 16, getFontColor(context), 1, fontWeight: FontWeight.w600),
              ],
            ),
          );
        },
      ),
    );
  }

}
