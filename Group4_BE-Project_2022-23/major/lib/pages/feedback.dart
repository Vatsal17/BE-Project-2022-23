import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:major/pages/home_page.dart';
import 'package:major/pages/login_page.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}
class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text('AmbWay'),
        backgroundColor: Colors.red[400],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.10,
              child:Card(
                  color: Colors.blueGrey,
                  child: Text('             Feedback            ',
                    style: TextStyle(fontSize: 20),
                  )
              ),
            ),

            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),




            ElevatedButton(
              onPressed: () {
                // Handle submit logic here
                FirebaseFirestore.instance
                    .collection('feedback')
                .doc("data")
                    .get()
                    .then((DocumentSnapshot documentSnapshot) {
                if (documentSnapshot.exists) {
                int currentRating = documentSnapshot['rating'];
                int newRating = ((currentRating + _rating) / 2).round();
                FirebaseFirestore.instance
                    .collection('feedback')
                    .doc("data")
                    .update({'rating': newRating});
                }
                });

              },
              child: Text('Submit'),

            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.5,),
            ElevatedButton(
              onPressed: () async {
                // Handle submit logic here
                final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
                await _firebaseAuth.signOut();
                Navigator.popUntil(
                    context,
                (route) => route.isFirst);

              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}