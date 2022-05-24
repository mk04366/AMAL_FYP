import 'package:firebase_database/firebase_database.dart';
class UserData {
  final String name;
  final String email;
  final String password;

  UserData(this.name, this.email, this.password);

  UserData.fromJson(Map<dynamic, dynamic> json)
  : name = json['name'] as String,
    email = json['email'] as String,
    password = json['password'] as String;
  Map<dynamic,dynamic> toJson() => <dynamic,dynamic> {
    'name': name,
    'email': email,
    'password': password,
  };
}