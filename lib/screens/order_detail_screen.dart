import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:tailorware/models/order_model.dart';
import 'package:tailorware/models/size_model.dart';
import 'package:tailorware/screens/home_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.isPending,
  });

  final Order order;
  final bool isPending;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String? server;

  void getServer() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      server = prefs.getString('server');
    });
  }

  void goBackToRoute(route) {
    Navigator.pop(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => const HomeScreen(
          selectedRoute: 1,
        ),
      ),
      (Route route) => false,
    );
  }

  @override
  void initState() {
    getServer();
    super.initState();
  }

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
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: IconButton(
                              onPressed: () => {
                                Navigator.pop(context),
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: widget.isPending
                                    ? Colors.blue
                                    : Colors.green,
                                size: 25,
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: widget.isPending
                                      ? Colors.blue
                                      : Colors.green,
                                  radius: 30,
                                  child: const Icon(
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
                                  style: TextStyle(
                                    color: widget.isPending
                                        ? Colors.blue
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            color:
                                widget.isPending ? Colors.blue : Colors.green,
                          ),
                          OrderDetailItems(
                            title: 'Deadline',
                            value: widget.order.deadline,
                            color:
                                widget.isPending ? Colors.blue : Colors.green,
                          ),
                          OrderDetailItems(
                            title: 'Contact',
                            value: widget.order.phone,
                            color:
                                widget.isPending ? Colors.blue : Colors.green,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  widget.isPending ? Colors.blue : Colors.green,
                              minimumSize: const Size(100, 30),
                              elevation: 1,
                            ),
                            onPressed: () {
                              showPlatformDialog(
                                context: context,
                                builder: (context) => BasicDialogAlert(
                                  title: Center(
                                    child: widget.isPending
                                        ? const Text("Serve")
                                        : const Text("Finish Order"),
                                  ),
                                  content: widget.isPending
                                      ? const Text(
                                          "do you realy want to do this order?",
                                        )
                                      : const Text(
                                          "do you realy want to finish this order?",
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
                                        if (widget.isPending) {
                                          var assignOrderOrderResponse =
                                              await assignOrderToUser(
                                            widget.order.orderId,
                                          );
                                          if (!mounted) return;
                                          Navigator.pop(context);
                                          showPlatformDialog(
                                            context: context,
                                            builder: (context) =>
                                                BasicDialogAlert(
                                              title: Text(
                                                assignOrderOrderResponse[
                                                    'title']!,
                                                style: TextStyle(
                                                  color:
                                                      assignOrderOrderResponse[
                                                                  'error'] ==
                                                              true
                                                          ? Colors.red
                                                          : Colors.black,
                                                ),
                                              ),
                                              content: Text(
                                                assignOrderOrderResponse[
                                                    'message']!,
                                              ),
                                              actions: <Widget>[
                                                BasicDialogAction(
                                                  title: const Text("OK"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            const HomeScreen(
                                                          selectedRoute: 1,
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
                                          var finishedOrderResponse =
                                              await finishOrder(
                                            widget.order.orderId,
                                          );
                                          if (!mounted) return;
                                          Navigator.pop(context);
                                          showPlatformDialog(
                                            context: context,
                                            builder: (context) =>
                                                BasicDialogAlert(
                                              title: Text(
                                                finishedOrderResponse['title']!,
                                                style: TextStyle(
                                                  color: finishedOrderResponse[
                                                              'error'] ==
                                                          true
                                                      ? Colors.red
                                                      : Colors.black,
                                                ),
                                              ),
                                              content: Text(
                                                finishedOrderResponse[
                                                    'message']!,
                                              ),
                                              actions: <Widget>[
                                                BasicDialogAction(
                                                  title: const Text("OK"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.of(context)
                                                        .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            const HomeScreen(
                                                          selectedRoute: 1,
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
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: widget.isPending
                                ? const Text("Serve")
                                : const Text("Complete"),
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
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 250,
                            width: 350,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
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
                                        backgroundColor: widget.isPending
                                            ? Colors.blue
                                            : Colors.green,
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
                                          Text(
                                              "${widget.order.services[index].quantity} ${widget.order.services[index].name}"),
                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                              widget
                                                  .order.services[index].style,
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
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => {
                              showPlatformDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Image(
                                    image: NetworkImage(
                                      'http://$server/api/v1/files/${widget.order.services[index].imageName}',
                                    ),
                                  ),
                                ),
                              )
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      'http://$server/api/v1/files/${widget.order.services[index].imageName}',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 25,
                              width: 25,
                              color: Colors.blue,
                              alignment: Alignment.center,
                              child: Text(
                                widget.order.services[index].menu[
                                    widget.order.services[index].menu.length -
                                        1],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> assignOrderToUser(orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var server = prefs.getString('server');
      var userId = prefs.getString('userId');

      final response = await http.post(
        Uri.parse(
            'http://$server/api/v1/orders/assign-order-to-user/$orderId/$userId'),
      );

      if (response.statusCode == 200) {
        return {
          'title': "Success",
          "message": "Succssfully Completed",
          "error": false
        };
      } else {
        var error = json.decode(response.body);
        return {'title': "Error", "message": error, "error": true};
      }
    } catch (e) {
      return {'title': "Error", "message": '$e', "error": true};
    }
  }

  Future<Map<String, dynamic>> finishOrder(orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var server = prefs.getString('server');

      final response = await http.post(
        Uri.parse(
          'http://$server/api/v1/orders/finish-order/$orderId',
        ),
      );

      if (response.statusCode == 200) {
        return {
          'title': "Success",
          "message": "Succssfully Completed",
          "error": false
        };
      } else {
        var error = json.decode(response.body);
        return {'title': "Error", "message": error, "error": true};
      }
    } catch (e) {
      return {'title': "Error", "message": '$e', "error": true};
    }
  }
}

class OrderDetailItems extends StatelessWidget {
  const OrderDetailItems({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

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
          style: TextStyle(
            color: color,
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
