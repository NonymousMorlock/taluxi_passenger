import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:real_time_location/real_time_location.dart';
import 'package:taluxi/pages/taxi_tracking_page/taxi_tracker_page_widgets.dart';
import 'package:taluxi_common/taluxi_common.dart';

// ignore: must_be_immutable
class TaxiTrackingPage extends StatefulWidget {
  TaxiTrackingPage(this.dataOfDriverToTrack, {super.key}) {
    _idOfDriverToTrack = dataOfDriverToTrack.keys.first;
    final coordinatesOfDriverToTrack = dataOfDriverToTrack[_idOfDriverToTrack];
    _initialCameraPosition = CameraPosition(
      target: LatLng(
        coordinatesOfDriverToTrack!.latitude,
        coordinatesOfDriverToTrack.longitude,
      ),
      zoom: 15.4746,
    );
  }

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  final Map<String, Coordinates> dataOfDriverToTrack;
  late String _idOfDriverToTrack;
  late CameraPosition _initialCameraPosition;

  @override
  State<TaxiTrackingPage> createState() => _TaxiTrackingPageState();
}

// TODOrefactoring .
class _TaxiTrackingPageState extends State<TaxiTrackingPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  var _mapOpacity = 0.0;
  Timer? timer;
  final _markers = <Marker>{};
  final _deviceLocationHandler = DeviceLocationHandler.instance;
  late RealTimeLocation _realTimeLocation;

  @override
  void initState() {
    super.initState();
    _initializesLocationServices();
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: widget._initialCameraPosition.target,
        infoWindow: const InfoWindow(title: 'Driver'),
      ),
    );
    timer = Timer(
      const Duration(milliseconds: 500),
      () => setState(() => _mapOpacity = 1),
    );
  }

  Future<void> _initializesLocationServices() async {
    _realTimeLocation = context.read<RealTimeLocation>();
    await _realTimeLocation.initialize(currentUserId: 'test');
    await _deviceLocationHandler.initialize(requireBackground: true);
    _deviceLocationHandler
        .getCoordinatesStream(distanceFilterInMeter: 5)
        .listen(_currentUserLocationTraker);
    _realTimeLocation
        .startLocationTracking(widget._idOfDriverToTrack)
        .listen(_driverLocationTraker);
  }

  void _currentUserLocationTraker(Coordinates coordinates) {
    setState(
      () => _markers.add(
        Marker(
          markerId: const MarkerId('currentUser'),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: const InfoWindow(title: 'currentUser'),
        ),
      ),
    );
  }

  void _driverLocationTraker(Coordinates coordinates) {
    setState(
      () => _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          infoWindow: const InfoWindow(title: 'driver'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
      body: Builder(
        builder: (context) => Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _mapOpacity,
              child: GoogleMap(
                markers: _markers,
                padding: const EdgeInsets.only(bottom: 65),
                initialCameraPosition: widget._initialCameraPosition,
                onMapCreated: (GoogleMapController controller) async {
                  _mapController.complete(controller);
                },
              ),
            ),
            _backButton(context),
            _menuButton(context),
            Align(
              alignment: Alignment.bottomCenter,
              child: CurvedNavigationBar(
                height: 65,
                color: const Color(0xFFFFA715),
                backgroundColor: Colors.transparent,
                //buttonBackgroundColor: Colors.white,
                items: <Widget>[
                  const Icon(
                    Icons.my_location,
                    size: 25,
                    color: Colors.white,
                  ),
                  Image.asset(
                    'assets/images/taxi-sign.png',
                    width: 25,
                    height: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _menuButton(BuildContext context) {
    return Positioned(
      right: 10,
      top: 53,
      child: InkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: mainLinearGradient,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Positioned _backButton(BuildContext context) {
    return Positioned(
      left: 10,
      top: 53,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: mainLinearGradient,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final controller = await _mapController.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(TaxiTrackingPage._kLake));
  }
}
