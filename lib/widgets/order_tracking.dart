import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:valet/widgets/keys_maps.dart';

class OrderTracking extends StatefulWidget {
  const OrderTracking({super.key});

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.4221, -122.0852);
  static const LatLng destination = LatLng(37.4116, -122.0713);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/home.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/wallet.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/network.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  // void getCurrentLocation() async {
  //   Location location = Location();

  //   location.getLocation().then(
  //     (location) {
  //       currentLocation = location;
  //       setState(() {});
  //     },
  //   );
  //   GoogleMapController googleMapController = await _controller.future;

  //   location.onLocationChanged.listen(
  //     (newLoc) {
  //       currentLocation = newLoc;
  //       googleMapController.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //             zoom: 14.5,
  //             target: LatLng(newLoc.latitude!, newLoc.longitude!),
  //           ),
  //         ),
  //       );
  //       setState(() {});
  //     },
  //   );
  // }

  void getPolypoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
      mapAndroidKey,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (polylineResult.points.isNotEmpty) {
      polylineResult.points.forEach(
        (PointLatLng points) => polylineCoordinates.add(
          LatLng(points.latitude, points.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getPolypoints();
    // getCurrentLocation();
    setCustomMarkerIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          //  currentLocation == null
          //     ? const Center(
          //         child: Text(
          //         "Loading..",
          //       ))
          //     :
          GoogleMap(
        initialCameraPosition: CameraPosition(
          zoom: 14.5,
          target:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 6,
          ),
        },
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            icon: currentLocationIcon,
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
          ),
          Marker(
              markerId: const MarkerId("source"),
              icon: sourceIcon,
              position: sourceLocation),
          Marker(
              markerId: const MarkerId("destination"),
              icon: destinationIcon,
              position: destination),
        },
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
