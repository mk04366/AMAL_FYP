import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/data_models/items.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ItemScreen extends StatefulWidget {
  late ItemData item;
  Database datab;
  ItemScreen(this.item, this.datab, {Key? key}) : super(key: key);

  @override
  State<ItemScreen> createState() => _ItemScreenState(item, datab);
}

class _ItemScreenState extends State<ItemScreen> {
  ItemData item;
  Database datab;
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> insertdata(ItemData item, int quantity) async {
    item.quantity = quantity;
    final db = await datab;
    await db.insert('shoppingcart', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  _ItemScreenState(this.item, this.datab);
  int _quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF4F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xffF4F7FA),
          centerTitle: true,
          leading: BackButton(
            color: Colors.black54,
          ),
          actions: [
            IconButton(
              color: Colors.black54,
              onPressed: () {
                _signOut();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage(datab)));
              },
              icon: Icon(Icons.logout),
            ),
          ],
          title: Text(item.name,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins')),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 100, bottom: 100),
                        padding: EdgeInsets.only(top: 100, bottom: 50),
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(item.name,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins')),
                            Text("Rs. " + item.price.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Poppins')),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 25),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Text('Quantity',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Poppins')),
                                    margin: EdgeInsets.only(bottom: 15),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 55,
                                        height: 55,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_quantity == 2) return;
                                              _quantity += 1;
                                            });
                                          },
                                          child: Icon(Icons.add),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Text(_quantity.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Poppins')),
                                      ),
                                      Container(
                                        width: 55,
                                        height: 55,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              if (_quantity == 1) return;
                                              _quantity -= 1;
                                            });
                                          },
                                          child: Icon(Icons.remove),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 180,
                              child: TextButton(
                                onPressed: () async {
                                  await insertdata(item, _quantity);
                                  var name = item.name;
                                  Fluttertoast.showToast(
                                    msg: "$name added to cart",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    fontSize: 16.0,
                                  );
                                },
                                child: Text(
                                  "Add to Cart",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20.0),
                                ),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xff44c662)),
                                    textStyle: MaterialStateProperty.all(
                                        const TextStyle(color: Colors.black))),
                              ),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                  color: Color.fromRGBO(0, 0, 0, .05))
                            ]),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        height: 160,
                        child: Container(
                          height: 200,
                          width: 200,
                          child: Image(
                              image:
                                  NetworkImage(item.imageUrl)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
