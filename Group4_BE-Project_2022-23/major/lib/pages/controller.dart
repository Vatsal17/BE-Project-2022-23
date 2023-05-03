import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:major/pages/feedback.dart';
import 'package:major/pages/message.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:location/location.dart' as loc;

import '../components/my_textfield.dart';

class TrafficControllerPage extends StatefulWidget{
  @override
  State<TrafficControllerPage> createState() => _TrafficControllerPageState();
}
class _TrafficControllerPageState extends State<TrafficControllerPage> {

  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  loc.Location location = loc.Location();
  LatLng curLocation=LatLng(19.268855, 72.967330);
  Marker? currentPosition,sourcePosition, destinationPosition;

  var id=null;
  String? dropdownValue;
  String? Source;
  String? Destination;
  bool changed=false;
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(19.268255,72.967330);

  late Timer _timer;
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (Source?.length != null) {
        print('running');
        var data = await FirebaseFirestore.instance.collection('drivers').doc(id).get();
        curLocation=LatLng(data['currentLoc'].latitude, data['currentLoc'].longitude);
        addMarker(curLocation);
      } else {
        timer.cancel();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }


  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    var isLoggedIn=false;
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text('AmbWay'),
        backgroundColor: Colors.red[400],
      ),
      body: SingleChildScrollView(
        child:Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.05,),
          Row(
            children:[
              Card(
                semanticContainer: true,
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.30,
                  child: Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      child: Column(
                        children: [
                          Text(
                            "Name :"+
                            user.displayName!,
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.005,),
                          Text(
                            "Email :"+
                            user.email!,
                            style: TextStyle(fontSize: 20),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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


      ]
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child:
              Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade200,
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
              child:
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('drivers').doc('data').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  List<DropdownMenuItem> driverItems = [];
                  for (var driver in snapshot.data!['drivers']) {
                    driverItems.add(DropdownMenuItem(
                      child: Text(driver['name']),
                      value: driver['id'],
                    ));
                  }
                  return DropdownButton(
                    value: dropdownValue,
                    onChanged: (newValue) async {
                      var data = await FirebaseFirestore.instance.collection('drivers').doc(newValue).get();
                      var current = data['current'];
                      if (current != null) {
                        id=newValue;
                        Source = '${current['Source'].latitude},${current['Source'].longitude}';
                        Destination = '${current['Destination'].latitude},${current['Destination'].longitude}';
                        addMarkers(LatLng(current['Source'].latitude, current['Source'].longitude),LatLng(current['Destination'].latitude, current['Destination'].longitude));
                        curLocation=LatLng(data['currentLoc'].latitude, data['currentLoc'].longitude);
                        addMarker(LatLng(data['currentLoc'].latitude, data['currentLoc'].longitude));
                        getDirections(LatLng(current['Destination'].latitude, current['Destination'].longitude));
                        startTimer();
                      }
                      else{
                        Source=null;
                        Destination=null;
                      }
                      print(Source);
                      print(dropdownValue);
                      setState(() {
                        dropdownValue = newValue;
                      });
                    },
                    items: driverItems,
                    isExpanded: true,
                  );
                },
              )
                ),),
                Card(
                  color: Colors.black,
                  child: TextButton(
                    onPressed: () {
                      // code to navigate to the Feedback widget
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MessagePage()),
                      );
                    },
                    child: Text('Message'),
                  ),
                ),
              ],
            ),

            ),
          if (Source?.length != null)
          Container(
            height: MediaQuery.of(context).size.height*0.6,
            width: MediaQuery.of(context).size.width*0.8,
            child: GoogleMap(
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
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.01,),
          if (Source?.length != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child:Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade200,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  Source!,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child:Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade200,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Source",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          ,
          SizedBox(
              height: MediaQuery.of(context).size.height*0.05,
          ),
          if (Destination?.length != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child:Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade200,
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                Destination!,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child:Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade200,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Destination",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),

          SizedBox(
            height: MediaQuery.of(context).size.height*0.01,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.6,
          ),
          if (isLoggedIn=false)
            Text("Not Reached"),
          if (isLoggedIn=true)
            Text("Reached"),
          if (isLoggedIn=true)
          Center(
            child: SizedBox(
              height:MediaQuery.of(context).size.height*0.05,
              width:MediaQuery.of(context).size.width*0.3,
              child: Card(
                color: Colors.black,
                child: TextButton(
                  onPressed: () {
                    // code to navigate to the Feedback widget
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FeedbackPage()));
                  },
                  child: Text('Feedback'),
                ),
              ),
            ),
          ),
        ],
      ),),
    );
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

  addMarkers(Src,Dst) {
    destinationPosition = Marker(
      markerId: MarkerId('destination'),
      position: LatLng(Dst!.latitude, Dst!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      infoWindow: InfoWindow(title:'${double.parse((getDistance(LatLng(Dst!.latitude, Dst!.longitude)).toStringAsFixed(2)))} km'
      ),
    );
    sourcePosition = Marker(
      markerId: MarkerId('source'),
      position: LatLng(Src!.latitude, Src!.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),

    );
  }
  addMarker(curLocation) {
    setState(() {
      currentPosition = Marker(
        markerId: MarkerId('current'),
        position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });
  }
}