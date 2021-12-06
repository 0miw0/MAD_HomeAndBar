import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketPage extends StatefulWidget {
  final String docId;
  final String userId;
  const MarketPage({Key? key, required this.docId, required this.userId})
      : super(key: key);

  @override
  State<MarketPage> createState() => MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  Completer<GoogleMapController> _controller = Completer();

  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('market');
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.docId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went worng");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          int rating = data['rating'];

          void _launchURL() async => await canLaunch(data['url'])
              ? await launch(data['url'])
              : throw 'Could not launch ${data['url']}';

          // double latitude = data['location'][0];
          // double longitude = data['location'][1];

          GeoPoint marketLocation = data['location'];

          double latitude = marketLocation.latitude;
          double longitude = marketLocation.longitude;

          //marker 추가
          _markers.add(Marker(
              markerId: MarkerId("1"),
              draggable: true,
              onTap: () => print("Marker!"),
              position: LatLng(latitude, longitude)));

          final CameraPosition _kGooglePlex = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 15,
          );

          return new Scaffold(
            appBar: AppBar(
              title: Text('Market'),
            ),
            body: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Market name : ${data['title']}"),
                        Row(
                          children: [
                            Text("rating"),
                            rating > 0
                                ? Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.star_border,
                                    color: Colors.yellow,
                                    size: 15,
                                  ),
                            rating > 1
                                ? Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.star_border,
                                    color: Colors.yellow,
                                    size: 15,
                                  ),
                            rating > 2
                                ? Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.star_border,
                                    color: Colors.yellow,
                                    size: 15,
                                  ),
                            rating > 3
                                ? Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.star_border,
                                    color: Colors.yellow,
                                    size: 15,
                                  ),
                            rating > 4
                                ? Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.star_border,
                                    color: Colors.yellow,
                                    size: 15,
                                  ),
                          ],
                        ),
                        Text("Address : ${data['address']}"),
                        TextButton(
                          onPressed: _launchURL,
                          child: Text('Market Link ${data['url']}'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      markers: Set.from(_markers),
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        //loading
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            // backgroundColor: Colors.indigo[300],
            title: Text('Market'),
          ),
          body: Center(
            child: Text('loading..'),
          ),
        );
      },
    );
  }
}
