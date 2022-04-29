// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Geo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LocationApp(),
    );
  }
}

class LocationApp extends StatefulWidget {
  LocationApp({Key? key}) : super(key: key);

  @override
  State<LocationApp> createState() => _LocationAppState();
}

String Address = '...';

Future<Position> getGeoLocationPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    await Geolocator.openLocationSettings();
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

class _LocationAppState extends State<LocationApp> {
  var mssgUbicacion = "";

  void getCurrentLocation() async {
    var posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lastposition = await Geolocator.getLastKnownPosition();
    print(lastposition);
    var lat = posicion.latitude;
    var long = posicion.longitude;
    print("$lat, $long");

    setState(() {
      mssgUbicacion = "Latitud: $lat, Longitud: $long";
    });
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GeoLocation"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.gps_fixed_rounded,
              size: 47.0,
              color: Colors.indigo,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Mostrar ubicación",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 21.0,
            ),
            Text(
              "Posición:",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 21.0,
            ),
            Text(
              "$mssgUbicacion",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.w900),
            ),
            SizedBox(
              height: 21.0,
            ),
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.indigo,
                    textStyle: TextStyle(fontSize: 18.0)),
                onPressed: () async {
                  Position position = await getGeoLocationPosition();

                  getCurrentLocation();
                  GetAddressFromLatLong(position);
                },
                child: Text("Obtener ubicación actual")),
            SizedBox(
              height: 21.0,
            ),
            Text(
              "Dirección: ",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 21.0,
            ),
            Text(
              "$Address",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
