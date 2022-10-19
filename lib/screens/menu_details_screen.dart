import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    print('Lenght : :::: : ${widget.menu['menuProducts'].length}');
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
                  onPressed: () => {},
                  child: Text(widget.menu['name']),
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
          GridView(
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
                          'http://$server/api/v1/files/${image}',
                        ),
                      ),
                    ),
                  )
            ],
          ),
        ],
      )),
    );
  }
}
