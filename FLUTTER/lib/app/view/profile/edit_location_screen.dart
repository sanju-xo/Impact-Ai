import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLocationScreen extends StatefulWidget {
  const EditLocationScreen({Key? key}) : super(key: key);

  @override
  State<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  LatLng _selectedLocation = LatLng(37.7749, -122.4194); // Default San Francisco coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(), // Empty container for the title (no search box)
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: markers,
            onTap: (LatLng position) {
              setState(() {
                _selectedLocation = position;
                markers.add(Marker(
                  markerId: MarkerId('selected_location'),
                  position: position,
                ));
              });
            },
          ),
          Positioned(
            top: 40, // Adjust position of button (now where the search bar was)
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Purple color for the button
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                saveLocationData(_selectedLocation.latitude, _selectedLocation.longitude);
              },
              child: Text(
                'Save Location',
                style: TextStyle(fontSize: 18, color: Colors.white), // White text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  void saveLocationData(double latitude, double longitude) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
    }).then((value) {
      print("Location updated successfully!");
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to update location: $error");
    });
  }
}
