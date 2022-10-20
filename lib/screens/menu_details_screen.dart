import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailorware/screens/home_screen.dart';
import 'package:http/http.dart' as http;

class MenuDetailsScreen extends StatefulWidget {
  const MenuDetailsScreen({super.key, required this.menu});
  final dynamic menu;

  @override
  State<MenuDetailsScreen> createState() => _MenuDetailsScreenState();
}

class _MenuDetailsScreenState extends State<MenuDetailsScreen> {
  String? server;

  void getServer() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      server = prefs.getString('server');
    });
  }

  @override
  void initState() {
    getServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
          child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'http://$server/api/v1/files/${widget.menu['coverImageUrl']}',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -6,
                right: 0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    side: BorderSide.none,
                  ),
                  onPressed: () => {
                    changeCoverImageDialog(context, widget.menu['_id']),
                  },
                  child: const Text("Change Cover"),
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40, bottom: 10),
            child: Text(
              "Menu Products",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
                mainAxisExtent: 150,
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
              shrinkWrap: true,
              children: [
                if (widget.menu['menuProducts']!.length > 0)
                  for (var image in widget.menu['menuProducts'])
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                        ),
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            'http://$server/api/v1/files/$image',
                          ),
                        ),
                      ),
                    )
              ],
            ),
          ),
        ],
      )),
    );
  }
}

dynamic changeCoverImageDialog(context, menuId) {
  return showDialog(
    context: context,
    builder: (context) {
      // dialog body content
      Widget content = const SizedBox();
      bool isSelected = false;
      bool isUploading = false;
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
            final XFile? selectedImage =
                await imagePicker.pickImage(source: ImageSource.gallery);

            // if not empty, set imagefilelist to selected images
            if (selectedImage != null) {
              imageFileList.add(selectedImage);
            }

            // if all well set the body
            setState(() {
              content = showSelectedImage(imageFileList, context);
              menuProducts = imageFileList;
              isSelected = true;
            });
          }

          return AlertDialog(
            content: content,
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (!isSelected) {
                      selectImages();
                    } else {
                      setState(() {
                        isUploading = true;
                      });
                      await uploadCoverImage(context, menuId, menuProducts[0]);
                      setState(() {
                        isUploading = false;
                      });
                    }
                  },
                  child: !isUploading
                      ? !isSelected
                          ? const Text("Select Image")
                          : const Text("Upload Image")
                      : const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        ),
                ),
              )
            ],
          );
        },
      );
    },
  );
}

Widget showSelectedImage(imageFileList, context) {
  List<Widget> widgets = [];
  int index = 0;
  while (index < imageFileList.length) {
    widgets.add(Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.file(
          File(
            imageFileList[index].path,
          ),
          fit: BoxFit.cover,
        ),
      ),
    ));
    index += 2;
  }
  return SizedBox(
    height: 100,
    child: SingleChildScrollView(
      child: Column(
        children: widgets,
      ),
    ),
  );
}

Future<void> uploadCoverImage(context, menuId, cover) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    var url = 'http://$server/api/v1/menus/$menuId';

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse(url),
    );
    Map<String, String> headers = {"Content-type": "multipart/form-data"};

    request.files.add(http.MultipartFile(
      'cover',
      File(cover.path).readAsBytes().asStream(),
      File(cover.path).lengthSync(),
      filename: cover.path.split('/').last,
    ));

    request.headers.addAll(headers);

    var res = await request.send();
    http.Response response = await http.Response.fromStream(res);

    if (response.statusCode == 201) {
      showPlatformDialog(
        context: context,
        builder: (context) => BasicDialogAlert(
          title: const Text("Success"),
          content: const Text("Succssfully Completed"),
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
