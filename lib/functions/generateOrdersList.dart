import 'package:tailorware/models/orderModel.dart';
import 'package:tailorware/models/serviceModel.dart';

List<Order> generateOrdersList(orders) {
  List<Order> ordersList = [];
  for (var order in orders) {
    var orderServices = order['services']!;

    List<Service> services = [];

    for (var service in orderServices) {
      var styles = '';
      for (var index = 0; index < service['styles'].length; index++) {
        var style = service['styles'][index];
        if (index == 0) {
          styles += style;
        } else {
          styles += " - $style";
        }
      }
      services.add(
        Service(
          name: service['type']!,
          style: styles,
          imageName: service['imageUrl']!,
        ),
      );
    }
    var customer = order['customer'];

    ordersList.add(
      Order(
        orderNumber: order['orderNumber']!,
        name: order['name']!,
        customerName: customer!['name'],
        services: services,
      ),
    );
  }

  return ordersList;
}
