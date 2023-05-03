import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import '../components/my_textfield.dart';
import 'feedback.dart';

class DriverPage extends StatefulWidget {
  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  loc.Location location = loc.Location();
  Marker? currentPosition,sourcePosition, destinationPosition;
  loc.LocationData? _currentPosition;
  LatLng curLocation=LatLng(19.268855, 72.967330);
  StreamSubscription<loc.LocationData>? locationSubscription;

  final user = FirebaseAuth.instance.currentUser!;
  final DestController = TextEditingController();
  GeoPoint? Src;
  GeoPoint? Dst;
  bool TripStart = false;
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(19.268855, 72.967330);

  bool Nav=false;

  late Timer _timer;
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (Nav) {
        FirebaseFirestore.instance
            .collection('drivers')
            .doc(user.uid)
            .update({
          'currentLoc':GeoPoint(curLocation.latitude, curLocation.longitude)
        });
      } else {
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNavigation();
    addMarker();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  var SRC = "19.268255,72.967330";

  @override
  Widget build(BuildContext context) {
    var isLoggedIn = false;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('AmbWay'),
        backgroundColor: Colors.red[400],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(children: [
              Card(
                semanticContainer: true,
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      child: Column(
                        children: [
                          Text(
                            "Name :" + user.displayName!,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.005,
                          ),
                          Text(
                            "Email :" + user.email!,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                semanticContainer: true,
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                child: SizedBox(
                  child: Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      child: Row(
                        children: [
                          Text(
                            "Contact :",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "1234567890",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade200,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  (curLocation?.latitude?.toString() ?? "latitude") + "," + (curLocation?.longitude?.toString() ?? "longitude"),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            if (TripStart)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.grey.shade200,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    DestController.text,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              MyTextField(
                controller: DestController,
                hintText: 'Destination',
                obscureText: false,
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            if (DestController.text.length > 0 && TripStart == false)
              Center(
                child: Card(
                  color: Colors.brown,
                  child: TextButton(
                    onPressed: () {

                      Src = GeoPoint(curLocation.latitude, curLocation.longitude);
                      List<String>  latLngList = DestController.text.split(',');
                      var lat = double.parse(latLngList[0]);
                      var lng = double.parse(latLngList[1]);
                      Dst = GeoPoint(lat, lng);
                      print(Dst);
                      print(user.uid);
                      FirebaseFirestore.instance
                          .collection('drivers')
                          .doc(user.uid)
                          .update({
                        'current': {'Source': Src, 'Destination': Dst},
                        'trips': FieldValue.increment(1)
                      });
                      TripStart = true;
                      addMarker2();
                      getDirections(LatLng(Dst!.latitude, Dst!.longitude));
                    },
                    child: Text('Navigate'),
                  ),
                ),
              ),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: MediaQuery.of(context).size.width * 0.8,
              child: currentPosition == null
                  ? Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        TripStart?
                            Nav?
                        GoogleMap(
                          zoomControlsEnabled: true,
                          polylines: Set<Polyline>.of(polylines.values),
                          initialCameraPosition: CameraPosition(
                            target: curLocation,
                            zoom: 18,
                          ),
                          markers: {currentPosition!, destinationPosition!,sourcePosition!},
                          onTap: (latLng) {
                            print(latLng);
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            _controller.complete(controller);
                          },
                        ):
                            GoogleMap(
                              zoomControlsEnabled: true,
                              polylines: Set<Polyline>.of(polylines.values),
                              initialCameraPosition: CameraPosition(
                                target: curLocation,
                                zoom: 18,
                              ),
                              markers: {currentPosition!, destinationPosition!},
                              onTap: (latLng) {
                                print(latLng);
                              },
                              onMapCreated: (GoogleMapController controller) async {
                                _controller.complete(controller);
                              },
                            )
                            :
                        GoogleMap(
                          zoomControlsEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: curLocation,
                            zoom: 10,
                          ),
                          markers: {currentPosition!},
                          onTap: (latLng) {
                            print(latLng);
                          },
                          onMapCreated: (GoogleMapController controller) async {
                            _controller.complete(controller);
                          },
                        ),
                        Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.blue),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.navigation_outlined,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    startTimer();
                                    Nav=true;
                                    addMarker3(Src);
                                    await launchUrl(Uri.parse(
                                        'google.navigation:q=${Dst!.latitude}, ${Dst!.longitude}&key=AIzaSyCQsIWL1z-79bGvSsrWWCeSsANUHp-Ebpo'));
                                  },
                                ),
                              ),
                            ))
                      ],
                    ),
            ),
            if (DestController.text.length > 0 && TripStart)
              Center(
                child: Card(
                  color: Colors.brown,
                  child: TextButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        // Get the document reference
                        DocumentReference docRef = FirebaseFirestore.instance
                            .collection('drivers')
                            .doc(user.uid);

                        // Get the current document data
                        DocumentSnapshot docSnapshot =
                            await transaction.get(docRef);
                        Map<String, dynamic> docData =
                            docSnapshot.data() as Map<String, dynamic>;

                        // Get the value of the trips field
                        int trips = docData['trips'] ?? 0;

                        // Update the document
                        transaction.set(
                          docRef,
                          {
                            'current': null,
                            'currentLoc':null,
                            'past': {
                              trips.toString(): {
                                'Source': Src,
                                'Destination': Dst
                              }
                            }
                          },
                          SetOptions(merge: true),
                        );
                        TripStart = false;
                        Nav=false;
                        Dst = null;
                        DestController.text = "";
                      });
                    },
                    child: Text('Reached'),
                  ),
                ),
              ),
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.3,
                child: Card(
                  color: Colors.black,
                  child: TextButton(
                    onPressed: () {
                      // code to navigate to the Feedback widget
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedbackPage()));
                    },
                    child: Text('Feedback'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getNavigation() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    final GoogleMapController? controller = await _controller.future;
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    if (_permissionGranted == loc.PermissionStatus.granted) {
      _currentPosition = await location.getLocation();
      curLocation =
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      locationSubscription =
          location.onLocationChanged.listen((loc.LocationData currentLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16,
        )));
        if (mounted) {
          controller
              ?.showMarkerInfoWindow(MarkerId(currentPosition!.markerId.value));
          setState(() {
            curLocation =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            currentPosition = Marker(
              markerId: MarkerId(currentLocation.toString()),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position:
                  LatLng(currentLocation.latitude!, currentLocation.longitude!),
              infoWindow: InfoWindow(
                  title:
                      "You"),
              onTap: () {
                print('market tapped');
              },
            );
          });

        }
      });
    }
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyCQsIWL1z-79bGvSsrWWCeSsANUHp-Ebpo',
        PointLatLng(curLocation.latitude, curLocation.longitude),
        PointLatLng(dst.latitude, dst.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destposition) {
    return calculateDistance(curLocation.latitude, curLocation.longitude,
        destposition.latitude, destposition.longitude);
  }

  addMarker() {
    setState(() {
      currentPosition = Marker(
        markerId: MarkerId('current'),
        position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });
  }
  addMarker2() {
    destinationPosition = Marker(
      markerId: MarkerId('destination'),
      position: LatLng(Dst!.latitude, Dst!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow: InfoWindow(title:'${double.parse((getDistance(LatLng(Dst!.latitude, Dst!.longitude)).toStringAsFixed(2)))} km'
      ),
    );
  }

  addMarker3(Src) {
    sourcePosition = Marker(
      markerId: MarkerId('source'),
      position: LatLng(Src!.latitude, Src!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }
}
