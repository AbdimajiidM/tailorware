// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailorware/screens/home_screen.dart';
import 'package:tailorware/screens/login_screen.dart';
import 'package:tailorware/screens/menu_details_screen.dart';

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
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MenuDetailsScreen(
                                                menu: menu,
                                              ),
                                            ),
                                          );
                                        },
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
                                        onPressed: () {
                                          addMenuProductsDialog(
                                            context,
                                            menu['_id'],
                                          );
                                        },
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

dynamic addMenuProductsDialog(context, menuId) {
  return showDialog(
    context: context,
    builder: (context) {
      // dialog body content
      Widget content = SizedBox();
      bool isSelected = false;
      List<XFile> menuProducts = [];
      // dialog box
      return StatefulBuilder(
        builder: (context, setState) {
          void selectImages() async {
            // image picker object
            final ImagePicker imagePicker = ImagePicker();
            // picked images
            List<XFile>? imageFileList = [];

            // select[pick] multiple images
            final List<XFile> selectedImages =
                await imagePicker.pickMultiImage();

            // if not empty, set imagefilelist to selected images
            if (selectedImages.isNotEmpty) {
              imageFileList.addAll(selectedImages);
            }

            // if all well set the body
            setState(() {
              content = showSelectedImages(imageFileList, context);
              menuProducts = imageFileList;
              isSelected = true;
            });
          }

          return AlertDialog(
            content: content,
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (!isSelected) {
                      selectImages();
                    } else {
                      addMenuItems(context, menuId, menuProducts);
                    }
                  },
                  child: !isSelected
                      ? Text("Select Images")
                      : Text("Upload Images"),
                ),
              )
            ],
          );
        },
      );
    },
  );
}

Widget showSelectedImages(imageFileList, context) {
  List<Widget> widgets = [];
  int index = 0;
  while (index < imageFileList.length) {
    widgets.add(Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image.file(
              File(
                imageFileList[index].path,
              ),
              fit: BoxFit.cover,
            ),
          ),
          index < imageFileList.length - 1
              ? SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.file(
                    File(
                      imageFileList[index + 1].path,
                    ),
                    fit: BoxFit.cover,
                  ),
                )
              : SizedBox(
                  width: 100,
                  height: 100,
                ),
        ],
      ),
    ));
    index += 2;
  }
  return SizedBox(
    height: 250,
    child: SingleChildScrollView(
      child: Column(
        children: widgets,
      ),
    ),
  );
}

void addMenuItems(context, menuId, menuProducts) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    var url = 'http://$server/api/v1/menus/add-menu-products/$menuId';

    // var request = http.MultipartRequest('POST', Uri.parse(url));
    // request.files.add(await http.MultipartFile.fromPath('menuProducts', menuProducts));
    // var response = await request.send();
    // // return res.reasonPhrase;

    final response = await http.post(
      Uri.parse(
        'http://$server/api/v1/menus/add-menu-products/$menuId',
      ),
      body: {menuProducts: menuProducts},
    );

    print('Here Wer Are');
    if (response.statusCode == 200) {
      showPlatformDialog(
        context: context,
        builder: (context) => BasicDialogAlert(
          title: const Text("Error"),
          content: const Text("Succssfully Completed"),
          actions: <Widget>[
            BasicDialogAction(
              title: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen(
                      selectedRoute: 3,
                    ),
                  ),
                  (Route route) => false,
                );
              },
            ),
          ],
        ),
      );
    } else {
      var error = json.decode(response.body);
      showPlatformDialog(
        context: context,
        builder: (context) => BasicDialogAlert(
          title: const Text(
            "Error",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          content: Text(error['message'] ?? 'Error'),
          actions: <Widget>[
            BasicDialogAction(
              title: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  } catch (e) {
    showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: const Text(
          "Error",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        content: Text("Error : $e"),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen(
                    selectedRoute: 2,
                  ),
                ),
                (Route route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
