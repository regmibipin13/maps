// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_application_1/databaseHelper.dart';
import 'package:flutter_application_1/homepage.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: TextField(
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                    )),
                hintText: 'Search your location',
                hintStyle: const TextStyle(color: Colors.white)),
            maxLines: 5,
            minLines: 1,
          ),
          backgroundColor: const Color(0xff5CB8E4),
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xff5CB8E4)),
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage("assets/images/u.jpg"),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.upload,
                ),
                title: const Text('Export'),
                onTap: () {
                  DataBaseHelper.instance.exportDatabase();
                  Navigator.pop(context);
                  const snackBar = SnackBar(
                    content: Text(
                      'Database Has Beed Exported To Downloads Folder Successfully',
                      style: TextStyle(color: Colors.green),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_to_home_screen_outlined),
                title: const Text('Import'),
                onTap: () async {
                  var status = await DataBaseHelper.instance.importDatabase();

                  if (status) {
                    const snackBar = SnackBar(
                      content: Text(
                        'Database Has Been Imported Successfully',
                        style: TextStyle(color: Colors.green),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
        body: Homepage());
  }
}
