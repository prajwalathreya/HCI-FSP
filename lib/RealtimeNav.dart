// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:math' show pi, log, tan, atan2,min,max;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_tts/flutter_tts.dart';

// class RealtimeNav extends StatefulWidget {
//   final LatLng startLocation;
//   final LatLng destination;
//   final StreamController<LatLng> locationUpdateController;

//   RealtimeNav({
//     required this.startLocation,
//     required this.destination,
//     required this.locationUpdateController,
//   });

//   @override
//   _RealtimeNavState createState() =>
//       _RealtimeNavState(locationUpdateController: locationUpdateController);
// }

// class _RealtimeNavState extends State<RealtimeNav> {
//   GoogleMapController? _controller;
//   final StreamController<LatLng> locationUpdateController;
//   LatLng _currentLocation = LatLng(0.0, 0.0);
//   bool _isSatelliteView = false;
//   bool _showBusStops = false;
//   Set<Polyline> _polylines = {};
//   Set<Marker> _busStopMarkers = {};
//   bool _isNightMode = false; // for night mode
//   FlutterTts flutterTts = FlutterTts();
//   bool isMuted = false;

//   late StreamSubscription<Position> _positionStream;

//   _RealtimeNavState({required this.locationUpdateController});

//   @override
//   void initState() {
//     super.initState();

//     // Subscribe to location updates
//     _positionStream = Geolocator.getPositionStream(
//       desiredAccuracy: LocationAccuracy.best,
//       distanceFilter: 5, // Update every 10 meters
//     ).listen((Position position) {
//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//       });
//       _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
//     });

//     widget.locationUpdateController.stream.listen((location) async {
//       setState(() {
//         _currentLocation = location;
//       });
//       _controller?.animateCamera(CameraUpdate.newLatLng(location));
//       //configuring text to speech
//       flutterTts.setStartHandler(() {
//         print("Text to speech started");
//       });
//       flutterTts.setCompletionHandler(() {
//         print("Text to speech completed");
//       });
//       flutterTts.setErrorHandler((msg) {
//         print("Text to speech Error: $msg");
//        });
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // Cancel the location updates stream when the widget is disposed
//     _positionStream.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Bike Navigation"),
//       ),
//       body: FutureBuilder(
//         future: Future.delayed(Duration(milliseconds: 500)),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return _buildMap();
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _zoomIn,
//             child: Icon(Icons.zoom_in),
//           ),
//           SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: _zoomOut,
//             child: Icon(Icons.zoom_out),
//           ),
//           SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: _recenter,
//             child: Icon(Icons.my_location),
//           ),
//           SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: () {
//               setState(() {
//                 _isNightMode = !_isNightMode;
//               });
//             },
//             child: Icon(
//                 _isNightMode ? Icons.nightlight_round : Icons.wb_sunny),
//           ),
//           SizedBox(height: 16),
//           FloatingActionButton(
//             onPressed: () {
//               // Add your SOS button logic here
//               _showSOSDialog();
//             },
//             backgroundColor: Colors.red,
//             child: Text(
//               'SOS',
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//             // child: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }

//   Widget _buildMap() {
//     return Stack(
//       children: [
//         Padding(
//           padding: EdgeInsets.only(bottom: 7.0, left: 5.0),
//           child: GoogleMap(
//             onMapCreated: (controller) {
//               _controller = controller;
//             },
//             initialCameraPosition: CameraPosition(
//               target: widget.startLocation,
//               zoom: 15.0,
//             ),
//             markers: {
//               Marker(
//                 markerId: MarkerId('start'),
//                 position: widget.startLocation,
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueBlue,
//                 ),
//               ),
//               Marker(
//                 markerId: MarkerId('destination'),
//                 position: widget.destination,
//                 infoWindow: InfoWindow(title: 'Destination'),
//               ),
//               Marker(
//                 markerId: MarkerId('currentLocation'),
//                 position: _currentLocation,
//                 infoWindow: InfoWindow(title: 'Current Location'),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueBlue,
//                 ),
//               ),
//               ..._busStopMarkers,
//             },
//             mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
//             polylines: _polylines,
//             onCameraMove: (CameraPosition position) {
//               // You can add logic to handle camera movement if needed
//             },
//             myLocationButtonEnabled: false,
//           ),
//         ),
//         Positioned(
//           top: 20.0,
//           right: 20.0,
//           child: Column(
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _isSatelliteView = !_isSatelliteView;
//                   });
//                   _recenter();
//                 },
//                 child: Text(
//                   _isSatelliteView
//                       ? 'Switch to Map View'
//                       : 'Switch to Satellite View',
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _startBikeNavigation();
//                   setState(() {
//                     _showBusStops = true;
//                   });
//                   _getBusStops();
//                 },
//                 child: Text('Bike Path Navigation'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _showBusStops = true;
//                   });
//                   _getBusStops();
//                 },
//                 child: Text('Get Bus Stops'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//----------------------------testing
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show pi, log, tan, atan2, min, max;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RealtimeNav extends StatefulWidget {
  final LatLng startLocation;
  final LatLng destination;
  final StreamController<LatLng> locationUpdateController;

  RealtimeNav({
    required this.startLocation,
    required this.destination,
    required this.locationUpdateController,
  });

  @override
  _RealtimeNavState createState() =>
      _RealtimeNavState(locationUpdateController: locationUpdateController);
}

