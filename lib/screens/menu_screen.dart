// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailorware/screens/login_screen.dart';
import 'package:tailorware/screens/widgets/orders_list.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:http/http.dart' as http;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<Map> dataFuture;
  String? username;
  String? name;
  String? userId;
  bool isOpen = false;
  String? server;

  void getServer() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      server = prefs.getString('server');
    });
  }

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
    getServer();
    fetchUser();
    dataFuture = fetchMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        elevation: 2,
        title: Text("Tailorware"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
                if (snapshot.data!['data']['menus'].length > 0) {
                  var menus = snapshot.data!['data']['menus'];
                  return GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 213,
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                    shrinkWrap: true,
                    children: [
                      for (var menu in menus)
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFE0E0E0),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  menu['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    border: Border.all(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        'http://$server/api/v1/files/${menu['coverImageUrl']}',
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            width: 0.5,
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        child: Text(
                                          "View",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          side: BorderSide(
                                            width: 0.5,
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        child: Text(
                                          "Add",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ]),
                        )
                    ],
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Menus",
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

  Future<Map> fetchMenus() async {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    final response = await http.get(
      Uri.parse('http://$server/api/v1/menus'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data.');
    }
  }
}
