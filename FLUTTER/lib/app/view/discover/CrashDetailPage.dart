import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrashDetailPage extends StatefulWidget {
  const CrashDetailPage({Key? key}) : super(key: key);

  @override
  _CrashDetailPageState createState() => _CrashDetailPageState();
}

class _CrashDetailPageState extends State<CrashDetailPage> {
  String? crashId;
  double? latitude;
  double? longitude;
  String? crashDate;
  String? crashTime;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestCrash();
  }

  /// Fetches the latest crash sorted by date and time
  Future<void> _fetchLatestCrash() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("crash")
          .orderBy("crash_date", descending: true)
          .orderBy("crash_time", descending: true)
          .orderBy(FieldPath.documentId, descending: false) // Equivalent to "__name__" in Firestore
          .limit(10)
          .get();


      if (querySnapshot.docs.isNotEmpty) {
        var latestCrash = querySnapshot.docs.first.data();
        setState(() {
          crashId = querySnapshot.docs.first.id;
          latitude = latestCrash["crash_address"]["latitude"] ?? 0.0;
          longitude = latestCrash["crash_address"]["longitude"] ?? 0.0;
          crashDate = latestCrash["crash_date"] ?? "Unknown Date";
          crashTime = latestCrash["crash_time"] ?? "Unknown Time";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No crash records found!")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching crash data: ${e.toString()}")),
      );
    }
  }

  /// Marks the crash as resolved in Firestore
  Future<void> _resolveCrash() async {
    if (crashId == null) return;

    try {
      await FirebaseFirestore.instance.collection("crash").doc(crashId).update({"resolved": "yes"});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Crash marked as resolved!")),
      );
      Navigator.pop(context); // Close the page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crash Details"),
        actions: [
          if (!isLoading)
            ElevatedButton(
              onPressed: _resolveCrash,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 🔴 Visible button
                foregroundColor: Colors.white,
              ),
              child: const Text("MARK RESOLVED"),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔄 Show loading indicator
          : crashId == null
          ? const Center(child: Text("❌ No crash records available!"))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📌 Crash ID: $crashId",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("📅 Date: $crashDate", style: const TextStyle(fontSize: 16)),
                Text("⏰ Time: $crashTime", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude ?? 0, longitude ?? 0),
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(latitude ?? 0, longitude ?? 0),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
