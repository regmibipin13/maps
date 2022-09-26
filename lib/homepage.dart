// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data.dart';
import 'package:flutter_application_1/databaseHelper.dart';
import 'package:flutter_application_1/details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'data.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int? selectedId;
  final typeController = TextEditingController();
  final priceController = TextEditingController();
  final detailsController = TextEditingController();
  final List<LatLng> latLng = <LatLng>[];
  Completer<GoogleMapController> _controller = Completer();

  // ignore: prefer_final_fields, unused_field
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  List<Marker> markers = [];
  int id = 1;
  Set<Polyline> _polylines = Set<Polyline>();
  // List<LatLng> polylineCoordinates = [];

  // Current Location
  LatLng currentLocation = LatLng(28.207981, 83.983272);
  late GoogleMapController mapController;
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(28.207981, 83.983272), zoom: 14);

  void initState() {
    // TODO: implement initState
    super.initState();
  }

  XFile? file;
  Future<LocationData> getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print("location is not permitted");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("location is not permitted");
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: FloatingActionButton(
              onPressed: () async {
                LocationData? locationData = await getCurrentLocation();
                currentLocation = LatLng(locationData.latitude!.toDouble(),
                    locationData.longitude!.toDouble());
                mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: currentLocation, zoom: 14)));
                setState(() {});
              },
              child: Icon(Icons.map)),
        ),
        body: FutureBuilder(
            future: DataBaseHelper.instance.getDetails(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return (Center(child: CircularProgressIndicator()));
              } else {
                markers = snapshot.data.map<Marker>((element) {
                  return Marker(
                      markerId: MarkerId(element.id.toString()),
                      draggable: false,
                      onTap: () {
                        _customInfoWindowController.addInfoWindow!(
                            SingleChildScrollView(
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffF2F2F2),
                                    border: Border.all(color: Colors.blueGrey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // ignore: prefer_const_literals_to_create_immutables
                                      children: [
                                        Text(
                                          "Type: " +
                                              Detail(
                                                type: element.type,
                                                price: element.price,
                                                latitude: element.latitude,
                                                longitude: element.longitude,
                                                details: element.details ?? '',
                                              ).type.toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Price: " +
                                              Detail(
                                                type: element.type,
                                                price: element.price,
                                                latitude: element.latitude,
                                                longitude: element.longitude,
                                                details: element.details ?? '',
                                              ).price.toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        InkWell(
                                          child: Text(
                                            "More Details",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xff5CB8E4),
                                              decorationColor: Colors.black,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Details(
                                                          id: element.id,
                                                          latitude: LatLng(
                                                                  double.parse(
                                                                      element
                                                                          .latitude),
                                                                  double.parse(
                                                                      element
                                                                          .longitude))
                                                              .latitude
                                                              .toString(),
                                                          longitude: LatLng(
                                                                  double.parse(
                                                                      element
                                                                          .latitude),
                                                                  double.parse(
                                                                      element
                                                                          .longitude))
                                                              .longitude
                                                              .toString(),
                                                          type: element.type
                                                              .toString(),
                                                          price: element.price
                                                              .toString(),
                                                          details: element
                                                              .details
                                                              .toString(),
                                                        )));
                                          },
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Color(0xff5CB8E4)),
                                              onPressed: () {
                                                AlertDialog alert = AlertDialog(
                                                  title: Text(
                                                      "Do you really want to delete?"),
                                                  content: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return Container(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          TextButton(
                                                              onPressed: () {
                                                                DataBaseHelper
                                                                    .instance
                                                                    .remove(
                                                                        element
                                                                            .id!);
                                                                _customInfoWindowController
                                                                    .hideInfoWindow!();
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {});
                                                              },
                                                              child:
                                                                  Text("Yes")),
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text("No"))
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                );

                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return alert;
                                                    });
                                              },
                                              child: const Icon(Icons.delete),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Color(0xff5CB8E4)),
                                              onPressed: () {
                                                setState(() {
                                                  _customInfoWindowController
                                                      .hideInfoWindow!();
                                                });
                                              },
                                              child: const Icon(Icons.close),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                            LatLng(double.parse(element.latitude),
                                double.parse(element.longitude)));

                        setState(() {});
                      },
                      position: LatLng(double.parse(element.latitude),
                          double.parse(element.longitude)));
                }).toList();
                return Stack(
                  children: [
                    GoogleMap(
                      onTap: (LatLng latlng) async {
                        AlertDialog alert = AlertDialog(
                          title: Text('Detail form'),
                          content:
                              StatefulBuilder(builder: (context, setState) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              reverse: true,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: typeController,
                                    decoration:
                                        InputDecoration(hintText: 'Type '),
                                    maxLines: 5,
                                    minLines: 1,
                                  ),
                                  TextField(
                                    controller: priceController,
                                    decoration:
                                        InputDecoration(hintText: 'Price '),
                                    maxLines: 5,
                                    minLines: 1,
                                  ),
                                  TextField(
                                    controller: detailsController,
                                    decoration: InputDecoration(
                                        hintText: 'More details'),
                                    maxLines: 10,
                                    minLines: 1,
                                  ),
                                ],
                              ),
                            );
                          }),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  typeController.clear();
                                  priceController.clear();
                                  detailsController.clear();

                                  Navigator.pop(context, 'Cancel');
                                },
                                child: Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  await DataBaseHelper.instance.add(
                                    Detail(
                                      latitude: latlng.latitude != null
                                          ? latlng.latitude.toString()
                                          : "",
                                      longitude: latlng.longitude.toString(),
                                      type: typeController.text,
                                      price: priceController.text,
                                      details: detailsController.text,
                                    ),
                                  );

                                  Marker firstMarker = Marker(
                                      markerId: MarkerId("$id"),
                                      position: LatLng(
                                          latlng.latitude, latlng.longitude),
                                      icon: BitmapDescriptor.defaultMarker);
                                  markers.add(firstMarker);
                                  _customInfoWindowController.hideInfoWindow!();
                                  typeController.clear();
                                  priceController.clear();
                                  detailsController.clear();

                                  file = null;
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Text('Add')),
                          ],
                        );

                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            });
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      onCameraMove: (position) {
                        _customInfoWindowController.onCameraMove!();
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _customInfoWindowController.googleMapController =
                            controller;
                        mapController = controller;
                      },
                      initialCameraPosition: initialCameraPosition,
                      markers: markers.map((e) => e).toSet(),
                      polylines: _polylines,
                    ),
                    CustomInfoWindow(
                      controller: _customInfoWindowController,
                      height: 200,
                      width: 250,
                      offset: 35,
                    )
                  ],
                );
              }
            }));
  }
}
