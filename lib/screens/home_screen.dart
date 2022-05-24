import 'package:app/screens/auth_screen.dart';
import 'package:app/screens/menu_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';

class Home_Screen extends StatelessWidget {
  Database database;
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Home_Screen(this.database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Delivery App",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              _signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage(database)));
            },
            icon: Icon(Icons.logout),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(padding: EdgeInsets.all(20.0)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MenuScreen(database)));
              },
              child: const Text(
                "Menu",
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 80), primary: Colors.blue),
            ),
            const Padding(padding: EdgeInsets.all(20.0)),
        //     ElevatedButton(
        //       onPressed: () {
        //         FirebaseFirestore.instance.collection("items").add({"ID":3,"name":"Pizza","price":200,"image": 'assets/images/pizza.jpg',
        // "desc": 'This is a pizza'});
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => MenuScreen(database)));
        //       },
        //       child: const Text(
        //         "Update Backend",
        //         style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        //       ),
        //       style: ElevatedButton.styleFrom(
        //           fixedSize: const Size(300, 80), primary: Colors.blue),
        //     ),
            const Padding(padding: EdgeInsets.all(20.0)),
          ],
        ),
      ),
    );
  }
}
