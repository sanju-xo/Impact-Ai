import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/view/discover/CrashDetailPage.dart'; // Update import path if needed

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleCrashNotification(Map<String, dynamic> data) async {
  // 🔹 Fetch the most recent crash from Firestore
  try {
    var querySnapshot = await FirebaseFirestore.instance
        .collection("crash")
        .orderBy("crash_date", descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // 🔹 Navigate to CrashDetailPage (fetches latest data internally)
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const CrashDetailPage(),
        ),
      );
    } else {
      debugPrint("⚠️ No crash records found in Firestore.");
    }
  } catch (e) {
    debugPrint("❌ Error fetching crash data: ${e.toString()}");
  }
}
