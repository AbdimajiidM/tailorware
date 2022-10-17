import 'package:flutter/material.dart';
import 'package:tailorware/functions/generate_orders_list.dart';
import 'package:tailorware/models/order_model.dart';
import 'package:tailorware/screens/order_detail_screen.dart';

import '../../models/service_model.dart';

class OdersList extends StatefulWidget {
  const OdersList({
    super.key,
    required this.orders,
    required this.title,
    required this.color,
  });
  final List orders;
  final String title;
  final Color color;
  @override
  State<OdersList> createState() => _OdersListState();
}

class _OdersListState extends State<OdersList> {
  List<Order> ordersList = [];

  @override
  void initState() {
    super.initState();

    ordersList = generateOrdersList(widget.orders);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (BuildContext context, index) {
          Order order = ordersList[index];
          List<Service> services = order.services;

          return Column(
            children: [
              index == 0
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(25.0, 20, 0, 15),
                      child: Row(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              ExpansionPanelList(
                elevation: 0,
                animationDuration: const Duration(milliseconds: 300),
                expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 0),
                expansionCallback: (int i, bool isExpanded) {
                  setState(() {
                    ordersList[index].isExpanded = !isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    canTapOnHeader: true,
                    hasIcon: services.length == 1 ? false : true,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(
                                order: order,
                              ),
                            ),
                          )
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              order.orderNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.name),
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: services.length == 1
                            ? Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      'http://192.168.100.77/api/v1/files/${services[0].imageName}',
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                              ),
                      );
                    },
                    body: services.length > 1
                        ? Column(children: [
                            for (var service in services)
                              Padding(
                                padding: const EdgeInsets.only(left: 50),
                                child: ListTile(
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: 0),
                                  leading: Container(
                                    height: 45,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          'http://192.168.100.77/api/v1/files/${service.imageName}',
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(service.name),
                                      Text(
                                        service.style,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ])
                        : const SizedBox(
                            height: 0,
                          ),
                    isExpanded: order.isExpanded,
                  ),
                ],
              ),
            ],
          );
        });
  }
}
