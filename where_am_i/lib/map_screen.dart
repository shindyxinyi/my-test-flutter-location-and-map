import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.422153, -122.084047),
    zoom: 14.0,
  );

  GoogleMapController _mapController;
  bool _isMapCreated = false;

  LatLng _currentPosition;
  Map<String, Marker> _markers = {};
  String _currentFullAddress;

  StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();

    checkLocationPermission();
  }

  @override
  void dispose() {
    // Stop position listener
    positionStream.cancel();
    super.dispose();
  }

  void checkLocationPermission() async {
    // Check is device location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      getCurrentLocation();
    } else if (permission == LocationPermission.denied) {
      // Request permission if is denied
      permission = await Geolocator.requestPermission();
      print(permission);

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        getCurrentLocation();
      }
    }
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    // Location listener
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1000,
      intervalDuration: Duration(seconds: 40),
    ).listen((Position location) {
      print(location);
      setState(() {
        _currentPosition = LatLng(location.latitude, location.longitude);
        animateMapToCurrentPosition();
      });
    });

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      // Update Google Map Camera position
      animateMapToCurrentPosition();
    });
  }

  void addMarker() {
    _markers.clear();

    final marker = Marker(
      markerId: MarkerId('marker'),
      position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
    );

    setState(() {
      _markers['current_location'] = marker;
    });
  }

  void animateMapToCurrentPosition() {
    if (_currentPosition == null || _isMapCreated == false) {
      return;
    }

    // Add marker when camera moves
    addMarker();
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 16)));
    getCurrentFullAddress();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _isMapCreated = true;
    });
  }

  void getCurrentFullAddress() async {
    Uri url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_currentPosition.latitude.toString()},${_currentPosition.longitude.toString()}&key=');
    http.Response response = await http.get(url);

    var decodedData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<dynamic> results = decodedData['results'];
      if (results != null && results.length > 0) {
        setState(() {
          _currentFullAddress = results[0]['formatted_address'];
        });
      }
    } else {
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    GoogleMap googleMap = GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _kInitialPosition,
      markers: _markers.values.toSet(),
      myLocationEnabled: false,
    );

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text('Where Am I?'),
        backgroundColor: Colors.redAccent,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(color: Colors.grey, child: googleMap),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your current location',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    Text('Latitude: ' +
                        (_currentPosition == null
                            ? '-'
                            : '${_currentPosition.latitude}')),
                    SizedBox(height: 10.0),
                    Text('Longitude: ' +
                        (_currentPosition == null
                            ? '-'
                            : '${_currentPosition.longitude}')),
                    SizedBox(height: 10.0),
                    Text(
                        'Address: ${(_currentFullAddress != null ? _currentFullAddress : '-')}')
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
