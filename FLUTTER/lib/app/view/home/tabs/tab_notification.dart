import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:impactai/base/color_data.dart';
import '../../../../base/resizer/fetch_pixels.dart';
import '../../../../base/widget_utils.dart';
import 'dart:math';

class TabNotification extends StatefulWidget {
  const TabNotification({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabNotification();
  }
}

class _TabNotification extends State<TabNotification> {
  List<Map<String, dynamic>> notificationList = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications from Firestore
  }

  Future<void> fetchNotifications() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Fetch all crash data
      QuerySnapshot snapshot = await firestore.collection('crash').get();

      if (snapshot.docs.isEmpty) {
        print("No crash data found.");
      } else {
        print("Fetched crash data successfully.");
      }

      setState(() {
        // Sorting the notifications by crash date and time (descending order)
        notificationList = snapshot.docs.map((doc) {
          return {
            'crash_address': doc['crash_address'] is String
                ? doc['crash_address']
                : 'Lat: ${doc['crash_address']['latitude']}, Lng: ${doc['crash_address']['longitude']}',
            'crash_date': doc['crash_date'] ?? 'Unknown Date',
            'crash_time': doc['crash_time'] ?? 'Unknown Time',
            'image': getRandomImage(), // Get random image for each notification
          };
        }).toList();

        // Sorting by date and time (descending order)
        notificationList.sort((a, b) {
          // Compare crash date and time in descending order
          DateTime dateA = DateTime.parse('${a['crash_date']} ${a['crash_time']}');
          DateTime dateB = DateTime.parse('${b['crash_date']} ${b['crash_time']}');
          return dateB.compareTo(dateA); // Descending order
        });

        // Limit to the most recent 10 notifications
        notificationList = notificationList.take(10).toList();
      });
    } catch (error) {
      print("Error fetching notifications: $error");
    }
  }

// Helper function to get random image
  String getRandomImage() {
    List<String> images = [
      'notification1.png',
      'notification2.png',
      'notification3.png',
      'notification4.png',
      'notification5.png',
      'notification6.png',
      'notification7.png',
      'notification8.png',
    ];
    Random random = Random();
    return images[random.nextInt(images.length)];
  }



  @override
  Widget build(BuildContext context) {
    double horSpace = FetchPixels.getDefaultHorSpace(context);

    return Column(
      children: [
        getVerSpace(FetchPixels.getPixelHeight(10)),
        topHeader(horSpace, "Crash Alerts", context),
        getVerSpace(FetchPixels.getPixelHeight(27)),
        buildExpanded(horSpace),
      ],
    );
  }

  Expanded buildExpanded(double horSpace) {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        itemCount: notificationList.length,
        primary: true,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          var modelDiscover = notificationList[index];
          String randomImage = 'notification${(index % 8) + 1}.png';

          return Container(
            width: double.infinity,
            height: FetchPixels.getPixelHeight(92),
            margin: EdgeInsets.symmetric(
                horizontal: horSpace, vertical: FetchPixels.getPixelHeight(10)),
            decoration: getButtonDecoration(
                getCurrentTheme(context).dialogBackgroundColor,
                corner: getButtonCorners(),
                withBorder: false,
                withCorners: true,
                shadow: [
                  BoxShadow(
                      color: getCurrentTheme(context).shadowColor,
                      offset: const Offset(-5, 6),
                      blurRadius: 40)
                ]),
            padding: EdgeInsets.symmetric(
                horizontal: horSpace, vertical: FetchPixels.getPixelHeight(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image of the notification (randomized)
                Container(
                  width: FetchPixels.getPixelHeight(60),
                  height: FetchPixels.getPixelHeight(60),
                  decoration: BoxDecoration(
                    image: getDecorationAssetImage(context, randomImage),
                  ),
                ),
                getHorSpace(FetchPixels.getPixelWidth(12)),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getCustomFont(
                        modelDiscover['crash_address'] ?? 'No Address', // Crash Address
                        16,
                        getFontColor(context),
                        1,
                        fontWeight: FontWeight.w600,
                      ),
                      getVerSpace(FetchPixels.getPixelHeight(5)),
                      getCustomFont(
                        modelDiscover['crash_date'] ?? 'No Date', // Crash Date
                        15,
                        getFontColor(context),
                        1,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                // Timestamp (crash_time)
                getCustomFont(
                  modelDiscover['crash_time'] ?? 'No Time', // Crash Time
                  15,
                  getFontSkip(context),
                  1,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
