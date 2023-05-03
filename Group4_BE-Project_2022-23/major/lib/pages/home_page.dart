import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major/pages/driver.dart';
import 'package:humanitarian_icons/humanitarian_icons.dart';
import 'controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(centerTitle: true,
      title: Text('AmbWay'),
      backgroundColor: Colors.red[400],

    ),
      body: Center(
        child: Column(
          children: [
            Text(
              "Logged In as " + user.displayName!,
              style: TextStyle(fontSize: 20),
            ),

            Card(
              semanticContainer: true,
              color: Colors.blueGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.80,
                child: Stack(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      size: 200,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DriverPage()),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 100,
                          child: Text("Ambulance Driver", style: TextStyle(fontSize: 25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              semanticContainer: true,
              color: Colors.blueGrey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.80,
                child: Stack(
                  children: [
                    const Icon(
                      Icons.traffic,
                      size: 200,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrafficControllerPage()),
              );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 100,
                          child: Text("Traffic Manager", style: TextStyle(fontSize: 25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Handle submit logic here
                final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
                await _firebaseAuth.signOut();


              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
