
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_place/google_place.dart';
// import 'package:fsp/MapUtils.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' show Polyline, PolylineId;
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PreviewScreen extends StatefulWidget {
//   final DetailsResult? startPosition;
//   final DetailsResult? endPosition;

//   const PreviewScreen({Key? key, this.startPosition, this.endPosition})
//       : super(key: key);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<PreviewScreen> {
//   late CameraPosition _initialPosition;
//   final Completer<GoogleMapController> _controller = Completer();
//   PolylineId _polylineId = PolylineId('polyline');
//   Set<Polyline> _polylines = {};

//   Future<List<LatLng>> getDirections() async {
//     final apiKey = 'AIzaSyDkKbK_K-0WJuhGvvSbmSL5pEoCiBSWNqY';
//     final apiUrl =
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startPosition!.geometry!.location!.lat},${widget.startPosition!.geometry!.location!.lng}&destination=${widget.endPosition!.geometry!.location!.lat},${widget.endPosition!.geometry!.location!.lng}&mode=bicycling&key=$apiKey';

//     final response = await http.get(Uri.parse(apiUrl));

//     if (response.statusCode == 200) {
//       final decodedResponse = json.decode(response.body);
//       List<LatLng> points = [];

//       if (decodedResponse['status'] == 'OK') {
//         for (var step in decodedResponse['routes'][0]['legs'][0]['steps']) {
//           points.add(LatLng(
//             step['start_location']['lat'],
//             step['start_location']['lng'],
//           ));
//           points.add(LatLng(
//             step['end_location']['lat'],
//             step['end_location']['lng'],
//           ));
//         }
//       }

//       return points;
//     } else {
//       throw Exception('Failed to load directions');
//     }
//   }

//   void _addPolyline() async {
//     List<LatLng> points = await getDirections();

//     _polylines.add(Polyline(
//       polylineId: _polylineId,
//       color: Colors.blue,
//       points: points,
//     ));

//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initialPosition = CameraPosition(
//       target: LatLng(widget.startPosition!.geometry!.location!.lat!,
//           widget.startPosition!.geometry!.location!.lng!),
//       zoom: 14.4746,
//     );
//     _addPolyline();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Set<Marker> _markers = {
//       Marker(
//           markerId: MarkerId('start'),
//           position: LatLng(widget.startPosition!.geometry!.location!.lat!,
//               widget.startPosition!.geometry!.location!.lng!),
//           icon:
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)),
//       Marker(
//           markerId: MarkerId('end'),
//           position: LatLng(widget.endPosition!.geometry!.location!.lat!,
//               widget.endPosition!.geometry!.location!.lng!))
//     };

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Preview"),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: CircleAvatar(
//             backgroundColor: Colors.blue,
//             child: const Icon(
//               Icons.arrow_back,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: _initialPosition,
//         markers: Set.from(_markers),
//         polylines: _polylines,
//         onMapCreated: (GoogleMapController controller) {
//           Future.delayed(
//             Duration(milliseconds: 200),
//             () => controller.animateCamera(
//               CameraUpdate.newLatLngBounds(
//                 MapUtils.boundsFromLatLngList(
//                   _markers.map((loc) => loc.position).toList(),
//                 ),
//                 30,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:fsp/MapUtils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show Polyline, PolylineId;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class PreviewScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? endPosition;

  const PreviewScreen({Key? key, this.startPosition, this.endPosition})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<PreviewScreen> {
  late CameraPosition _initialPosition;
  final Completer<GoogleMapController> _controller = Completer();
  List<Polyline> _polylines = [];

  Future<List<List<LatLng>>> getDirections() async {
    final apiKey = 'AIzaSyDkKbK_K-0WJuhGvvSbmSL5pEoCiBSWNqY';
    final apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startPosition!.geometry!.location!.lat},${widget.startPosition!.geometry!.location!.lng}&destination=${widget.endPosition!.geometry!.location!.lat},${widget.endPosition!.geometry!.location!.lng}&mode=bicycling&key=$apiKey&alternatives=true';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      List<List<LatLng>> routes = [];

      if (decodedResponse['status'] == 'OK') {
        for (var route in decodedResponse['routes']) {
          List<LatLng> points = [];

          for (var leg in route['legs']) {
            for (var step in leg['steps']) {
              points.add(LatLng(
                step['start_location']['lat'],
                step['start_location']['lng'],
              ));
              points.add(LatLng(
                step['end_location']['lat'],
                step['end_location']['lng'],
              ));
            }
          }

          routes.add(points);
        }
      }

      return routes;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void _addPolylines() async {
    List<List<LatLng>> routes = await getDirections();

    _polylines.clear(); // Clear previous polylines

    for (int i = 0; i < routes.length; i++) {
      PolylineId polylineId = PolylineId('polyline_$i');
      Color color = _getRandomColor();
      _polylines.add(Polyline(
        polylineId: polylineId,
        color: color,
        points: routes[i],
      ));
    }

    setState(() {});
  }
  Color _getRandomColor() {
  return Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0).withOpacity(1.0);
  }

  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!),
      zoom: 14.0,
    );
    _addPolylines();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> _markers = {
      Marker(
        markerId: MarkerId('start'),
        position: LatLng(
          widget.startPosition!.geometry!.location!.lat!,
          widget.startPosition!.geometry!.location!.lng!,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: MarkerId('end'),
        position: LatLng(
          widget.endPosition!.geometry!.location!.lat!,
          widget.endPosition!.geometry!.location!.lng!,
        ),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: CircleAvatar(
            backgroundColor: Colors.blue,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: Set.from(_markers),
        polylines: Set.from(_polylines),
        onMapCreated: (GoogleMapController controller) {
          Future.delayed(
            Duration(milliseconds: 200),
            () => controller.animateCamera(
              CameraUpdate.newLatLngBounds(
                MapUtils.boundsFromLatLngList(
                  _markers.map((loc) => loc.position).toList(),
                ),
                30,
              ),
            ),
          );
        },
      ),
    );
  }
}


