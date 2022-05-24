// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'auth_screen.dart';

// class Pickup_Screen extends StatelessWidget {
//   const Pickup_Screen({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Container(
//         padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//         child: Text("Your food will be ready for pickup soon",
//         style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
//       ),
//       );
//   }
// }
// class Deliver_Screen extends StatelessWidget {
//   const Deliver_Screen({ Key? key }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Container(
//         padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
//         child: Text("Your food is being delivered",
//         style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
//       ),
//     );
// }
// }

// class Order_Screen extends StatelessWidget {
//   Future<void> _signOut() async {
//     await FirebaseAuth.instance.signOut();
//   }
//   //late String name;
//   //ItemScreen(this.name);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Order"),
//       actions: [
//           IconButton(
//             onPressed: () {
//               _signOut();
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => Auth_Screen()));
//             },
//             icon: Icon(Icons.logout),
//           ),
//         ],),
//       body: Center(
//         child: Column(
//         children: [
//           const Padding(padding: EdgeInsets.all(20.0)),
//           const Text("Do you want to pickup your order or get it delivered?",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,),
//           textAlign: TextAlign.center,),
//           ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Pickup_Screen()));}, child: const Text("Pickup",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,),),),
//           ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Deliver_Screen()));}, child: const Text("Deliver",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0,),),),
//         ],
//       ),
//       ),
//     );
//   }
// }