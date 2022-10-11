// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tailorware/screens/homeScreen.dart';
import 'package:tailorware/screens/loginScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = false;
  String error = '';
  String baseUrl = 'http://192.168.100.77/api/v1';

  void authenticateUser(username, password, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/users/authenticate?username=$username&password=$password'),
      );

      if (response.statusCode == 200) {
        final Map user = json.decode(response.body);
        setState(() {
          error = "";
        });
        // if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        setState(() {
          error = "Invalid Username Or Password";
        });
      }
    } catch (e) {
      setState(() {
        error = '$e';
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(
        authenticateUserfn: authenticateUser,
        isLoading: isLoading,
        error: error,
      ),
    );
  }
}
