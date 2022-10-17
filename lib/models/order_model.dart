import 'package:tailorware/models/service_model.dart';

class Order {
  Order({
    required this.orderNumber,
    required this.name,
    required this.customerName,
    required this.services,
    this.isExpanded = false,
    required this.ref,
    required this.phone,
    required this.deadline,
    required this.orderId,
  });
  final int orderNumber;
  final String name;
  final String customerName;
  final String ref;
  final String phone;
  final String deadline;
  final List<Service> services;
  final String orderId;
  bool isExpanded;
}