class _RealtimeNavState extends State<RealtimeNav> {
  GoogleMapController? _controller;
  final StreamController<LatLng> locationUpdateController;
  LatLng _currentLocation = LatLng(0.0, 0.0);
  bool _isSatelliteView = false;
  bool _showBusStops = false;
  Set<Polyline> _polylines = {};
  Set<Marker> _busStopMarkers = {};
  bool _isNightMode = false; // for night mode
  FlutterTts flutterTts = FlutterTts();
  bool isMuted = false;
  bool _hasNavigationStarted = false;

  late StreamSubscription<Position> _positionStream;

  _RealtimeNavState({required this.locationUpdateController});

  @override
  void initState() {
    super.initState();

    // Subscribe to location updates
    _positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
      distanceFilter: 100, // Update every 5 meters
    ).listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    });

    widget.locationUpdateController.stream.listen((location) async {
      setState(() {
        _currentLocation = location;
      });
      _controller?.animateCamera(CameraUpdate.newLatLng(location));

      // Configure text to speech only once
      flutterTts.setStartHandler(() {
        print("Text to speech started");
      });
      flutterTts.setCompletionHandler(() {
        print("Text to speech completed");
      });
      flutterTts.setErrorHandler((msg) {
        print("Text to speech Error: $msg");
      });

      // Start navigation directions
      if (!_isNightMode && !_showBusStops) {
        _speakNavigationDirections();
      }
    });
  }

  @override
  void dispose() {
    // Cancel the location updates stream when the widget is disposed
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bike Navigation"),
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 500)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildMap();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoomInButton',
            onPressed: _zoomIn,
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'zoomOutButton',
            onPressed: _zoomOut,
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'recenterButton',
            onPressed: _recenter,
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'themeButton',
            onPressed: () {
              setState(() {
                _isNightMode = !_isNightMode;
                isMuted = false; // Reset mute state when switching modes
              });
              if (!_isNightMode && !_showBusStops) {
                _speakNavigationDirections();
              } else {
                flutterTts
                    .stop(); // Stop speech if in night mode or showing bus stops
              }
            },
            child: Icon(_isNightMode ? Icons.wb_sunny : Icons.nightlight_round),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'sosButton',
            onPressed: () {
              // Add your SOS button logic here
              _showSOSDialog();
            },
            backgroundColor: Colors.red,
            child: Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'audioButton',
            onPressed: () {
              setState(() {
                isMuted = !isMuted;
                if (isMuted) {
                  flutterTts.stop();
                } else {
                  _speakNavigationDirections();
                }
              });
            },
            child: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 7.0, left: 5.0),
          child: GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
              if (!_hasNavigationStarted) {
                _startBikeNavigation();
                //_recenter();
                _hasNavigationStarted = true;
              }
            },
            initialCameraPosition: CameraPosition(
              target: widget.startLocation,
              zoom: 15.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('start'),
                position: widget.startLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
              Marker(
                markerId: MarkerId('destination'),
                position: widget.destination,
                infoWindow: InfoWindow(title: 'Destination'),
              ),
              Marker(
                markerId: MarkerId('currentLocation'),
                position: _currentLocation,
                infoWindow: InfoWindow(title: 'Current Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
              ),
              ..._busStopMarkers,
            },
            mapType: _isSatelliteView ? MapType.satellite : MapType.normal,
            polylines: _polylines,
            onCameraMove: (CameraPosition position) {
              // You can add logic to handle camera movement if needed
            },
            myLocationButtonEnabled: false,
          ),
        ),
        Positioned(
          top: 20.0,
          right: 20.0,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSatelliteView = !_isSatelliteView;
                  });
                  _recenter();
                },
                child: Text(
                  _isSatelliteView
                      ? 'Switch to Map View'
                      : 'Switch to Satellite View',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showBusStops = true;
                  });
                  _getBusStops();
                },
                child: Text('Get Bus Stops'),
              ),
            ],
          ),
        ),
      ],
    );
  }

