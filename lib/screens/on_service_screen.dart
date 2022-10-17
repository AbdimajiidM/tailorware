// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailorware/screens/login_screen.dart';
import 'package:tailorware/screens/widgets/orders_list.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:http/http.dart' as http;

class OnServiceScreen extends StatefulWidget {
  const OnServiceScreen({super.key});

  @override
  State<OnServiceScreen> createState() => _OnServiceScreenState();
}

class _OnServiceScreenState extends State<OnServiceScreen> {
  late Future<Map> dataFuture;
  String? username;
  String? name;
  String? userId;
  bool isOpen = false;

  void fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? globalUsername = prefs.getString('username');
    final String? globalName = prefs.getString('name');
    final String? globalUserId = prefs.getString('userId');

    setState(() {
      username = globalUsername;
      name = globalName;
      userId = globalUserId;
    });
  }

  void userLogout(context) async {
    // Remove data for the 'counter' key.
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('remember');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(),
      ),
      (Route route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
    dataFuture = fetchOnServericeOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        elevation: 2,
        title: Text("Tailorware"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 1,
              ),
              onPressed: () {
                showPlatformDialog(
                  context: context,
                  builder: (context) => BasicDialogAlert(
                    title: Center(child: Text("Logout")),
                    content: Text("$username do you realy want to logout?"),
                    actions: <Widget>[
                      BasicDialogAction(
                        title: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      BasicDialogAction(
                        title: Text("Yes"),
                        onPressed: () async {
                          userLogout(context);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.power_settings_new,
                  ),
                  Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                if (snapshot.data!['data']['orders'].length > 0) {
                  return OdersList(
                    orders: snapshot.data!['data']['orders'],
                    title: "On-Service Orders",
                    color: Colors.green,
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Orders",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
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

  Future<Map> fetchOnServericeOrders() async {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    var userId = prefs.getString('userId');

    final response = await http.get(
      Uri.parse(
          'http://$server/api/v1/orders/on-service-orders-by-user/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data.');
    }
  }
}
