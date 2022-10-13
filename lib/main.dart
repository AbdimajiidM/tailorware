import 'package:flutter/material.dart';
import 'package:tailorware/screens/homeScreen.dart';
import 'package:tailorware/screens/loginScreen.dart';
import "package:shared_preferences/shared_preferences.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('userId');

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: userId == null ? const LoginPage() : const HomeScreen(),
    ),
  );
}
