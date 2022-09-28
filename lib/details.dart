import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'data.dart';
import 'databaseHelper.dart';

class Details extends StatefulWidget {
  const Details({
    Key? key,
    this.id = 0,
    this.latitude = '',
    this.longitude = '',
    required this.type,
    required this.price,
    required this.details,
  }) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
  final int id;
  final String latitude;
  final String longitude;
  final String type;
  final String price;
  final String details;
}

class _DetailsState extends State<Details> {
  final typeController = TextEditingController();
  final priceController = TextEditingController();
  final detailsController = TextEditingController();
  List<Photo> photos = [];

  final destination = [];

  final kDefaultPadding = 20.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPhotos();
  }

  void loadPhotos() async {
    Future<List<Photo>> details_images =
        DataBaseHelper.instance.getDetailPhotos(widget.id);
    List listPhotos = await details_images;

    for (int i = 0; i < listPhotos.length; i++) {
      destination.add(Photo(detailId: widget.id, name: listPhotos[i].name));
    }
    setState(() {});
  }

  XFile? file;
  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: Stack(
        children: [
          // ignore: avoid_unnecessary_containers
          Container(
              child: SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                    backgroundColor: const Color(0xff5CB8E4),
                    title: Text(widget.type),
                    actions: <Widget>[
                      IconButton(
                        // ignore: prefer_const_constructors
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          typeController.text = widget.type;
                          priceController.text = widget.price;
                          detailsController.text = widget.details;

                          AlertDialog alert = AlertDialog(
                            title: const Center(child: Text('Detail form')),
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
                                      decoration: const InputDecoration(
                                          hintText: 'Type '),
                                      maxLines: 5,
                                      minLines: 1,
                                    ),
                                    TextField(
                                      controller: priceController,
                                      decoration: const InputDecoration(
                                          hintText: 'Price '),
                                      maxLines: 5,
                                      minLines: 1,
                                    ),
                                    TextField(
                                      controller: detailsController,
                                      decoration: const InputDecoration(
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
                                    Navigator.pop(context, 'Cancel');
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Color(0xff5CB8E4)),
                                  )),
                              TextButton(
                                  onPressed: () async {
                                    await DataBaseHelper.instance.update(
                                      Detail(
                                        id: widget.id,
                                        latitude: widget.latitude,
                                        longitude: widget.longitude,
                                        type: typeController.text,
                                        price: priceController.text,
                                        details: detailsController.text,
                                      ),
                                    );
                                    loadPhotos();
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Details(
                                                  type: typeController.text,
                                                  price: priceController.text,
                                                  details:
                                                      detailsController.text,
                                                )),
                                        ModalRoute.withName("/"));
                                  },
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(color: Color(0xff5CB8E4)),
                                  )),
                            ],
                          );
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                          // do something
                        },
                      )
                    ]),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // ignore: sized_box_for_whitespace
                      Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: destination.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding),
                              child: destinationCard(context, index),
                            ),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          TextButton.icon(
                              onPressed: () async {
                                List<XFile> imageLists = [];
                                final List<XFile>? imgFile =
                                    await ImagePicker().pickMultiImage();
                                if (imgFile!.isNotEmpty) {
                                  imageLists.addAll(imgFile);

                                  for (int i = 0; i < imageLists.length; i++) {
                                    var photo;
                                    final bytes =
                                        await imageLists[i].readAsBytes();
                                    final base64 = base64Encode(bytes);
                                    photo = base64.toString();
                                    Photo p =
                                        Photo(detailId: widget.id, name: photo);
                                    destination.add(p);
                                    DataBaseHelper.instance.addPhoto(p);
                                    // setState(() {});
                                  }
                                }

                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.image,
                                color: Color(0xff5CB8E4),
                              ),
                              label: const Text(
                                'Add Photos',
                                style: TextStyle(color: Colors.black),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              // ignore: prefer_const_constructors
                              Text(
                                "Type:",
                                style: TextStyle(
                                    fontSize: 15 * textScale,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Text(
                                widget.type,
                                style: TextStyle(
                                    fontSize: 15 * textScale,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              Text(
                                "Price:",
                                style: TextStyle(
                                    fontSize: 15 * textScale,
                                    fontWeight: FontWeight.bold),
                              ),

                              // ignore: sized_box_for_whitespace
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.56,
                                  child: Text(
                                    widget.price,
                                    style: TextStyle(fontSize: 15 * textScale),
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              Text(
                                "Description:",
                                style: TextStyle(
                                    fontSize: 15 * textScale,
                                    fontWeight: FontWeight.bold),
                              ),

                              // ignore: sized_box_for_whitespace
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.56,
                                  child: Text(
                                    widget.details,
                                    style: TextStyle(fontSize: 15 * textScale),
                                  ))
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget destinationCard(BuildContext context, index) {
    Photo img = destination[index];
    String imagePath = img.name;
    AlertDialog alert = AlertDialog(
      scrollable: true,
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextButton.icon(
                onPressed: () async {
                  var photo;
                  final ImagePicker _picker = ImagePicker();
                  XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    final base64 = base64Encode(bytes);
                    photo = base64.toString();

                    DataBaseHelper.instance.updatePhoto(
                        Photo(id: img.id, detailId: widget.id, name: photo));
                  }
                  destination[index] = Photo(detailId: widget.id, name: photo);
                  Navigator.pop(context, "Cancel");
                  setState(() {});
                },
                icon: const Icon(
                  Icons.image,
                  color: Color(0xff5CB8E4),
                ),
                label: const Text(
                  'Change Image',
                  style: TextStyle(color: Colors.black),
                )),
            const SizedBox(
              height: 10,
            ),
            TextButton.icon(
                onPressed: () {
                  DataBaseHelper.instance
                      .removePhoto(Photo(detailId: widget.id, name: img.name));
                  Navigator.pop(context);
                  destination.removeAt(index);
                  setState(() {});
                },
                icon: const Icon(Icons.remove, color: Color(0xff5CB8E4)),
                label: const Text(
                  'Remove Image',
                  style: TextStyle(color: Colors.black),
                )),
            const SizedBox(
              height: 10,
            ),
            TextButton.icon(
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                },
                icon: const Icon(Icons.exit_to_app, color: Color(0xff5CB8E4)),
                label: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.black),
                ))
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: () => {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            })
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: MemoryImage(base64.decode(imagePath)),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width - 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