//--------------------till here
  void _recenter() async {
    final GoogleMapController controller = _controller!;
    double bearing = _calculateBearing(
      widget.startLocation.latitude,
      widget.startLocation.longitude,
      widget.destination.latitude,
      widget.destination.longitude,
    );

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _currentLocation.latitude,
        _currentLocation.longitude,
      ),
      northeast: widget.destination,
    );

    double padding = 50.0;

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
      bounds,
      padding,
    );

    controller.animateCamera(cameraUpdate);
    double tilt = _calculateTilt(bearing);
    Future.delayed(Duration(milliseconds: 500), () {
      double tilt = _calculateTilt(bearing);
      if (_isSatelliteView || _isNightMode) {
        // For satellite view, set tilt to 0
        tilt = 45.0;
      }
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: widget.startLocation,
        zoom: 14.0,
        bearing: bearing,
        tilt: tilt,
      )));
    });
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("SOS"),
          content: Text("Do you want to call 911?"),
          actions: [
            TextButton(
              onPressed: () {
                // Handle "Yes" button click
                print("Calling 911...");
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                // Handle "No" button click
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _startBikeNavigation() async {
    if (!_isNightMode && !_showBusStops) {
      _speakNavigationDirections();
    }

    // Existing code...
    const apiKey =
        'AIzaSyDkKbK_K-0WJuhGvvSbmSL5pEoCiBSWNqY'; // Replace with your API key
    final origin =
        '${widget.startLocation.latitude},${widget.startLocation.longitude}';
    final destination =
        '${widget.destination.latitude},${widget.destination.longitude}';
    final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$origin&destination=$destination&mode=bicycling&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final List<LatLng> points =
            _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        Polyline polyline = Polyline(
          polylineId: PolylineId('bikePath'),
          color: Colors.blue,
          width: 5,
          points: points,
        );

        LatLngBounds polylineBounds = _getPolylineBounds(points);

        _controller!.animateCamera(
          CameraUpdate.newLatLngBounds(
            polylineBounds,
            50.0,
          ),
        );

        setState(() {
          _polylines = {..._polylines, polyline};
        });
      } else {
        print('Directions API request failed with status: ${data['status']}');
      }
    } else {
      print('Failed to fetch directions. Status code: ${response.statusCode}');
    }
  }

  void _getBusStops() async {
    // Existing code...
    const apiKey =
        'AIzaSyDkKbK_K-0WJuhGvvSbmSL5pEoCiBSWNqY'; // Replace with your API key
    final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&'
        'destination=${widget.destination.latitude},${widget.destination.longitude}&'
        'mode=transit&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        _displayBusStops(data['routes'][0]['legs'][0]['steps']);
      } else {
        print('Transit API request failed with status: ${data['status']}');
      }
    } else {
      print(
          'Failed to fetch transit information. Status code: ${response.statusCode}');
    }
  }

  void _displayBusStops(List<dynamic> steps) {
    // Existing code...
    Set<Marker> busStopMarkers = {};
    for (var step in steps) {
      if (step['transit_details'] != null) {
        final LatLng busStopLocation = LatLng(
          step['start_location']['lat'],
          step['start_location']['lng'],
        );

        Marker busStopMarker = Marker(
          markerId: MarkerId('busStop-${busStopLocation.hashCode}'),
          position: busStopLocation,
          infoWindow: InfoWindow(title: 'Bus Stop'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        );

        busStopMarkers.add(busStopMarker);
      }
    }

    setState(() {
      _busStopMarkers = busStopMarkers;
    });
  }

  LatLngBounds _getPolylineBounds(List<LatLng> points) {
    // Existing code...
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    for (LatLng point in points) {
      double lat = point.latitude;
      double lng = point.longitude;

      minLat = min(minLat, lat);
      minLng = min(minLng, lng);
      maxLat = max(maxLat, lat);
      maxLng = max(maxLng, lng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    // Existing code...
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5), (lng / 1E5)));
    }
    return points;
  }

  double _calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Existing code...

    double startLat = _degreesToRadians(lat1);
    double startLong = _degreesToRadians(lon1);
    double endLat = _degreesToRadians(lat2);
    double endLong = _degreesToRadians(lon2);

    double dLong = endLong - startLong;

    double dPhi =
        log(tan(endLat / 2.0 + pi / 4.0) / tan(startLat / 2.0 + pi / 4.0));

    double bearing = atan2(dLong, dPhi);

    bearing = _radiansToDegrees(bearing);
    bearing = (bearing + 360.0) % 360.0;

    return bearing;
  }

  double _radiansToDegrees(double radians) {
    // Existing code...
    return radians * (180.0 / pi);
  }

  double _degreesToRadians(double degrees) {
    // Existing code...
    return degrees * (pi / 180.0);
  }

  double _calculateTilt(double bearing) {
    // Existing code...
    const double maxTilt = 70.0;
    return _clamp(bearing.abs(), 0.0, maxTilt);
  }

  double _clamp(double value, double min, double max) {
    // Existing code...
    return value.clamp(min, max);
  }

  void _zoomIn() {
    _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _controller?.animateCamera(CameraUpdate.zoomOut());
  }

  void _speakNavigationDirections() async {
    //using text to speech
    if (!isMuted) {
      await flutterTts.speak("Start Navigation");
    }
  }
}
