import 'package:app/screens/auth_screen.dart';
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/data_models/users.dart';
import 'package:sqflite/sqflite.dart';

class SignUpScreen extends StatefulWidget {
  Database database;
  SignUpScreen(this.database);

  @override
  _SignUpScreenState createState() => _SignUpScreenState(this.database);
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool pass = true;
  Database database;
  _SignUpScreenState(this.database);
  Future SignUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      UserData user = UserData(_nameController.text, _emailController.text,
          _passwordController.text);
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      users
          .doc(user.email)
          .set({'name': user.name, 'email': user.email, 'flag': "True"});
      // final DatabaseReference _userdataref =
      //     FirebaseDatabase.instance.ref().child('users');
      // _userdataref.push().set(user.toJson());
      showAlertDialog1(context, database);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showAlertDialog2(context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Sign Up',
            style: TextStyle(
                color: Colors.grey, fontFamily: 'Poppins', fontSize: 25)),
      ),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
        padding: EdgeInsets.only(left: 18, right: 18),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Welcome to AMAL!', style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.w800,fontFamily: 'Poppins')),
                Text('Let\'s get started', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                Container(
                  margin: EdgeInsets.only(top: 13),
                  child: TextField(
                    controller: _nameController,
                    cursorColor: Color(0xff44c662),
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                        labelText: "Full Name",
                        hintStyle: TextStyle(fontFamily: 'Poppins', color: Color(0xff444444)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)),borderSide: BorderSide(color: Color(0xff44c662),)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(gapPadding: 0, borderRadius: BorderRadius.all(Radius.circular(6)))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 13),
                  child: TextField(
                    controller: _emailController,
                    cursorColor: Color(0xff44c662),
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                        labelText: "Email",
                        hintStyle: TextStyle(fontFamily: 'Poppins', color: Color(0xff444444)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)),borderSide: BorderSide(color: Color(0xff44c662),)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(gapPadding: 0, borderRadius: BorderRadius.all(Radius.circular(6)))),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 13),
                  child: TextField(
                    controller: _passwordController,
                    cursorColor: Color(0xff44c662),
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                  obscureText: pass,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              pass = !pass;
                            });
                          },
                          icon: Icon(
                              pass ? Icons.visibility_off : Icons.visibility)),
                        labelText: "Password",
                        hintStyle: TextStyle(fontFamily: 'Poppins', color: Color(0xff444444)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6)),borderSide: BorderSide(color: Color(0xff44c662),)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(gapPadding: 0, borderRadius: BorderRadius.all(Radius.circular(6)))),
                  ),
                ),
                                Row(
                    children: <Widget>[
                      const Text('Already have an account?'),
                      TextButton(
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Auth_Screen(database)));
                        },
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  )
              ],
            ),
            Positioned(
              bottom: 15,
              right: -15,
              child: FlatButton(
                onPressed: () async {
                  await SignUp();
                    //Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: Dashboard()));
                },
                color: Color(0xff44c662),
                padding: EdgeInsets.all(13),
               shape: CircleBorder(),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            )
          ],
        ),
        height: 360,
        
        width: double.infinity,
        decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, .1),
              blurRadius: 10,
              spreadRadius: 5,
              offset: Offset(0, 1))
        ],
        borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(20), bottomStart: Radius.circular(20))),
      ),
        ],
      )
    );
  }
}

showAlertDialog1(BuildContext context, Database databasse) {
  // set up the button
  Widget okButton = ElevatedButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Auth_Screen(databasse)));
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Success"),
    content: Text("New User Created"),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertDialog2(BuildContext context) {
  // set up the button
  Widget okButton = ElevatedButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Sign up Failed"),
    content: Text("User already exists"),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
