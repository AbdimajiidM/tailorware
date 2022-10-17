import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tailorware/models/order_model.dart';
import 'package:tailorware/models/size_model.dart';
import 'package:tailorware/screens/on_service_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 230,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey,
                            spreadRadius: 0,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Stack(
                          children: [
                            Positioned(
                              child: IconButton(
                                onPressed: () => {
                                  Navigator.pop(context),
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.blue,
                                  size: 25,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 30,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  widget.order.customerName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '#${widget.order.ref}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ),
                  Expanded(
                      child: Container(
                    height: 230,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 0, 0, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OrderDetailItems(
                            title: 'Order',
                            value: widget.order.name,
                          ),
                          OrderDetailItems(
                            title: 'Deadline',
                            value: widget.order.deadline,
                          ),
                          OrderDetailItems(
                            title: 'Contact',
                            value: widget.order.phone,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(100, 30),
                              elevation: 1,
                            ),
                            onPressed: () {
                              showPlatformDialog(
                                context: context,
                                builder: (context) => BasicDialogAlert(
                                  title: const Center(child: Text("Serve")),
                                  content: const Text(
                                    "do you realy want to do this order?",
                                  ),
                                  actions: <Widget>[
                                    BasicDialogAction(
                                      title: const Text("No"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ElevatedButton(
                                      child: const Text("Yes"),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        assignOrderToUser(
                                          widget.order.orderId,
                                          context,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text("Serve"),
                          )
                        ],
                      ),
                    ),
                  )),
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: Text(
                  "Services",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Column(
                children: [
                  for (var index = 0;
                      index < widget.order.services.length;
                      index++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 250,
                        width: 350,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 40, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    radius: 25,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.order.services[index].name),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          widget.order.services[index].style,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              OrderSizes(
                                sizes: widget.order.services[index].sizes,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailItems extends StatelessWidget {
  const OrderDetailItems({super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 12,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class OrderSizes extends StatelessWidget {
  const OrderSizes({super.key, required this.sizes});
  final List<SizeModel> sizes;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 5,
          mainAxisExtent: 30,
        ),
        padding: const EdgeInsets.fromLTRB(65, 10, 0, 0),
        shrinkWrap: true,
        children: [
          for (var size in sizes)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${size.title} : ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '${size.value}cm',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void assignOrderToUser(orderId, context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    var server = prefs.getString('server');
    var userId = prefs.getString('userId');
    final response = await http.post(
      Uri.parse(
        'http://$server/api/v1/orders/assign-order-to-user/$orderId/$userId',
      ),
    );

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnServiceScreen(),
                  ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnServiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
