import 'package:app/screens/menu_screen.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:app/screens/home_screen.dart';
import 'package:sqflite/sqflite.dart';

class Auth_Screen extends StatefulWidget {
  Database database;
  Auth_Screen(this.database);

  @override
  _Auth_ScreenState createState() => _Auth_ScreenState(this.database);
}

class _Auth_ScreenState extends State<Auth_Screen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool pass = true;
  Database database;
  _Auth_ScreenState(this.database);

  Future SignIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MenuScreen(database)));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog1(context);
      } else if (e.code == 'wrong-password') {
        showAlertDialog2(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Sign In',
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
                Text('Welcome Back!', style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.w800,fontFamily: 'Poppins')),
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
                      const Text('Do not have an account?'),
                      TextButton(
                        child: const Text(
                          'Sign up',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SignUpScreen(database)));
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
                onPressed: ()async {
                  await SignIn();
                    //Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeft, child: Dashboard()));
                },
                color: Color(0xff44c662),
                padding: EdgeInsets.all(13),
               shape: CircleBorder(),
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
        height: 245,
        
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

showAlertDialog1(BuildContext context) {
  // set up the button
  Widget okButton = ElevatedButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Sign in Failed"),
    content: Text("This user does not exist"),
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
    title: Text("Sign in Failed"),
    content: Text("Wrong password"),
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
