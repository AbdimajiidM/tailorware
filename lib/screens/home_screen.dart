// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tailorware/screens/menu_screen.dart';
import 'package:tailorware/screens/on_service_screen.dart';
import 'package:tailorware/screens/pending_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.selectedRoute = 0});
  final int selectedRoute;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int selectedPage;

  final _pageOptions = [
    PendingOrdersScreen(),
    OnServiceScreen(),
    MenuScreen(),
  ];

  @override
  void initState() {
    selectedPage = widget.selectedRoute;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tailorware',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Pending",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "On-services ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Menu",
            ),
          ],
          currentIndex: selectedPage,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            setState(() {
              selectedPage = index;
            });
          },
        ),
      ),
    );
  }
}
