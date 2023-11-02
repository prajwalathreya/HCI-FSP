import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(31.7749, -130.4194), // Initial map coordinates
          zoom: 6.0, // Zoom level
        ),
        onMapCreated: (GoogleMapController controller) {
          // You can use the controller to interact with the map.
        },
      ),
    );
  }
}