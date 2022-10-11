import 'package:tailorware/models/serviceModel.dart';

class Order {
  Order({
    required this.orderNumber,
    required this.name,
    required this.customerName,
    required this.services,
    this.isExpanded = false,
  });
  int orderNumber;
  String name;
  String customerName;
  List<Service> services;
  bool isExpanded;
}
