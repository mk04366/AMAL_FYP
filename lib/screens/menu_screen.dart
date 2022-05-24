import 'package:app/data_models/items.dart';
import 'package:app/screens/item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';

class MenuScreen extends StatefulWidget {
  Database database;
  MenuScreen(this.database);

  @override
  _MenuScreenState createState() => _MenuScreenState(database);
}

class _MenuScreenState extends State<MenuScreen> {
  CollectionReference ref_items =
      FirebaseFirestore.instance.collection("items");
  FirebaseStorage storage = FirebaseStorage.instance;
  List<ItemData> cartlist = [];
  Database datab;
  int selectedindex = 0;
  bool flag = false;
  String dropdownValue = 'Table 1';
  _MenuScreenState(this.datab);
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> insertdata(ItemData item) async {
    final db = await datab;
    await db.insert('shoppingcart', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  getitems() async {
    QuerySnapshot query = await ref_items.get();
    List docs = query.docs;
    List<ItemData> lst =
        docs.map((doc) => ItemData.fromJson(doc.data(), 0)).toList();
    return lst;
  }

  Future itemslist() async {
    final db = await datab;

    final List<Map<String, dynamic>> maps = await db.query('shoppingcart');

    return List.generate(maps.length, (i) {
      return ItemData(maps[i]['quantity'],
          itemId: maps[i]['itemId'],
          name: maps[i]["name"],
          price: maps[i]["price"],
          imageUrl: maps[i]["imageUrl"],
          description: maps[i]['description'],
          category: maps[i]['category']);
    });
  }

  updateStatus() async {
    try {
      var status = 0;
      var docs = await FirebaseFirestore.instance
        .collection('orders')
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((value) => value.docs.map((e) => status = e['ID']).toList());
    FirebaseFirestore.instance.collection('orders').doc(docs[docs.length-1].toString()).update({"status":'delivered'});
    }
    catch (error){
      print(error);
    }
  }
  getstatus() async {
    try {
      var status = '';
      var docs = await FirebaseFirestore.instance
        .collection('orders')
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((value) => value.docs.map((e) => status = e['status']).toList());
    return Column(
      children: [
        Padding(padding: EdgeInsets.all(20.0)),
        Text(
          "Your order status is:",
          style: TextStyle(fontSize: 20.0),
        ),
        Text(
            docs[docs.length-1],
            style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
    }
    catch (error){
      return Column(children: [
        Padding(padding: EdgeInsets.all(20.0)),
        Text("You do not have any order",style: TextStyle(fontSize: 20.0))
      ]);
    }
  }

  setdatadelivery(List lst, num amount, String tableno) async {
    var name = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((doc) => doc.get('name'));
    var id = await FirebaseFirestore.instance
        .collection('metadata')
        .doc('data')
        .get()
        .then((doc) => doc.get('orderids'));
    id = id + 1;
    FirebaseFirestore.instance.collection("orders").doc(id.toString()).set({
      'amount': amount,
      'name': name,
      'ID': id,
      "email": FirebaseAuth.instance.currentUser?.email,
      'items': lst,
      'deliver': true,
      'time': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      'status': 'preparing',
      'table': tableno
    });
    FirebaseFirestore.instance
        .collection('metadata')
        .doc('data')
        .update({'orderids': id});
  }

  setdatapreorder(List lst, num amount) async {
    var name = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((doc) => doc.get('name'));
    var id = await FirebaseFirestore.instance
        .collection('metadata')
        .doc('data')
        .get()
        .then((doc) => doc.get('orderids'));
    id = id + 1;
    FirebaseFirestore.instance.collection("orders").doc(id.toString()).set({
      'amount': amount,
      'name': name,
      'ID': id,
      "email": FirebaseAuth.instance.currentUser?.email,
      'items': lst,
      'deliver': false,
      'time': DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      'status': 'preparing'
    });
    FirebaseFirestore.instance
        .collection('metadata')
        .doc('data')
        .update({'orderids': id});
  }

  Future<void> deleteItem(String id) async {
    final db = await datab;
    await db.delete(
      'shoppingcart',
      where: 'itemId = ?',
      whereArgs: [id],
    );
  }

  getwidgettree(int index) {
    List<Widget> widgets = <Widget>[
      Column(
        children: <Widget>[
          FutureBuilder(
              future: getitems(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    List<Widget> list = [];
                    for (var i = 0; i < snapshot.data.length; i++) {
                      var currentItem = snapshot.data[i];
                      print(currentItem.imageUrl);
                      list.add(Column(
                        children: <Widget>[
                          Container(
                              width: 180,
                              height: 180,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(12),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color.fromARGB(255, 255, 255, 255)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ItemScreen(
                                                currentItem, datab)));
                                  },
                                  child: Hero(
                                      transitionOnUserGestures: true,
                                      tag: currentItem.name,
                                      child: Image.network(currentItem.imageUrl,width: 200)))),
                          Padding(padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0)),
                          Text(currentItem.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins')),
                          Text("Rs. " + currentItem.price.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins')),
                        ],
                      ));
                    }
                    return Expanded(
                      child: GridView.count(
                        physics: const ScrollPhysics(),
                        childAspectRatio: 2 / 3,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        children: list,
                      ),
                    );
                  }
                }
                return Center(child: Text("Items Loading"));
              })
        ],
      ),
      Container(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: ListView(
            children: [
              FutureBuilder(
                future: itemslist(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      List<Widget> cartlist = [];
                      for (var i = 0; i < snapshot.data.length; i++) {
                        var name = snapshot.data[i].name;
                        var qty = snapshot.data[i].quantity;
                        var price = (snapshot.data[i].price * qty).toString();
                        var image = snapshot.data[i].imageUrl;
                        cartlist.add(Column(
                          children: [
                            Container(
                                color: Colors.grey[500],
                                height: 100.0,
                                width: 400.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    //borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(padding: EdgeInsets.all(10.0)),
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: Image(
                                            image: NetworkImage(image)),
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.all(5.0)),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(name + " x" + qty.toString()),
                                          const Padding(
                                              padding: EdgeInsets.all(5.0)),
                                          Text("Rs." + price),
                                        ],
                                      ),
                                      const Padding(
                                          padding: EdgeInsets.all(10.0)),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  deleteItem(
                                                      snapshot.data[i].itemId);
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.remove_circle)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            Padding(padding: EdgeInsets.all(5.0))
                          ],
                        ));
                      }
                      cartlist.add(Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: snapshot.data.length < 1
                                  ? null
                                  : () {
                                      List lst = [];
                                      num amount = 0;
                                      for (var i = 0;
                                          i < snapshot.data.length;
                                          i++) {
                                        lst.add({
                                          "itemId": snapshot.data[i].itemId
                                              .toString(),
                                          "name": snapshot.data[i].name,
                                          "qty": snapshot.data[i].quantity
                                        });
                                        amount = amount +
                                            (snapshot.data[i].price *
                                                snapshot.data[i].quantity);
                                      }
                                      setdatapreorder(lst, amount);
                                      for (var i = 0;
                                          i < snapshot.data.length;
                                          i++) {
                                        deleteItem(snapshot.data[i].itemId);
                                      }
                                      const snackBar = SnackBar(
                                        content: Text('Order Placed! Check the Track my Order page for its status'),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                      setState(() {});
                                    },
                              child: Text("Pre Order")),
                          Padding(padding: EdgeInsets.all(10.0)),
                          ElevatedButton(
                            child: Text("Deliver"),
                            onPressed: snapshot.data.length < 1
                                ? null
                                : () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: Text('Table Selector'),
                                            content: StatefulBuilder(
                                              builder:  (BuildContext context, StateSetter setState) {
                                                return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Form(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                        "Please select your table:"),
                                                    DropdownButton(
                                                      value: dropdownValue,
                                                      items: <String>[
                                                        'Table 1',
                                                        'Table 2',
                                                        'Table 3',
                                                        'Table 4',
                                                        'Table 5',
                                                        'Table 6',
                                                        'Table 7',
                                                        'Table 8',
                                                        'Table 9',
                                                        'Table 10',
                                                        'Table 11',
                                                        'Table 12',
                                                        'Table 13',
                                                        'Table 14',
                                                        'Table 15',
                                                        'Table 16',
                                                        'Table 17'
                                                      ].map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          dropdownValue =
                                                              newValue!;
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                              },
                                              ), 
                                            actions: [
                                              ElevatedButton(
                                                  child: Text("Submit"),
                                                  onPressed: () {
                                                    List lst = [];
                                                    num amount = 0;
                                                    for (var i = 0;
                                                        i <
                                                            snapshot
                                                                .data.length;
                                                        i++) {
                                                      lst.add({
                                                        "itemId": snapshot
                                                            .data[i].itemId
                                                            .toString(),
                                                        "name": snapshot
                                                            .data[i].name,
                                                        "qty": snapshot
                                                            .data[i].quantity
                                                      });
                                                      amount = amount +
                                                          (snapshot.data[i]
                                                                  .price *
                                                              snapshot.data[i]
                                                                  .quantity);
                                                    }
                                                    setdatadelivery(lst, amount,
                                                        dropdownValue);
                                                    for (var i = 0;
                                                        i <
                                                            snapshot
                                                                .data.length;
                                                        i++) {
                                                      deleteItem(snapshot
                                                          .data[i].itemId);
                                                    }
                                                    const snackBar = SnackBar(
                                                      content: Text('Order Placed! Check the Track my Order page for its status'),
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  })
                                            ],
                                          );
                                        });
                                  },
                          ),
                        ],
                      ));
                      return Column(
                        children: cartlist,
                      );
                    }
                    return Center(child: Text("No items in cart"));
                  }
                  return Center(child: Text("No items in cart"));
                },
              ),
            ],
          )),
      Container(
          child: Column(
            children: [
              Center(
                child: FutureBuilder(
                    future: getstatus(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              snapshot.data
                            ],
                          );
                        }
                      }
                      return Text("loading");
                    })),
              Padding(padding: EdgeInsets.all(20.0)),
              Text("Have you recieved the order?"),
              ElevatedButton(onPressed: (){
                updateStatus();
              }, child: Text("Order Recieved")),
            ],
          )),
    ];
    return widgets[index];
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Menu",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 21,
              letterSpacing: 2,
              color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff44c662),
        elevation: 0,
        centerTitle: true,
        actions: [
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => Cart_Screen(datab)));
          //     },
          //     icon: Icon(Icons.shopping_cart)),
          IconButton(
            onPressed: () {
              _signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage(datab)));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: getwidgettree(selectedindex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory), label: "Menu"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: "Track my Order"),
        ],
        currentIndex: selectedindex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
