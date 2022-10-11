// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tailorware/screens/widgets/ordersList.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map> dataFuture;
  bool isOpen = false;
  @override
  void initState() {
    super.initState();
    dataFuture = fetchPendingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 20, 0, 0),
              child: Row(
                children: const [
                  Text(
                    "Pending Orders",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: dataFuture,
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "${snapshot.error}",
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              } else if (snapshot.hasData) {
                // return Pending Orders
                return OdersList(
                  orders: snapshot.data!['data']['orders'],
                );
              } else {
                return const Center(
                  child: Text(
                    "No Data",
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }
          }
        }),
      ),
    );
  }

  Future<Map> fetchPendingOrders() async {
    final response = await http.get(
      Uri.parse('http://192.168.100.77/api/v1/orders'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data.');
    }
  }
}
