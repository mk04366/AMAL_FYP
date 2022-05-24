import 'package:app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final database = await openDatabase(
    join(await getDatabasesPath(), "app_database_final.db"),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE shoppingcart(itemId TEXT PRIMARY KEY, name TEXT, price INTEGER, imageUrl TEXT, description TEXT, category TEXT, quantity INT)');
    },
    version: 1,
  );
  runApp(MyApp(database));
}

class MyApp extends StatelessWidget {
  Database database;
  
  MyApp(this.database, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.orange[50],
        textTheme: GoogleFonts.spartanTextTheme(),
      ),
      home: MyHomePage(database)
    );
  }
}

class MyHomePage extends StatelessWidget {
  Database database;
  // Future<void> updateDB() async {
  //   final db = await database;
  //   db.execute("ALTER TABLE shoppingcart ADD quantity INT");
  //   print("DB updated");
  // }
  
  MyHomePage(this.database,{ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.network('https://github.com/muzammiltariq/Final-Year-Project/blob/main/Mobile%20Application/assets/images/logo.jpg?raw=true', width: 190, height: 190),
          Container(
            margin: EdgeInsets.only(bottom: 10, top: 0),
            child: Text('AMAL', style: TextStyle(fontFamily: 'Pacifico',fontSize: 30,color: Colors.black54,letterSpacing: 2)),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, top: 0),
            child: Text('A Food Delivery Service', style: TextStyle(fontFamily: 'Pacifico',fontSize: 25,color: Colors.black54,letterSpacing: 1)),
          ),
          Container(
            width: 200,
            margin: EdgeInsets.only(bottom: 0),
            child: ElevatedButton( child: Text("Sign in"), onPressed: (){ 
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Auth_Screen(database)));
           }),
          ),
          Container(
            width: 200,
            padding: EdgeInsets.all(0),
            child: ElevatedButton( child: Text('Sign Up'), onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignUpScreen(database)));
             }),
          ),
          // Container(
          //   width: 200,
          //   padding: EdgeInsets.all(0),
          //   child: ElevatedButton( child: Text('Update DB'), onPressed: (){
          //     updateDB();
          //   }),
          // ),
        ],
      )),
      backgroundColor: Color(0xffF4F7FA),
    );
  }
}